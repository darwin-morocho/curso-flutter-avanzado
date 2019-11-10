import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'map_utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController _mapController;
  Uint8List _carPin;
  Marker _myMarker;

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  StreamSubscription<Position> _positionStream;
  Map<MarkerId, Marker> _markers = Map();
  Map<PolylineId, Polyline> _polylines = Map();

  List<LatLng> _myRoute = List();

  Position _lastPosition;

  @override
  void initState() {
    super.initState();
    _loadCarPin();
  }

  _loadCarPin() async {
    _carPin =
        await MapUtils.loadPinFromAsset('assets/icons/car-pin.png', width: 60);
    _startTracking();
  }

  _startTracking() {
    final geolocator = Geolocator();
    final locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 5);

    _positionStream =
        geolocator.getPositionStream(locationOptions).listen(_onLocationUpdate);
  }

  _onLocationUpdate(Position position) {
    if (position != null) {
      final myPosition = LatLng(position.latitude, position.longitude);
      _myRoute.add(myPosition);

      final myPolyline = Polyline(
          polylineId: PolylineId("me"),
          points: _myRoute,
          color: Colors.cyanAccent,
          width: 8);

      if (_myMarker == null) {
        final markerId = MarkerId("me");
        final bitmap = BitmapDescriptor.fromBytes(_carPin);
        _myMarker = Marker(
            markerId: markerId,
            position: myPosition,
            icon: bitmap,
            rotation: 0,
            anchor: Offset(0.5, 0.5));
      } else {
        final rotation = _getMyBearing(_lastPosition, position);
        _myMarker = _myMarker.copyWith(
            positionParam: myPosition, rotationParam: rotation);
      }

      setState(() {
        _markers[_myMarker.markerId] = _myMarker;
        _polylines[myPolyline.polylineId] = myPolyline;
      });
      _lastPosition = position;
      _move(position);
    }
  }

  double _getMyBearing(Position lastPosition, Position currentPosition) {
    final dx = math.cos(math.pi / 180 * lastPosition.latitude) *
        (currentPosition.longitude - lastPosition.longitude);
    final dy = currentPosition.latitude - lastPosition.latitude;
    final angle = math.atan2(dy, dx);
    return 90 - angle * 180 / math.pi;
  }

  @override
  void dispose() {
    if (_positionStream != null) {
      _positionStream.cancel();
      _positionStream = null;
    }
    super.dispose();
  }

  _move(Position position) {
    final cameraUpdate =
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude));
    _mapController.animateCamera(cameraUpdate);
  }

  _updateMarkerPosition(MarkerId markerId, LatLng p) {
    print("newPosition");
    _markers[markerId] = _markers[markerId].copyWith(positionParam: p);
  }

  _onMarkerTap(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Click"),
            content: Text("marker id $id"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  _onTap(LatLng p) {
    final id = "${_markers.length}";
    final markerId = MarkerId(id);

    final marker = Marker(
        markerId: markerId,
        position: p,
        draggable: true,
        onTap: () => _onMarkerTap(id),
        onDragEnd: (np) => _updateMarkerPosition(markerId, np));
    setState(() {
      _markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              markers: Set.of(_markers.values),
              polylines: Set.of(_polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _mapController.setMapStyle(jsonEncode(mapStyle));
              },
            )
          ],
        ),
      ),
    );
  }
}
