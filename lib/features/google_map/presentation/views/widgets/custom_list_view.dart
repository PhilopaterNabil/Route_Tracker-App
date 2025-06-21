import 'package:flutter/material.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({super.key, required this.places});

  final List<PlaceModel> places;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) => Text(places[index].description!),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: places.length,
    );
  }
}