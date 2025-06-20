import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/core/utils/location_service.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late LocationService locationService;
  GoogleMapController? googleMapController;

  Set<Marker> markers = {};

  @override
  void initState() {
    initalCameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      zoomControlsEnabled: false,
      initialCameraPosition: initalCameraPosition,
      onMapCreated: (controller) {
        googleMapController = controller;
        updateCurrentLocation();
      },
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
