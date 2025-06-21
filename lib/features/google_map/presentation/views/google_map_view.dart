import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/core/utils/location_service.dart';
import 'package:route_tracker_app/core/utils/map_services.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart';
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
  late MapServices mapServices;
  late TextEditingController textEditingController;
  GoogleMapController? googleMapController;

  String? sessionToken;
  late Uuid uuid;
  Set<Marker> markers = {};
  List<PlaceModel> places = [];
  Set<Polyline> polylines = {};

  late LatLng destinationLocation;

  Timer? debounce;

  @override
  void initState() {
    uuid = Uuid();
    textEditingController = TextEditingController();
    initalCameraPosition = CameraPosition(target: LatLng(0, 0));
    mapServices = MapServices();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (debounce?.isActive ?? false) debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 100), () async {
        sessionToken ??= uuid.v4();
        await mapServices.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
          places: places,
        );
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    googleMapController?.dispose();
    debounce?.cancel();
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
                    mapsServices: mapServices,
                    onPlaceSelect: (placeDetails) async {
                      textEditingController.clear();
                      places.clear();

                      sessionToken = null;
                      setState(() {});
                      destinationLocation = LatLng(
                        placeDetails.geometry!.location!.lat!,
                        placeDetails.geometry!.location!.lng!,
                      );

                      var points = await mapServices.getRouteData(
                        destinationLocation: destinationLocation,
                      );

                      mapServices.displayRoute(
                        points,
                        polylines: polylines,
                        googleMapController: googleMapController,
                      );
                      setState(() {});
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
      mapServices.updateCurrentLocation(
        onUpdateCurrentLocation: (){
          setState(() {});
        },
        googleMapController: googleMapController,
        markers: markers,
      );
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO:
    } catch (e) {
      // TODO:
    }
  }
}
