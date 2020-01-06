import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gelocation_tracking/flutter_gelocation_tracking.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _geolocation = Geolocation();

  Coord _lastLocation;
  DateTime _lastTime;
  int _speed = 0, _counter = 0;
  var _isTracking = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      _checkPermissions();
    });
    _geolocation.onGpsEnabled = (bool isEnabled) {
      print("gpsEnabled: $isEnabled");
      if (isEnabled) {
        _geolocation.startTracking();
      }
    };

    _geolocation.onLocationUpdate = this._onLocationUpdate;
  }

  _onLocationUpdate(Coord location) {
    if (_lastLocation != null && _counter >= 2) {
      // d = v*t => v=d/t => v = dx/dt
      final dx = GeolocationUtils.getDistanceInKM(_lastLocation, location);
      final dt = DateTime.now().difference(_lastTime).inMilliseconds /
          (1000 * 60 * 60);
      setState(() {
        _speed = dx ~/ dt;
      });
    }
    _counter++;

    _lastTime = DateTime.now();
    _lastLocation = location;
  }

  @override
  void dispose() {
    _geolocation.stopTracking();
    super.dispose();
  }

  _checkPermissions() async {
    final status = await _geolocation.requestPermission();

    switch (status) {
      case GeolocationPermissionStatus.granted:
        _geolocation.startTracking();
        setState(() {
          _isTracking = true;
        });

        break;
      case GeolocationPermissionStatus.denied:
        break;
      case GeolocationPermissionStatus.unknown:
        break;
    }
  }

  _onPressed() {
    if (_isTracking) {
      _geolocation.stopTracking();
      _counter = 0;
    } else {
      _geolocation.startTracking();
    }
    setState(() {
      _isTracking = !_isTracking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_speed.toString(),
                style: TextStyle(fontSize: 40, color: Colors.black)),
            Text("km/h", style: TextStyle(fontSize: 20, color: Colors.black)),
            SizedBox(height: 20),
            CupertinoButton(
              onPressed: _onPressed,
              color: _isTracking ? Colors.red : Colors.green,
              child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            )
          ],
        ),
      ),
    );
  }
}
