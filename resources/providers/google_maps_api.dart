import 'dart:convert' show json;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:http/http.dart' as http;
import 'package:ex-package/src/models/autocomplete_result.dart';
import 'package:ex-package/src/models/service_info.dart';
import 'package:ex-package/src/utils/utils.dart'
    show getFormattedTextFromAddressComponents;

import '../../../../models/address.dart';
import '../../../../../environment.dart';

class GoogleMapsApiProvider {
  final http.Client _httpClient;

  final googleApiUrl = "maps.googleapis.com";
  final language = "es-419";

  GoogleMapsApiProvider({
    http.Client httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<List<AutocompleteResult>> getAutocompleteResults(
    String queryText,
    String token,
    LatLng userLocation,
  ) async {
    final queryParameters = {
      'input': "$queryText",
      'language': language,
      'sessiontoken': token,
      'key': Environment.values.googleApiKey,
      'components': "country:co",
      if (userLocation != null) ...{
        "location": "${userLocation.latitude},${userLocation.longitude}",
        "radius": "20000",
      }
    };

    final Uri uri = Uri.https(
      googleApiUrl,
      "/maps/api/place/autocomplete/json",
      queryParameters,
    );

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    final body = json.decode(response.body);

    return List<AutocompleteResult>.from(
      body['predictions'].map(
        (result) {
          return AutocompleteResult.fromApiJson(result);
        },
      ),
    );
  }

  Future<Address> getAddressByPlaceId(
    String placeId,
    String token,
  ) async {
    final queryParameters = {
      'place_id': placeId,
      'sessiontoken': token,
      'fields':
          "name,place_id,address_component,formatted_address,geometry,type",
      'language': language,
      'key': Environment.values.googleApiKey,
    };

    final Uri uri = Uri.https(
      googleApiUrl,
      "/maps/api/place/details/json",
      queryParameters,
    );

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    final body = json.decode(response.body);

    if (body["status"] != "OK") {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    final result = body["result"];

    final Map location = result["geometry"]["location"];
    return Address(
      latitude: location["lat"],
      longitude: location["lng"],
      formatted: getFormattedTextFromAddressComponents(
        result["address_components"],
      ),
      title: result['formatted_address'],
    );
  }

  Future<Address> getAddressByLocation(LatLng latLng) async {
    final queryParameters = {
      'latlng': "${latLng.latitude},${latLng.longitude}",
      'language': language,
      //'location_type': "ROOFTOP",
      //'result_type': "street_address",
      'key': Environment.values.googleApiKey,
    };

    final Uri uri = Uri.https(
      googleApiUrl,
      "/maps/api/geocode/json",
      queryParameters,
    );

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    final body = json.decode(response.body);

    if (body["status"] != "OK") {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }
    final firstAddress = body["results"].first;

    final Map location = firstAddress["geometry"]["location"];
    return Address(
      latitude: location["lat"],
      longitude: location["lng"],
      formatted: getFormattedTextFromAddressComponents(
        firstAddress["address_components"],
      ),
      title: firstAddress['formatted_address'],
    );
  }

  Future<List<Address>> getAddressesByText(String queryText) async {
    final queryParameters = {
      'query': "$queryText",
      'language': language,
      //'fields': 'opening_hours,icon,geometry',
      'key': Environment.values.googleApiKey,
    };

    final Uri uri = Uri.https(
      googleApiUrl,
      "/maps/api/place/textsearch/json",
      queryParameters,
    );

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    final body = json.decode(response.body);

    if (body["status"] != "OK") {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    return List<Address>.from(
      body['results'].map(
        (address) {
          final Map location = address["geometry"]["location"];
          return Address(
            latitude: location["lat"],
            longitude: location["lng"],
            title: address["name"],
            digited: queryText,
            formatted: address["formatted_address"],
          );
        },
      ),
    );
  }

  Future<ServiceInfo> getRouteValues(List<Address> addresses) async {
    final origin = addresses[0].getLatLng();
    final destination = addresses.last.getLatLng();
    final waypoints = getWaypointsString(addresses);

    final queryParameters = {
      'origin': "${origin.latitude},${origin.longitude}",
      'waypoints': waypoints,
      'destination': "${destination.latitude},${destination.longitude}",
      'language': language,
      'key': Environment.values.googleApiKey,
    };

    final Uri uri = Uri.https(
      googleApiUrl,
      "/maps/api/directions/json",
      queryParameters,
    );

    final http.Response response = await _httpClient.get(uri);

    if (response.statusCode != 200)
      throw Exception('Ha ocurrido un error intenta mas tarde');

    final body = json.decode(response.body);

    if (body["status"] != "OK") {
      throw Exception('Ha ocurrido un error intenta mas tarde');
    }

    return ServiceInfo.fromGoogleRouteJson(body);
  }

  String getWaypointsString(List<Address> addresses) {
    String waypoints = "";
    for (var i = 1; i < addresses.length - 1; i++) {
      if (i == 1) {
        waypoints += '${addresses[i].latitude},${addresses[i].longitude}';
        continue;
      }
      waypoints += '|${addresses[i].latitude},${addresses[i].longitude}';
    }
    if (waypoints.isEmpty) {
      return null;
    }

    return waypoints;
  }
}
