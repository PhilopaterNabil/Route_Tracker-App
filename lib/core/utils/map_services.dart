import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/core/utils/location_service.dart';
import 'package:route_tracker_app/core/utils/place_service.dart';
import 'package:route_tracker_app/core/utils/routes_service.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/lat_lng.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/location.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/location_info.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_details_model/place_details_model.dart';
import 'package:route_tracker_app/features/google_map/data/models/routes_model/routes_model.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();

  Future<void> getPredictions({
    required String input,
    required String sessionToken,
    required List<PlaceModel> places,
  }) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPedictions(input: input, sessionToken: sessionToken);

      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<List<LatLng>> getRouteData(
      {required LatLng currentLocation, required LatLng destinationLocation}) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );

    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destinationLocation.latitude,
          longitude: destinationLocation.longitude,
        ),
      ),
    );

    RoutesModel routes = await routesService.fetchRoutes(origin: origin, destination: destination);

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routes);

    return points;
  }

  List<LatLng> getDecodedRoute(PolylinePoints polylinePoints, RoutesModel routes) {
    List<PointLatLng> result =
        polylinePoints.decodePolyline(routes.routes!.first.polyline!.encodedPolyline!);

    List<LatLng> points = result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoute(List<LatLng> points,
      {required Set<Polyline> polylines, required GoogleMapController? googleMapController}) {
    Polyline route = Polyline(
      polylineId: PolylineId('route'),
      points: points,
      width: 5,
      color: Colors.blue,
    );

    polylines.add(route);

    LatLngBounds bounds = getLatlngBounds(points);
    googleMapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
  }

  LatLngBounds getLatlngBounds(List<LatLng> points) {
    double southwestLatitude = points.first.latitude;
    double southeastLongitude = points.first.longitude;
    double nourtEastLatitude = points.first.latitude;
    double northEastLongitude = points.first.longitude;

    for (LatLng point in points) {
      southwestLatitude = min(southwestLatitude, point.latitude);
      southeastLongitude = min(southeastLongitude, point.longitude);
      nourtEastLatitude = max(nourtEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southwestLatitude, southeastLongitude),
      northeast: LatLng(nourtEastLatitude, northEastLongitude),
    );
  }

  Future<LatLng> updateCurrentLocation(
      {required GoogleMapController? googleMapController, required Set<Marker> markers}) async {
    var locationData = await locationService.getLocation();

    var currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    Marker currentLocationMarker = Marker(
      markerId: MarkerId('my Location'),
      position: currentLocation,
      icon: BitmapDescriptor.defaultMarker,
    );
    CameraPosition myCurrentCameraPosition = CameraPosition(
      target: LatLng(locationData.latitude!, locationData.longitude!),
      zoom: 16,
    );
    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(myCurrentCameraPosition));
    markers.add(currentLocationMarker);

    return currentLocation;
  }

  Future<PlaceDetailsModel> getplaceDetails({required String placeId}) async {
    return await placesService.getplaceDetails(placeId: placeId);
  }
}
