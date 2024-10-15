import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WebViewExample extends StatelessWidget {
  final String accessToken =
      'pk.eyJ1Ijoic3VwZXJpb3J3ZWF0aGVyIiwiYSI6ImNtMjNucWx1dDA3bHUycXBzOTFkbnI2dTAifQ.zVW_x1ostoIHrprzrFPEzg'; // Replace with your Mapbox token

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(51.5, -0.09), // Initial center of the map
          initialZoom: 13.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$accessToken",
            subdomains: ['a', 'b', 'c'],
            // You can use different Mapbox styles, like "mapbox/streets-v11"
            fallbackUrl: 'mapbox/streets-v11',
            tileSize: 256,
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(51.5, -0.09), // Marker position
                child: Container(
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
