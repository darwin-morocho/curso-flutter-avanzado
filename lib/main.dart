import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/sign_up.dart';
import 'pages/home.dart';
import 'pages/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(),
      routes: {
        "login": (context) => LoginPage(),
        "singup": (context) => SingUpPage(),
        "home": (context) => HomePage(),
      },
    );
  }
}
