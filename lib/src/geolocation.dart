import 'package:flutter/services.dart';
import '../utils/geolocation_utils.dart';

class GeolocationPermissionStatus {
  static const granted = "GRANTED";
  static const denied = "DENIED";
  static const unknown = "UNKNOWN";
}

typedef void OnGpsEnabled(bool isEnabled);
typedef void OnLocationUpdate(Coord location);

class Geolocation {
  final _channel = MethodChannel('ec.dina/geolocation');
  OnGpsEnabled onGpsEnabled;
  OnLocationUpdate onLocationUpdate;

  Geolocation() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onLocation":
          // print("call.arguments ${call.arguments.toString()}");
          if (onLocationUpdate != null) {
            onLocationUpdate(
                Coord(call.arguments['lat'], call.arguments['lng']));
          }
          break;
        case "onGpsEnabled":
          final bool isEnabled = call.arguments;
          if (onGpsEnabled != null) {
            onGpsEnabled(isEnabled);
          }
          break;
      }
    });
  }

  Future<String> requestPermission() async {
    print("calling requestPermission");
    final result = await _channel.invokeMethod("permission");
    print("requestPermission status: $result");
    return result;
  }

  startTracking() async {
    await _channel.invokeMethod("startTracking");
  }

  stopTracking() async {
    await _channel.invokeMethod("stopTracking");
  }
}