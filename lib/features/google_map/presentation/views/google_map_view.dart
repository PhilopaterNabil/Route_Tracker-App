import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/core/utils/google_maps_place_service.dart';
import 'package:route_tracker_app/core/utils/location_service.dart';
import 'package:route_tracker_app/core/utils/routes_service.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/lat_lng.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/location.dart';
import 'package:route_tracker_app/features/google_map/data/models/location_info/location_info.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart';
import 'package:route_tracker_app/features/google_map/data/models/routes_model/routes_model.dart';
import 'package:route_tracker_app/features/google_map/presentation/views/widgets/custom_list_view.dart';
import 'package:route_tracker_app/features/google_map/presentation/views/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late GoogleMapsPlacesService googleMapsPlacesService;
  late LocationService locationService;
  late TextEditingController textEditingController;
  GoogleMapController? googleMapController;

  String? sessionToken;
  late Uuid uuid;
  Set<Marker> markers = {};
  late RoutesService routesService;
  List<PlaceModel> places = [];
  Set<Polyline> polylines = {};

  late LatLng currentLocation, destinationLocation;

  @override
  void initState() {
    uuid = Uuid();
    googleMapsPlacesService = GoogleMapsPlacesService();
    textEditingController = TextEditingController();
    initalCameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    routesService = RoutesService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPedictions(
            input: textEditingController.text, sessionToken: sessionToken!);
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: markers,
              polylines: polylines,
              zoomControlsEnabled: false,
              initialCameraPosition: initalCameraPosition,
              onMapCreated: (controller) {
                googleMapController = controller;
                updateCurrentLocation();
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  CustomTextField(textEditingController: textEditingController),
                  SizedBox(height: 16),
                  CustomListView(
                    places: places,
                    googleMapsPlacesService: googleMapsPlacesService,
                    onPlaceSelect: (placeDetails) async {
                      textEditingController.clear();
                      places.clear();

                      sessionToken = null;
                      setState(() {});
                      destinationLocation = LatLng(
                        placeDetails.geometry!.location!.lat!,
                        placeDetails.geometry!.location!.lng!,
                      );
                      var points = await getRouteData();
                      displayRoute(points);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();

      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
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
      setState(() {});
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO:
    } catch (e) {
      // TODO:
    }
  }

  Future<List<LatLng>> getRouteData() async {
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

  void displayRoute(List<LatLng> points) {
    Polyline route = Polyline(
      polylineId: PolylineId('route'),
      points: points,
      width: 5,
      color: Colors.blue,
    );

    polylines.add(route);
    setState(() {});
  }
}

// create text field
// Listen to text field
// search place and show on map
// display results location on map
