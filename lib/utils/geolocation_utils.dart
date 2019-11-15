import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;


class GeolocationUtils {
  ///decode the google encoded string using Encoded Polyline Algorithm Format
  /// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  ///return [List]
  static List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      final coord = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(coord);
    }
    return poly;
  }

  /// calculates the center of one array of coords
  static LatLng averageGeolocation(List<LatLng> coords) {
    if (coords.length == 1) {
      return coords[0];
    }

    var x = 0.0, y = 0.0, z = 0.0;

    for (var coord in coords) {
      final latitude = coord.latitude * math.pi / 180;
      final longitude = coord.longitude * math.pi / 180;

      x += math.cos(latitude) * math.cos(longitude);
      y += math.cos(latitude) * math.sin(longitude);
      z += math.sin(latitude);
    }

    final total = coords.length;

    x = x / total;
    y = y / total;
    z = z / total;

    final centralLongitude = math.atan2(y, x);
    final centralSquareRoot = math.sqrt(x * x + y * y);
    final centralLatitude = math.atan2(z, centralSquareRoot);

    return LatLng(
        centralLatitude * 180 / math.pi, centralLongitude * 180 / math.pi);
  }

  /// parse degrees to radians
  static double deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  /// calculates the distance between two coords in km
  static double getDistanceInKM(LatLng position1, LatLng position2) {
    final lat1 = position1.latitude;
    final lon1 = position1.longitude;
    final lat2 = position2.latitude;
    final lon2 = position2.longitude;

    final R = 6371; // Radius of the earth in km
    final dLat = deg2rad(lat2 - lat1); // deg2rad below
    final dLon = deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final d = R * c; // Distance in km

    return d;
  }

  ///
  static dynamic fitToCoordinates(List<LatLng> coords) {
    final centerMap = averageGeolocation(coords);

    final linearDistance =
        getDistanceInKM(coords[0], coords[coords.length - 1]);

    double radius = linearDistance / 2;
    double scale = radius / 0.3;
    final zoom = (16 - math.log(scale) / math.log(2));

    return {
      'center': {'lat': centerMap.latitude, 'lng': centerMap.longitude},
      'zoom': zoom
    };
  }
}
