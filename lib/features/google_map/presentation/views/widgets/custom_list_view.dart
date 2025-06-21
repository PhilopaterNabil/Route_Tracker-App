import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker_app/features/google_map/data/models/place_autocomplete_model/place_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({super.key, required this.places});

  final List<PlaceModel> places;

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
            onPressed: () {},
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
