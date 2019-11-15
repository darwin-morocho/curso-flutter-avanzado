import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class SearchResult {
  final LatLng position;
  final String displayName;
  final List<LatLng> polygon;

  SearchResult({this.position, this.displayName, this.polygon});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final position =
        LatLng(double.parse(json['lat']), double.parse(json['lon']));

    List<LatLng> polygon = List();
    if (json['geojson']['type'] == 'Polygon') {
      polygon = ((json['geojson']['coordinates'] as List)[0] as List)
          .map((item) => LatLng(item[1], item[0]))
          .toList();
    }

    return SearchResult(
        position: position,
        displayName: json['display_name'],
        polygon: polygon);
  }
}
