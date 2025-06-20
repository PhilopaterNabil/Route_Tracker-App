import 'package:flutter/material.dart';
import 'package:route_tracker_app/features/google_map/presentation/views/google_map_view.dart';

class RouteTrackerApp extends StatelessWidget {
  const RouteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Route Tracker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GoogleMapView(),
    );
  }
}