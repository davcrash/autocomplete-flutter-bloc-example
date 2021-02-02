import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:llevo/src/models/autocomplete_result.dart';
import 'package:llevo/src/models/service_info.dart';
import 'package:llevo/src/resources/providers/firestore_chat.dart';
import 'package:llevo/src/resources/providers/google_maps_api.dart';
import 'package:location/location.dart';

import '../../../../models/rating.dart';
import '../../../../models/area.dart';
import '../../../../models/address.dart';
import '../../../../models/location.dart' as LocationModel;
import '../../../../models/tariff.dart';
import '../../../../models/service.dart';
import '../../../../models/user.dart';
import '../../../../models/favorite_addresses.dart';
import '../../../providers/sp_recently_addresses.dart';
import '../../../providers/firestore_favorite_addresses.dart';
import '../../../providers/firestore_area.dart';
import '../../../providers/firestore_location.dart';
import '../../../providers/here_api_address.dart';
import '../../../providers/firestore_service.dart';
import '../../../providers/firestore_params.dart';
import '../../../providers/api_cancellation_reason_service.dart';

class ServiceRepository {
  final FirestoreServiceProvider _firestoreServiceProvider;
  final FirestoreChatProvider _firestoreChatProvider;
  final FirestoreLocationProvider _firestoreLocationsProvider;
  final FirestoreParamsProvider _firestoreParamsProvider;
  final FirestoreAreaProvider _firestoreAreaProvider;
  final FirestoreFavoriteAddressesProvider _firestoreFavoriteAddressesProvider;

  final GoogleMapsApiProvider _googleMapsApiProvider;
  final HereApiProvider _hereApiAddressProvider;
  final RecentlyAddressesProvider _recentlyAddressesProvider;
  final Location _location;
  final CloudFunctions _cloudFunctions;
  final ApiCancellationReasonServiceProvider
      _apiCancellationReasonServiceProvider;
  Tariff _instanceTariff; //TODO: eliminar

  ServiceRepository({
    FirestoreServiceProvider firestoreServiceProvider,
    FirestoreLocationProvider firestoreLocationsProvider,
    FirestoreChatProvider firestoreChatProvider,
    FirestoreParamsProvider firestoreParamsProvider,
    FirestoreAreaProvider firestoreAreaProvider,
    FirestoreFavoriteAddressesProvider favoriteAddressesProvider,
    GoogleMapsApiProvider googleMapsApiProvider,
    HereApiProvider hereApiAddressProvider,
    RecentlyAddressesProvider recentlyAddressesProvider,
    Location location,
    CloudFunctions cloudFunctions,
    ApiCancellationReasonServiceProvider apiCancellationReasonServiceProvider,
  })  : _firestoreServiceProvider =
            firestoreServiceProvider ?? FirestoreServiceProvider(),
        _firestoreChatProvider =
            firestoreChatProvider ?? FirestoreChatProvider(),
        _firestoreLocationsProvider =
            firestoreLocationsProvider ?? FirestoreLocationProvider(),
        _firestoreParamsProvider =
            firestoreParamsProvider ?? FirestoreParamsProvider(),
        _firestoreAreaProvider =
            firestoreAreaProvider ?? FirestoreAreaProvider(),
        _firestoreFavoriteAddressesProvider =
            favoriteAddressesProvider ?? FirestoreFavoriteAddressesProvider(),
        _hereApiAddressProvider = hereApiAddressProvider ?? HereApiProvider(),
        _googleMapsApiProvider =
            googleMapsApiProvider ?? GoogleMapsApiProvider(),
        _recentlyAddressesProvider =
            recentlyAddressesProvider ?? RecentlyAddressesProvider(),
        _location = location ?? Location(),
        _cloudFunctions = cloudFunctions ?? CloudFunctions.instance,
        _apiCancellationReasonServiceProvider =
            apiCancellationReasonServiceProvider ??
                ApiCancellationReasonServiceProvider();

  Stream<List<Service>> getInProgressServices(String uid) {
    return _firestoreServiceProvider.getInProgressServices(uid);
  }

  Future<Service> getInProgressService(User user) async {
    return await _firestoreServiceProvider.getInProgressService(user.uid);
  }

  Future<Tariff> get tariff async {
    if (_instanceTariff == null) {
      _instanceTariff = await this.getTariff();
    }
    return _instanceTariff;
  }

  Future<Tariff> getTariff() async {
    return await _firestoreParamsProvider.getTariff();
  }

  Future<LatLng> getLocation() async {
    if (!await _location.hasPermission()) {
      if (Platform.isIOS) {
        _location.requestPermission();
        return null;
      }
      if (!await _location.requestPermission()) return null;
    }
    if (!await _location.serviceEnabled()) {
      if (!await _location.requestService()) return null;
    }
    final LocationData locationData = await _location.getLocation();

    return LatLng(
      locationData.latitude,
      locationData.longitude,
    );
  }

  Future<List<AutocompleteResult>> getAutocompleteResults(
    String queryText,
    String token,
    LatLng userLocation,
  ) async {
    return await _googleMapsApiProvider.getAutocompleteResults(
      queryText,
      token,
      userLocation,
    );
  }

  Future<Address> getAddressByPlaceId(
    String placeId,
    String token,
  ) async {
    return await _googleMapsApiProvider.getAddressByPlaceId(
      placeId,
      token,
    );
  }

  Future<Address> getAddressByLocation(LatLng latLng) async {
    if (latLng == null) return null;
    return await _googleMapsApiProvider.getAddressByLocation(latLng);
  }

  Future<List<Address>> getAddressesByText(String queryText) async {
    return await _googleMapsApiProvider.getAddressesByText(queryText);
  }

  Future<ServiceInfo> getRouteValues(List<Address> addresses) async {
    return await _googleMapsApiProvider.getRouteValues(addresses);
  }

  Future<String> getCityCodeByLocation(LatLng latLng) async {
    if (latLng == null) return null;
    final addressWithCode = await _hereApiAddressProvider.getAddressByLocation(
      latLng,
    );
    return addressWithCode?.cityCode;
  }

  Future<FavoriteAddress> getFavoriteAddresses(String uid) async {
    return await _firestoreFavoriteAddressesProvider.getFavoriteAddresses(uid);
  }

  Future<List<Address>> getRecentlyAddresses() async {
    return await _recentlyAddressesProvider.getRecentlyAddresses();
  }

  Future<void> updateFavoriteAddresses(
    FavoriteAddress favoriteAddress,
    String uid,
  ) async {
    return await _firestoreFavoriteAddressesProvider.updateFavoriteAddresses(
      favoriteAddress,
      uid,
    );
  }

  Future<List<Address>> addRecentlyAddresses(Address newAddress) async {
    return await _recentlyAddressesProvider.addRecentlyAddresses(newAddress);
  }

  Future<bool> getLocationPermissionState() async {
    if (!await _location.hasPermission()) return false;
    if (!await _location.serviceEnabled()) return false;
    return true;
  }

  Future<String> setService(Service service) async {
    service.setCreateAt();
    service.setUpdatedAt();
    service.setInitialServiceHistory();
    return await _firestoreServiceProvider.setService(service);
  }

  Stream<Service> getServiceStream(String documentId) {
    return _firestoreServiceProvider.getServiceStream(documentId);
  }

  Future<List<LocationModel.Location>> getDriversNearest(LatLng latLng) async {
    final listDriversNearest =
        await _firestoreLocationsProvider.getDriversNearest(
      latLng,
      2,
    );

    if (listDriversNearest.isEmpty) return [];
    return listDriversNearest.toList();
  }

  Future<Area> getArea(String cityCode) async {
    return await _firestoreAreaProvider.getArea(cityCode);
  }

  Future<void> sendNotificationNewService(
    List<String> tokens,
    String serviceDocumentId,
  ) async {
    final HttpsCallable sendMultipleNotifications =
        _cloudFunctions.getHttpsCallable(
      functionName: 'sendMultipleNotifications',
    );
    await sendMultipleNotifications.call(<String, dynamic>{
      'tokens': tokens,
      'type': "service_new",
      'data': json.encode({
        "service_id": serviceDocumentId,
        "type": "service_new",
      }),
    });
  }

  Future<void> cancelService(
    String serviceId,
    bool isChatNull,
    ServiceStatus serviceStatus,
  ) async {
    final batch = Firestore.instance.batch();
    _firestoreServiceProvider.cancelService(
      batch,
      serviceId,
      serviceStatus,
    );
    if (!isChatNull) {
      _firestoreChatProvider.deactivateChat(batch, serviceId);
    }
    return await batch.commit();
  }

  Future<void> createCancellationReason(
    User user,
    Service service,
    String cancellationReason,
  ) async {
    return await _apiCancellationReasonServiceProvider.createCancellationReason(
      user,
      service,
      cancellationReason,
    );
  }

  Future<void> cancelGlobalStateService(String documentId) async {
    return await _firestoreServiceProvider.cancelGlobalStateService(documentId);
  }

  Stream<LocationModel.Location> getLocationStream(String driverUid) {
    return _firestoreLocationsProvider.getLocationStream(driverUid);
  }

  Future<void> ratingServiceDriver(String serviceId, Rating rating) async {
    return await _firestoreServiceProvider.ratingServiceDriver(
      serviceId,
      rating,
    );
  }

  Future<void> updateDriverUserRating(
    String driverUid,
    Rating rating,
  ) async {
    final HttpsCallable updateUserRating = _cloudFunctions.getHttpsCallable(
      functionName: 'updateUserRating',
    );
    await updateUserRating.call(<String, dynamic>{
      'uidToRating': driverUid,
      'ratingType': "driver",
      'ratingRequested': rating.toUpdateRatingCloudFunctionJson(),
    });
  }

  Future<List<Service>> getList(String uid) async {
    return await _firestoreServiceProvider.getList(uid);
  }

  Future<List<Service>> getNextList(String uid, DateTime date) async {
    return await _firestoreServiceProvider.getNextList(uid, date);
  }
}
