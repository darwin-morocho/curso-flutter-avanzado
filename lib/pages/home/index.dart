import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_maps/api/nominatim.dart';
import 'package:flutter_advanced_maps/api/osrm.dart';
import 'package:flutter_advanced_maps/models/reverse_result.dart';
import 'package:flutter_advanced_maps/models/search_result.dart';
import 'package:flutter_advanced_maps/models/service_location.dart';
import 'package:flutter_advanced_maps/pages/home/map_utils.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/my_center_position.dart';
import 'package:flutter_advanced_maps/pages/home/widgets/toolbar.dart';
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
        _markers[_originMarker.markerId] = _originMarker.copyWith(
            positionParam: _origin.position,
            onTapParam: () => _onServiceMarkerPressed(ReverseType.origin));
        if (_destination == null) {
          _reverseType = ReverseType.destination;
        }
      } else {
        _destination = serviceLocation;
        _markers[_destinationMarker.markerId] = _destinationMarker.copyWith(
            positionParam: _destination.position,
            onTapParam: () => _onServiceMarkerPressed(ReverseType.destination));
      }

      setState(() {});

      if (_origin != null && _destination != null) {
        _osrm.route(_origin.position, _destination.position);
      }
    };

    _osrm.onRoute = _onRoute;
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
      }
    }
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
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                              : Container()
                        ],
                      );
                    },
                  ),
                  panel: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _isPanelOpen
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class WidgetAsMarker extends StatelessWidget {
  final GlobalKey markerKey;
  final String text;
  final dotColor;

  const WidgetAsMarker(
      {Key key,
      @required this.markerKey,
      this.text = '',
      @required this.dotColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: 0,
      top: size.height,
      child: RepaintBoundary(
        key: markerKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.brightness_1,
                  size: 20,
                  color: dotColor,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(letterSpacing: 1, fontSize: 13),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
