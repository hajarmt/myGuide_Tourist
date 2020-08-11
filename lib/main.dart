import 'package:flutter/material.dart';
import './pages/splashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'My Guide : Tourist';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Raleway'),
      home: SplashScreen(),
    );
  }
}
