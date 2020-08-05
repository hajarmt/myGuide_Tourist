import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:MyGuide_Tourist/pages/homeScreen.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();

    _navigateToHome();
  }



  void _navigateToHome()async{
    await Future.delayed(Duration(milliseconds: 50), () {});
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen()
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/load.png',
              height: 350,
              width: 350,
            ),
            Shimmer.fromColors(
              period: Duration(milliseconds: 1500),
              baseColor: Color(0xff514a9d),
              highlightColor: Color(0xff25c4db),
              child: Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Touriste application",
                  style: TextStyle(
                      fontSize: 28.0,
                      fontFamily: 'Pacifico'
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}