import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class ServiceLocation {
  final LatLng position;
  final String address;

  ServiceLocation(this.position, this.address);
}
