import "dart:convert";

import "package:http/http.dart" as http;
import "package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_autocomplete_model.dart";

class GoogleMapsPlaceService {
  final String baseUrl = "https://maps.googleapis.com/maps/api/place";
  final String apiKey = "AIzaSyAaVDM4HROT2aKNMuS8URYbDJEJorZEA3w";
  Future<List<PlaceModel>> getPedictions({required String input}) async {
    var response = await http.get(Uri.parse('$baseUrl/autocomplete/json?key=$apiKey&input=$input'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceModel> placeList = data.map((e) => PlaceModel.fromJson(e)).toList();

      return placeList;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
