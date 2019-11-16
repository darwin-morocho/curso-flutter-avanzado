import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../api/auth_api.dart';
import '../api/profile_api.dart';
import '../models/user.dart';
import '../providers/me.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _authAPI = AuthAPI();
  final _profileAPI = ProfileAPI();

  Me _me;

  @override
  void initState() {
    super.initState();

    this.check();
  }

  check() async {
    final token = await _authAPI.getAccessToken();

    if (token != null) {

      final FirebaseUser firebaseUser = (await _auth.signInAnonymously()).user;
      assert(firebaseUser != null);
      assert(firebaseUser.isAnonymous);


      print("firebase Auth OK");


      final result = await _profileAPI.getUserInfo(context, token);

      final user = User.fromJson(result);

      print("id: ${user.id}");
      print("email: ${user.email}");

      print("user json: ${user.toJson()}");

      _me.data = user;

      Navigator.pushReplacementNamed(context, "home");
    } else {
      Navigator.pushReplacementNamed(context, "login");
    }
  }

  @override
  Widget build(BuildContext context) {
    _me = Me.of(context);

    return Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(
          radius: 15,
        ),
      ),
    );
  }
}
