import 'package:flutter/material.dart';
import 'package:MyGuide_Tourist/presentation/MyFlutterApp.dart';
import './LiveLocationPage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_qrcode/flutter_plugin_qrcode.dart';
import 'dart:async';
import 'package:url_audio_stream/url_audio_stream.dart';


void main() =>  runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  routes: {
    '/' : (cont) => HomeScreen(),
    '/location' : (cont) => LiveLocationPage(),
  },
));


BuildContext get cont => null;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  final String title;
  HomeScreen({Key key, this.title}) : super(key: key);

}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    imageCache.clear();
    return Scaffold(
        bottomNavigationBar: BottomNavCustom(),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            )
        )
    );
  }
}


class BottomNavCustom extends StatefulWidget {
  @override
  _BottomNavCustomState createState() => _BottomNavCustomState();
}

class _BottomNavCustomState extends State<BottomNavCustom> {
  int selectedIndex = 0;
  Color backgroundColorNav = Colors.white;

  List<NavigationItem> items = [
    NavigationItem(Icon(MyFlutterApp.qr_scanner), Text('QR code Scanner'),  Color(0xff5732C4)),
    NavigationItem(Icon(Icons.volume_off), Text('Turn volume off'), Color(0xff062695)),
    NavigationItem(Icon(MyFlutterApp.search_location), Text('Locate the guide'), Color(0xff029BD8))
  ];


  Widget _buildItem(NavigationItem item, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 240),
      height: 50,
      width: isSelected ? 170 : 50,
      padding: isSelected ? EdgeInsets.only(left: 16, right: 16) : null,
      decoration: isSelected
          ? BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.all(Radius.circular(50)))
          : null,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconTheme(
                data: IconThemeData(
                  size: 24,
                  color: isSelected ? backgroundColorNav : Colors.black,
                ),
                child: item.icon,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: isSelected
                    ? DefaultTextStyle.merge(
                    style: TextStyle(color: backgroundColorNav),
                    child: item.title)
                    : Container(),
              )
            ],
          ),
        ],
      ),
    );
  }
  static bool _isplaying = false;

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
      print("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff" + qrcode.toString());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.only(left: 30, top: 4, bottom: 4, right: 30),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          var itemIndex = items.indexOf(item);
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = itemIndex;
              });
              if(selectedIndex == 0){
                print(selectedIndex);
                getQrcodeState();
              }else if(selectedIndex == 1){
                if('Text("Turn volume on")' == items[selectedIndex].title.toString() && _isplaying){
                  items.removeAt(selectedIndex);
                  items.insert(selectedIndex, NavigationItem(Icon(Icons.volume_off), Text('Turn volume off'), Color(0xff062695)));
                  _stop();
                } else {
                  items.removeAt(selectedIndex);
                  items.insert(selectedIndex, NavigationItem(Icon(Icons.volume_up), Text('Turn volume on'), Color(0xff3A4BD6)));
                  _start();
                }
              }else if(selectedIndex == 2){
                print(selectedIndex);
                Navigator.pushNamed(cont,"/location");
              }
            },
            child: _buildItem(item, selectedIndex == itemIndex),
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final Icon icon;
  final Text title;
  final Color color;

  NavigationItem(this.icon, this.title, this.color);
}
