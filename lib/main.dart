import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:geolocation/geolocation.dart';
import 'package:flutter/foundation.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController _mapController;
  // Position currentPosition;
  Set<Marker> _markers = {};
  String _activity = "";
  int counter = 1;
  

  LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
     setState(() {
      _mapController = controller;
    });
  }

  getLocation() async {
    final GeolocationResult resultPermission = await Geolocation.requestLocationPermission();

    if(resultPermission.isSuccessful) {
      final GeolocationResult resultOperational = await Geolocation.isLocationOperational();
      if(resultOperational.isSuccessful) {
        ActivityRecognition.activityUpdates().listen((event) {
          setState(() {
          _activity = event.type;
          debugPrint('Activity: ' + _activity);
          });
        });
        StreamSubscription<LocationResult> subscription = Geolocation.locationUpdates(
          accuracy: LocationAccuracy.best,
          displacementFilter: 0.0, // in meters
          inBackground: true,
          androidOptions: LocationOptionsAndroid(interval: 10000, fastestInterval: 10000) // by default, location updates will pause when app is inactive (in background). Set to `true` to continue updates in background.
        )
        .listen((result) {
          if(result.isSuccessful) {
            setState(() {
              _markers.add(Marker(
              markerId: MarkerId(counter.toString()),
              position: LatLng(result.location.latitude,
                  result.location.longitude),
              infoWindow: InfoWindow(
                  title: _activity,
                  snippet: counter.toString()
                  )));
              debugPrint('Marker: YESSS '+ _activity);
              _mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(result.location.latitude, result.location.longitude), zoom: 11.0),
                ),
              );
            });
          }
        });
        Timer(
            Duration(seconds: 300),
                () => subscription.cancel()
          );
        
      }
    }
  }

  Future<String> getUserActivity() async {
    ActivityRecognition.activityUpdates().listen((event) {
      setState(() {
      _activity = event.type;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _markers,
        ),
      ),
    );
  }
}