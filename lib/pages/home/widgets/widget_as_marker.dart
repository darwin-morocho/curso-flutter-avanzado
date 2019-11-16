import 'package:flutter/material.dart';

class WidgetAsMarker extends StatelessWidget {
  final Color dotColor;
  final String text;
  final GlobalKey repaintKey;

  const WidgetAsMarker(
      {Key key,
      @required this.dotColor,
      @required this.text,
      @required this.repaintKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: 10,
      top: size.height,
      child: RepaintBoundary(
        key: repaintKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.brightness_1,
                color: dotColor,
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150),
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, letterSpacing: 1),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
