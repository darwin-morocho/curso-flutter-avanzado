import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'pages/sign_up.dart';
import 'pages/home.dart';
import 'pages/splash.dart';
import 'providers/me.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_)=>Me(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashPage(),
        routes: {
          "splash": (context) => SplashPage(),
          "login": (context) => LoginPage(),
          "singup": (context) => SingUpPage(),
          "home": (context) => HomePage(),
        },
      ),
    );
  }
}
