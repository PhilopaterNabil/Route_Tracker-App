import "dart:convert";

import "package:http/http.dart" as http;
import "package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart";
import "package:route_tracker_app/features/google_map/data/models/place_details_model/place_details_model.dart";

class GoogleMapsPlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyD4PqvgXw20qL9OHeTnGB-vw-ySTvrQRzU';
  Future<List<PlaceModel>> getPedictions(
      {required String input, required String sessionToken}) async {
    var response = await http.get(Uri.parse(
        '$baseUrl/autocomplete/json?key=$apiKey&input=$input&sessiontoken=$sessionToken'));
    print('API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceModel> placeList = [];

      for (var item in data) {
        placeList.add(PlaceModel.fromJson(item));
      }

      return placeList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<PlaceDetailsModel> getplaceDetails({required String placeId}) async {
    var response = await http.get(Uri.parse('$baseUrl/details/json?key=$apiKey&place_id=$placeId'));
    print('API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];

      return PlaceDetailsModel.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
