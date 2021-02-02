class ServiceRepository {
  final GoogleMapsApiProvider _googleMapsApiProvider;

  ServiceRepository({
    GoogleMapsApiProvider googleMapsApiProvider,
  }) : _googleMapsApiProvider =
            googleMapsApiProvider ?? GoogleMapsApiProvider();

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
}
