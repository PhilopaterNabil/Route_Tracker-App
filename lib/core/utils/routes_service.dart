import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route_tracker_app/features/google_map/data/models/location_info/location_info.dart';
import 'package:route_tracker_app/features/google_map/data/models/routes_model/routes_model.dart';
import 'package:route_tracker_app/features/google_map/data/models/routes_modifiers.dart';

class RoutesService {
  final String baseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyD4PqvgXw20qL9OHeTnGB-vw-ySTvrQRzU';
  // final String apiKey = 'AIzaSyC87Tt3tfO6aYids0BZStXXbrdAy05jQCI'; // for testing with Instractor account

  Future<RoutesModel> fetchRoutes(
      {required LocationInfoModel origin,
      required LocationInfoModel destination,
      RoutesModifiers? routesModifiers}) async {
    Uri url = Uri.parse(baseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers":
          routesModifiers != null ? routesModifiers.toJson() : RoutesModifiers().toJson(),
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return RoutesModel.fromJson(data);
    } else {
      throw Exception('No routes found');
    }
  }
}
