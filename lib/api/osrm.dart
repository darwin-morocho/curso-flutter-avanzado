import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

typedef OnRoute(int statusCode, dynamic data);

class OSRM {
  StreamSubscription _routeSub;
  OnRoute onRoute;

  route(LatLng origin, LatLng destination) {
    try {
      final url =
          "http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}";
      print(url);

      _routeSub?.cancel();

      _routeSub = http.get(url).asStream().listen((http.Response response) {
        if (onRoute != null) {
          if (response.statusCode == 200) {
            onRoute(200, jsonDecode(response.body));
          } else {
            onRoute(response.statusCode, response.body);
          }
        }
      });
    } catch (e) {}
  }

  dispose() {
    _routeSub?.cancel();
  }
}
