import 'package:flutter/material.dart';
import 'pages/splash.dart';
import 'pages/home/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        'home': (_) => HomePage(),
      },
    );
  }
}
