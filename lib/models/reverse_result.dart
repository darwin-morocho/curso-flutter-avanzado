import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class ReverseResult {
  final LatLng position;
  final displayName, city, state, country, countryCode, postcode;

  ReverseResult(
      {this.position,
      this.displayName,
      this.city,
      this.state,
      this.country,
      this.countryCode,
      this.postcode});

  factory ReverseResult.fromJson(Map<String, dynamic> json) {
    final position =
        LatLng(double.parse(json['lat']), double.parse(json['lon']));

    return ReverseResult(
      position: position,
      displayName: json['display_name'],
      city: json['address']['city'],
      state: json['address']['state'],
      country: json['address']['country'],
      countryCode: json['address']['country_code'],
      postcode: json['address']['postcode'],
    );
  }
}
