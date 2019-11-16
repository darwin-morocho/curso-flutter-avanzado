import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Request extends StatelessWidget {
  final dynamic route;
  final VoidCallback onReset, onConfirm;

  const Request(
      {Key key,
      @required this.route,
      @required this.onReset,
      @required this.onConfirm})
      : super(key: key);

  int _getDurationInMinutes() {
    final seconds = double.parse(route['duration'].toString());
    return (seconds/60).floor();
  }

  int _getDistanceInKm() {
    final meters = double.parse(route['distance'].toString());
    return (meters/1000).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.directions_car, size: 40),
              SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${_getDurationInMinutes()} min"),
                  Text("${_getDistanceInKm()} km"),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              CupertinoButton(
                onPressed: onReset,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                minSize: 30,
                color: Colors.redAccent,
                child: Text("Cancelar"),
                borderRadius: BorderRadius.circular(30),
              ),
              SizedBox(
                width: 5,
              ),
              CupertinoButton(
                onPressed: onConfirm,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                minSize: 30,
                color: Colors.blue,
                child: Text("Confirmar"),
                borderRadius: BorderRadius.circular(30),
              )
            ],
          )
        ],
      ),
    );
  }
}
