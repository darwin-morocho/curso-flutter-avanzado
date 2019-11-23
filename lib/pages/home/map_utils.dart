import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

const mapStyle = [
  {
    "elementType": "geometry",
    "stylers": [
      {"color": "#1d2c4d"}
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#8ec3b9"}
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#1a3646"}
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#4b6878"}
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#64779e"}
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#4b6878"}
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#334e87"}
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {"color": "#023e58"}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {"color": "#283d6a"}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#6f9ba5"}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#1d2c4d"}
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {"color": "#023e58"}
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#3C7680"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"color": "#304a7d"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#98a5be"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#1d2c4d"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {"color": "#2c6675"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {"color": "#255763"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#b0d5ce"}
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#023e58"}
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#98a5be"}
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#1d2c4d"}
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {"color": "#283d6a"}
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {"color": "#3a4762"}
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {"color": "#0e1626"}
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#4e6d70"}
    ]
  }
];

class MapUtils {
  static Future<Uint8List> loadPinFromAsset(String path, {width = 100}) async {
    final byteData = await rootBundle.load(path);
    var bytes = byteData.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    bytes = (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();

    return bytes;
  }

  static Future<Uint8List> widgetToBytes(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    final image = await boundary.toImage(pixelRatio: 2.3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  static Future<Uint8List> customMarkerToBytes(
      Color dotColor, String label) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final MyCustomMarker customMarker = MyCustomMarker(dotColor, label);
    customMarker.paint(canvas, Size(500, 120));

    final ui.Image image = await recorder.endRecording().toImage(500, 120);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }
}

class MyCustomMarker extends CustomPainter {
  final Color dotColor;
  final String label;

  MyCustomMarker(this.dotColor, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(20));

    canvas.drawRRect(rRect, paint);

    paint.color = dotColor;
    canvas.drawCircle(Offset(40, size.height / 2), 20, paint);

    final textPainter = TextPainter(
        text: TextSpan(
            text: this.label,
            style: TextStyle(color: Colors.black, fontSize: 20)),
        textDirection: TextDirection.ltr,
        maxLines: 2);

    textPainter.layout(minWidth: 0, maxWidth: size.width - 80);

    textPainter.paint(
        canvas, Offset(80, size.height / 2 - textPainter.size.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
