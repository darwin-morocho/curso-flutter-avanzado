import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_maps/api/nominatim.dart';
import 'package:flutter_advanced_maps/api/osrm.dart';
import 'package:flutter_advanced_maps/models/reverse_result.dart';
import 'package:flutter_advanced_maps/models/search_result.dart';
import 'package:flutter_advanced_maps/models/service_location.dart';
import 'package:flutter_advanced_maps/pages/home/map_utils.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/my_center_position.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/request.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/toolbar.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/widget_as_marker.dart';
import 'package:flutter_advanced_maps/utils/dialogs.dart';
import 'package:flutter_advanced_maps/utils/geolocation_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum ReverseType { origin, destination }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _originKey = GlobalKey(), _destinationKey = GlobalKey();
  ServiceLocation _origin, _destination;
  Marker _originMarker = Marker(markerId: MarkerId("origin"));
  Marker _destinationMarker = Marker(markerId: MarkerId("destination"));

  Nominatim _nominatim = Nominatim();
  OSRM _osrm = OSRM();

  PanelController _panelController = PanelController();
  GoogleMapController _mapController;

  CameraPosition _initialCameraPosition;

  StreamSubscription<Position> _positionStream;
  Map<MarkerId, Marker> _markers = Map();
  Map<PolylineId, Polyline> _polylines = Map();
  Map<PolygonId, Polygon> _polygons = Map();

  var _isPanelOpen = false;
  Timer _idleTimer;

  LatLng _centerPosition, _myPosition;
  ReverseResult _reverseResult;
  ReverseType _reverseType = ReverseType.origin;
  dynamic _route;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _nominatim.onReverse = (ReverseResult result) async {
      setState(() {
        _reverseResult = result;
      });

      final serviceLocation =
          ServiceLocation(_centerPosition, result.displayName);

      if (_reverseType == ReverseType.origin) {
        _origin = serviceLocation;

        if (_destination == null) {
          _reverseType = ReverseType.destination;
        }
      } else {
        _destination = serviceLocation;
      }

      setState(() {});

      if (_origin != null && _destination != null) {
        _drawOriginAndDestinationMarkers();
        _osrm.route(_origin.position, _destination.position);
      }
    };

    _osrm.onRoute = _onRoute;
  }

  _drawOriginAndDestinationMarkers() {
    Timer(Duration(milliseconds: 500), () async {
      final originBytes = await MapUtils.widgetToBytes(_originKey);
      final destinationBytes = await MapUtils.widgetToBytes(_destinationKey);

      setState(() {
        _markers[_originMarker.markerId] = _originMarker.copyWith(
            positionParam: _origin.position,
            anchorParam: Offset(1,1.3),
            iconParam: BitmapDescriptor.fromBytes(originBytes),
            onTapParam: () => _onServiceMarkerPressed(ReverseType.origin));

        _markers[_destinationMarker.markerId] = _destinationMarker.copyWith(
            positionParam: _destination.position,
            anchorParam: Offset(0.3,1.3),
            iconParam: BitmapDescriptor.fromBytes(destinationBytes),
            onTapParam: () => _onServiceMarkerPressed(ReverseType.destination));
      });
    });
  }

  _onServiceMarkerPressed(ReverseType reverseType) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Confirmación Requerida"),
            content: Text(
                "desea cambiar el ${reverseType == ReverseType.origin ? "origen" : "destino"} del servicio"),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("NO"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  if (reverseType == ReverseType.origin) {
                    _origin = null;
                  } else {
                    _destination = null;
                  }
                  _reverseType = reverseType;

                  setState(() {});
                },
                child: Text("SI"),
              )
            ],
          );
        });
  }

  _onRoute(int status, dynamic data) {
    print("$status");

    if (status == 200) {
      final routes = data['routes'] as List;
      if (routes.length > 0) {
        this._route = routes[0];
        final encodedPolyline = routes[0]['geometry'] as String;
        List<LatLng> points =
            GeolocationUtils.decodeEncodedPolyline(encodedPolyline);

        final fitData = GeolocationUtils.fitToCoordinates(points);
        final center =
            LatLng(fitData['center']['lat'], fitData['center']['lng']);
        final zoom = fitData['zoom'] as double;

        _moveCamera(center, zoom: zoom);

        final polyline = Polyline(
            polylineId: PolylineId('route'),
            points: points,
            width: 5,
            color: Colors.cyan);

        setState(() {
          _polylines[polyline.polylineId] = polyline;
        });
      } else {
        Dialogs.showAlert(context,
            title: "ERROR", body: "No se encontro una ruta", onOk: () {
          _reset();
        });
      }
    } else {
      Dialogs.showAlert(context,
          title: status.toString(), body: data.toString(), onOk: () {
        _reset();
      });
    }
  }

  _reset() {
    _origin = null;
    _destination = null;
    _reverseType = ReverseType.origin;
    _markers.clear();
    _polylines.clear();
    _polygons.clear();
    _reverseResult = null;
    _route = null;

    setState(() {});
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

      _myPosition = myPosition;

      if (_initialCameraPosition == null) {
        setState(() {
          _initialCameraPosition = CameraPosition(target: myPosition, zoom: 14);
        });
      }
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    if (_positionStream != null) {
      _positionStream.cancel();
      _positionStream = null;
    }
    _osrm.dispose();
    _nominatim.dispose();

    super.dispose();
  }

  _moveCamera(LatLng position, {double zoom = 12}) {
    final cameraUpdate = CameraUpdate.newLatLngZoom(position, zoom);
    _mapController.animateCamera(cameraUpdate);
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

  _onCameraMoveStarted() {
    print("move started");
    setState(() {
      _reverseResult = null;
    });
  }

  _onCameraMove(CameraPosition cameraPosition) {
    print(
        "moving ${cameraPosition.target.latitude},${cameraPosition.target.longitude}");
    _centerPosition = cameraPosition.target;

    _idleTimer?.cancel();
    _idleTimer = Timer(Duration(milliseconds: 400), _onCameraIdle);
  }

  _onCameraIdle() {
    if (_origin == null || _destination == null) {
      _nominatim.reverse(_centerPosition);
    }
  }

  _onSearch(SearchResult result) {
    _moveCamera(result.position, zoom: 16);

    if (result.polygon.length > 0) {
      final polygonId = PolygonId(result.displayName);
      final polygon = Polygon(
          polygonId: polygonId,
          points: result.polygon,
          strokeWidth: 1,
          strokeColor: Colors.cyan,
          fillColor: Colors.cyan.withOpacity(0.2));

      setState(() {
        _polygons[polygon.polygonId] = polygon;
      });
    } else {
      print("no polygon");
    }
  }

  _onGoMyPosition() {
    if (_myPosition != null) {
      _moveCamera(_myPosition, zoom: 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final slidingUpPanelHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: _initialCameraPosition == null
            ? Center(
                child: CupertinoActivityIndicator(radius: 15),
              )
            : SafeArea(
                child: SlidingUpPanel(
                  controller: _panelController,
                  onPanelOpened: () {
                    setState(() {
                      _isPanelOpen = true;
                    });
                  },
                  onPanelClosed: () {
                    setState(() {
                      _isPanelOpen = false;
                    });
                  },
                  maxHeight: slidingUpPanelHeight,
                  backdropEnabled: true,
                  backdropOpacity: 0.1,
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: _initialCameraPosition,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            markers: Set.of(_markers.values),
                            polylines: Set.of(_polylines.values),
                            polygons: Set.of(_polygons.values),
                            onCameraMoveStarted: _onCameraMoveStarted,
                            onCameraMove: _onCameraMove,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                          ),
                          _origin == null || _destination == null
                              ? MyCenterPosition(
                                  reverseResult: _reverseResult,
                                  containerHeight: constraints.maxHeight,
                                )
                              : Container(),
                          WidgetAsMarker(
                            repaintKey: _originKey,
                            dotColor: Colors.green,
                            text: _origin != null ? _origin.address : '',
                          ),
                          WidgetAsMarker(
                            repaintKey: _destinationKey,
                            dotColor: Colors.redAccent,
                            text: _destination != null
                                ? _destination.address
                                : '',
                          ),
                        ],
                      );
                    },
                  ),
                  panel: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _route == null
                          ? _isPanelOpen
                              ? Toolbar(
                                  onSearch: _onSearch,
                                  onGoMyPosition: _onGoMyPosition,
                                  onClear: () {
                                    _panelController.close();
                                  },
                                  containerHeight: slidingUpPanelHeight,
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(15),
                                  child: CupertinoButton(
                                    onPressed: () {
                                      _panelController.open();
                                    },
                                    color: Color(0xfff0f0f0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "A donde quieres ir?",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 19,
                                              letterSpacing: 1),
                                        ),
                                        Icon(
                                          Icons.search,
                                          color: Colors.black54,
                                          size: 30,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                          : Request(
                              onReset: _reset,
                              onConfirm: () {},
                              route: _route,
                            )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
