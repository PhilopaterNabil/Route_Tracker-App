import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker_app/core/utils/map_services.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_details_model/place_details_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.mapsServices,
    required this.onPlaceSelect,
  });

  final List<PlaceModel> places;
  final MapServices mapsServices;
  final void Function(PlaceDetailsModel) onPlaceSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(FontAwesomeIcons.mapPin),
          title: Text(places[index].description!),
          trailing: IconButton(
            onPressed: () async {
              var placeDetails =
                  await mapsServices.getplaceDetails(placeId: places[index].placeId!);
              onPlaceSelect(placeDetails);
            },
            icon: const Icon(Icons.arrow_circle_right_outlined),
          ),
        ),
        separatorBuilder: (context, index) => const Divider(
          height: 0,
        ),
        itemCount: places.length,
      ),
    );
  }
}
