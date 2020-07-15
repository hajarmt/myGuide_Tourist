
import 'dart:io';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wave_generator/wave_generator.dart';
import 'package:circle_wave_progress/circle_wave_progress.dart';
import 'package:flutter_plugin_qrcode/flutter_plugin_qrcode.dart';
import 'dart:async';
import 'package:url_audio_stream/url_audio_stream.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isplaying = false;
  @override
  void initState() {
    super.initState();
  }

  static String qrcode = "";
  static AudioStream stream = null;

  void _start() async {
    if(qrcode.isEmpty){
      getQrcodeState();
    }
    else{
      setState(() {
        _isplaying = true;
      });
      stream.start();
    }
  }
  void _stop() async {
    setState(() {
      _isplaying = false;
    });
    stream.stop();
  }

  Future<void> getQrcodeState() async {
    try {
      qrcode = await FlutterPluginQrcode.getQRCode;
    } on PlatformException {
      qrcode = '';
    }

    if (!mounted) return;
    setState(() {
      stream = new AudioStream(qrcode);
      _start();
      print(
          "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff" +
              qrcode.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
           title: Text("My Guide"),
            backgroundColor: Colors.cyanAccent,
            centerTitle: true,
            elevation: 0,
          ),
          body: Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  SizedBox(height: 50.0),
                  if(_isplaying && !qrcode.isEmpty)
                    CollectionScaleTransition(
                      children: <Widget>[
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                        Icon(Icons.adjust,size: 40,color: Colors.cyanAccent,),
                      ],
                    ),
                ],
              ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                  ),
                ],
    ),
    ),
          floatingActionButton: FloatingActionButton (
                 child:Icon(
                   _isplaying ?
                   Icons.volume_up : Icons.volume_off,
                   size: 50,
                   color: Colors.cyanAccent,
                 ),
                 onPressed :(){
                   if(_isplaying)
                     _stop();
                   else
                     _start();
                 },
            backgroundColor: Colors.white,
                  elevation: 50,

          ),
      ),
    );
  }


}
