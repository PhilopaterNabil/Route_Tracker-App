import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/core/utils/google_maps_place_service.dart';
import 'package:route_tracker_app/core/utils/location_service.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/features/google_map/presentation/views/widgets/custom_list_view.dart';
import 'package:route_tracker_app/features/google_map/presentation/views/widgets/custom_text_field.dart';

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

  Set<Marker> markers = {};
  List<PlaceModel> places = [];

  @override
  void initState() {
    googleMapsPlacesService = GoogleMapsPlacesService();
    textEditingController = TextEditingController();
    initalCameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPedictions(input: textEditingController.text);
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
                  CustomListView(places: places),
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

      LatLng currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: MarkerId('my Location'),
        position: currentPosition,
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
}

// create text field
// Listen to text field
// search place and show on map
// display results location on map
