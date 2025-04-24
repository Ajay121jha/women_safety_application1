import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class SafeRouteScreen extends StatefulWidget {
  @override
  _SafeRouteScreenState createState() => _SafeRouteScreenState();
}
 final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=AIzaSyBYcJfrlaPzs9YTI0XhGvDn9A5oaNQVB5M",
    );
class _SafeRouteScreenState extends State<SafeRouteScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  String _startLocation = "";
  String _endLocation = "";
  Set<Polyline> _polylines = {};

  // Dummy crime rate dataset (lat,lng => crime rate from 0.0 to 1.0)
  final Map<String, double> crimeRates = {
  "30.316,78.032": 0.4, // Dehradun
  "29.945,78.164": 0.6, // Haridwar
  "30.086,78.267": 0.3, // Rishikesh
  "29.391,79.454": 0.2, // Nainital
  "29.220,79.522": 0.5, // Haldwani
  "30.272,79.065": 0.1, // Chamoli
  "30.743,78.435": 0.2, // Uttarkashi
  "30.055,78.793": 0.7, // Pauri
  "29.592,78.558": 0.6, // Kotdwar
  "29.446,78.756": 0.3, // Roorkee
};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 15),
    ));
  }

  Future<void> _getDirections(String start, String end) async {
   

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["routes"].isNotEmpty) {
        _drawSafeRoute(data["routes"][0]["overview_polyline"]["points"]);
      }
    }
  }

  void _drawSafeRoute(String encodedPolyline) {
    List<LatLng> coords = _decodePolyline(encodedPolyline);

    // Adjust polyline color based on crime rate
    List<Polyline> weightedPolylines = [];
    for (int i = 0; i < coords.length - 1; i++) {
      double crimeScore = _getCrimeRateForSegment(coords[i]);
      Color color = _getColorBasedOnCrime(crimeScore);

      weightedPolylines.add(
        Polyline(
          polylineId: PolylineId('segment_$i'),
          points: [coords[i], coords[i + 1]],
          color: color,
          width: 6,
        ),
      );
    }

    setState(() {
      _polylines.clear();
      _polylines.addAll(weightedPolylines);
    });
  }

  double _getCrimeRateForSegment(LatLng coord) {
    String key = "${coord.latitude.toStringAsFixed(3)},${coord.longitude.toStringAsFixed(3)}";
    return crimeRates[key] ?? 0.0; // Default to safe if not in dataset
  }

  Color _getColorBasedOnCrime(double crimeRate) {
    if (crimeRate >= 0.7) return Colors.red;
    if (crimeRate >= 0.4) return Colors.orange;
    return Colors.green;
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Route Finder")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Enter Starting Location"),
                    onChanged: (value) => _startLocation = value,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Enter Destination"),
                    onChanged: (value) => _endLocation = value,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _getDirections(_startLocation, _endLocation);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentPosition!, zoom: 15),
                  ));
                }
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
