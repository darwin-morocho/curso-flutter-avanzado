import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/me.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Me _me;

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      User newUser = User(
          id: "asgasgasgasg",
          email: "saassa@kksakas.com",
          username: "tatata",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      _me.data = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    _me = Me.of(context);
    return Scaffold(
      body: Center(
        child: Text(_me.data.toJson().toString()),
      ),
    );
  }
}
