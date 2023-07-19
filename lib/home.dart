import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: _currentPosition != null
          ? GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(0,
                        0), // Use a default location if current position is null
                zoom: 14.0,
              ),
              markers: _markers,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, handle accordingly
      return;
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Location permission is denied, request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permission is still denied, handle accordingly
        return;
      }
    }

    // Handle permanently denied location permission
    if (permission == LocationPermission.deniedForever) {
      // Location permission is permanently denied, handle accordingly
      return;
    }

    // Fetch the current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _addMarker(position.latitude, position.longitude);
    });

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ),
    );
  }

  void _addMarker(double latitude, double longitude) {
    final marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: LatLng(latitude, longitude),
    );
    setState(() {
      _markers.add(marker);
    });
  }
}
