import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:llevo/src/models/address.dart';
import 'package:llevo/src/models/autocomplete_result.dart';
import 'package:llevo/src/resources/repositories/service_repo.dart';
import 'package:llevo/src/utils/errors/crashlytics_error.dart';
import 'package:uuid/uuid.dart';

part 'autocomplete_event.dart';
part 'autocomplete_state.dart';

class AutocompleteBloc extends Bloc<AutocompleteEvent, AutocompleteState> {
  final Uuid _uuid;
  final ServiceRepository serviceRepository;
  final CrashlyticsError crashlyticsError;

  AutocompleteBloc({
    @required this.serviceRepository,
    Uuid uuid,
    CrashlyticsError crashlyticsError,
  })  : assert(serviceRepository != null),
        this.crashlyticsError = crashlyticsError ?? CrashlyticsError(),
        this._uuid = uuid ?? Uuid();

  @override
  AutocompleteState get initialState => AutocompleteState(
        token: _uuid.v4(),
      );

  @override
  Stream<AutocompleteState> mapEventToState(
    AutocompleteEvent event,
  ) async* {
    if (event is AutocompleteTyping) {
      yield* mapAutocompleteTypingToState(event);
    } else if (event is AutocompleteConfirmAddress) {
      yield* mapAutocompleteConfirmAddressToState(event);
    } else if (event is AutocompleteChangeIndex) {
      yield* mapAutocompleteChangeIndexToState(event);
    }
  }

  Stream<AutocompleteState> mapAutocompleteTypingToState(
    AutocompleteTyping event,
  ) async* {
    final prevState = state;
    if (event.queryText.isEmpty || event.queryText.length <= 3) {
      return;
    }

    yield state.copyWith(
      isLoading: true,
    );

    try {
      final results = await serviceRepository.getAutocompleteResults(
        event.queryText,
        state.token,
        event.userLocation,
      );
      yield state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e, s) {
      yield state.copyWith(
        isFailure: true,
        failureMsg: crashlyticsError.reportAndReturnMsg(e, s),
      );
      yield prevState;
    }
  }

  Stream<AutocompleteState> mapAutocompleteConfirmAddressToState(
    AutocompleteConfirmAddress event,
  ) async* {
    final prevState = state;
    yield state.copyWith(
      isLoading: true,
    );

    try {
      final address = await serviceRepository.getAddressByPlaceId(
        event.placeId,
        state.token,
      );

      yield state.copyWith(
        isFavoriteAddress: event.isFavoriteAddress,
        addressSearched: address,
      );
      yield AutocompleteState(
        token: _uuid.v4(),
        addressIndex: prevState.addressIndex,
      );
    } catch (e, s) {
      yield state.copyWith(
        isFailure: true,
        failureMsg: crashlyticsError.reportAndReturnMsg(e, s),
      );
      yield prevState;
    }
  }

  Stream<AutocompleteState> mapAutocompleteChangeIndexToState(
    AutocompleteChangeIndex event,
  ) async* {
    if (state.addressIndex != event.newIndex) {
      yield state.copyWith(
        results: <AutocompleteResult>[],
        addressIndex: event.newIndex,
      );
    }
  }
}
