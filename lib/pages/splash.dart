import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with WidgetsBindingObserver {
  PermissionHandler _permissionHandler = PermissionHandler();

  var _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if(state==AppLifecycleState.resumed){
      _check();
    }
  }



  _check() async {
    final status = await _permissionHandler
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
    if (status == PermissionStatus.granted) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  _request() async {
    final result = await _permissionHandler
        .requestPermissions([PermissionGroup.locationWhenInUse]);
    if (result.containsKey(PermissionGroup.locationWhenInUse)) {
      final status = result[PermissionGroup.locationWhenInUse];
      if (status ==
          PermissionStatus.granted) {
        Navigator.pushReplacementNamed(context, 'home');
      }else if(status==PermissionStatus.denied){
       final result= await _permissionHandler.openAppSettings();
       print("result $result");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: _isChecking
            ? Center(
                child: CupertinoActivityIndicator(radius: 15),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "MISSING PERMISSION",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        letterSpacing: 1),
                  ),
                  SizedBox(height: 10),
                  CupertinoButton(
                    onPressed: _request,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue,
                    child: Text("ALLOW"),
                  )
                ],
              ),
      ),
    );
  }
}
