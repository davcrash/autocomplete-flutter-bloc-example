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
}
