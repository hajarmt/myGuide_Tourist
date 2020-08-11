import 'package:MyGuide_Tourist/presentation/MyFlutterApp.dart';
import 'package:flutter_plugin_qrcode/flutter_plugin_qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_audio_stream/url_audio_stream.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './LiveLocationPage.dart';
import 'dart:async';


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
            builder: (context) => HomeScreen()
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;
  @override
  _HomeScreenState createState() => _HomeScreenState();
  HomeScreen({Key key, this.title}) : super(key: key);
}

class KeysToBeInherited extends InheritedWidget {
  final GlobalKey volumeKey;
  final GlobalKey qRCodeKey;
  final GlobalKey locationKey;

  KeysToBeInherited({
    this.volumeKey,
    this.qRCodeKey,
    this.locationKey,
    Widget child,
  }) : super(child: child);

  static KeysToBeInherited of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(KeysToBeInherited);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey _qRCodeKey = GlobalKey();
  GlobalKey _volumeKey = GlobalKey();
  GlobalKey _locationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    imageCache.clear();
    SharedPreferences preferences;

    displayShowcase() async {
      preferences = await SharedPreferences.getInstance();
      bool showcaseVisibilityStatus = preferences.getBool("showShowcase");

      if (showcaseVisibilityStatus == null) {
        preferences.setBool("showShowcase", false).then((bool success) {
          if (success)
            print("Successfull in writing showshowcaase");
          else
            print("some bloody problem occured");
        });
        return true;
      }
      return false;
    }

    displayShowcase().then((status) {
      if (status) {
        ShowCaseWidget.of(context).startShowCase([
          _qRCodeKey,
          _volumeKey,
          _locationKey
        ]);
      }
    });

    return KeysToBeInherited(
        qRCodeKey: _qRCodeKey,
        volumeKey: _volumeKey,
        locationKey: _locationKey,
        child: Scaffold(
          //backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("My Guide : Tourist",
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            //elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          bottomNavigationBar: BottomNavCustom(),
          body: Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(
                "assets/images/background.png",
                fit: BoxFit.cover,
              )
          ),
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
  bool _isplaying = false;

  static String qrcode = "";
  static AudioStream stream = null;

  List<NavigationItem> items = [
    NavigationItem(Icon(MyFlutterApp.qr_scanner), Text('Scan QR code'),  Color(0xff5732C4)),
    NavigationItem(Icon(Icons.volume_off), Text('Turn on volume'), Color(0xff062695)),
    NavigationItem(Icon(MyFlutterApp.search_location), Text('Locate the guide'), Color(0xff029BD8))
  ];

  void _start() async {
    if(qrcode.isEmpty){
      getQRCodeState();
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

  Future<void> getQRCodeState() async {
    try {
      qrcode = await FlutterPluginQrcode.getQRCode;
    } on PlatformException {
      qrcode = '';
    }
    if (!mounted) return;
    setState(() {
      stream = new AudioStream(qrcode);
    });
  }

  gotoLiveLocationActivity(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LiveLocationPage()),
    );
  }

  Widget _buildItem(NavigationItem item, bool isSelected) {
    return  AnimatedContainer(
      duration: Duration(milliseconds: 240),
      height: 50,
      width: isSelected ? 170 : 50,
      padding: isSelected ? EdgeInsets.only(left: 16, right: 16) : null,
      decoration: isSelected
          ? BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.all(Radius.circular(50)))
          : null,
      child:  ListView(
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

  @override
  Widget build(BuildContext context) {
    String desc = "";
    GlobalKey key;

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

          if('Text("Turn on volume")' == item.title.toString()){
            desc = "Click here to turn on/off volume";
            key = KeysToBeInherited.of(context).volumeKey;
          }else if('Text("Scan QR code")' == item.title.toString()){
            desc = "Click here to scan the QR code of your guide";
            key = KeysToBeInherited.of(context).qRCodeKey;
          }else if('Text("Locate the guide")' == item.title.toString()){
            desc = "Click here to locate your guide";
            key = KeysToBeInherited.of(context).locationKey;
          }
          return  Showcase(
              key: key,
              description: desc,
              showcaseBackgroundColor: Colors.lightBlue[100],
              descTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = itemIndex;
                  });

                  if(selectedIndex == 0){
                    print(selectedIndex);
                    getQRCodeState();
                  }else if(selectedIndex == 1){
                    if('Text("Turn off volume")' == item.title.toString() && _isplaying){
                      items[1].setIconText(Icon(Icons.volume_off), Text('Turn up volume'));
                      _stop();
                    } else {
                      items[1].setIconText(Icon(Icons.volume_up), Text('Turn off volume'));
                      _start();
                    }
                  }else if(selectedIndex == 2){
                    print(selectedIndex);
                    gotoLiveLocationActivity(context);
                  }
                },
                child:_buildItem(item, selectedIndex == itemIndex),
              )
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  Icon icon;
  Text title;
  final Color color;

  NavigationItem(this.icon, this.title, this.color);

  setIconText(Icon icon, Text title){
    this.title = title;
    this.icon = icon;
  }
}
