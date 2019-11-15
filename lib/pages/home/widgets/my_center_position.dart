import 'package:flutter/material.dart';
import 'package:flutter_advanced_maps/models/reverse_result.dart';
import 'package:flutter_advanced_maps/utils/responsive.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyCenterPosition extends StatelessWidget {
  final ReverseResult reverseResult;
  final double containerHeight;

  const MyCenterPosition({Key key, this.reverseResult, this.containerHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final height = responsive.ip(4.3);

    return Positioned(
      top: containerHeight / 2 - height - 15,
      left: 0,
      right: 0,
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: height,
            width: reverseResult == null ? height : 250,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: reverseResult != null
                  ? Text(
                reverseResult.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xff01579B),
                    fontSize: responsive.ip(1.4)),
              )
                  : SpinKitRotatingCircle(
                color: Color(0xff01579B),
                size: 20.0,
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 4,
            height: 15,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                )),
          )
        ],
      ),
    );
  }
}
