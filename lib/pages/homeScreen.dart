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
    print('started app');
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
    return context.dependOnInheritedWidgetOfExactType();
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

extension ListUpdate<T> on List {
  List update(int pos, T t) {
    List<T> list = new List();
    list.add(t);
    replaceRange(pos, pos+1, list);
    print("list update" + t.toString() );
    print("list updated" + this[pos].toString() );
    return this;
  }
}

class _BottomNavCustomState extends State<BottomNavCustom> {
  int selectedIndex = 0;
  Color backgroundColorNav = Colors.white;
  bool _isPlaying = false;

  static String qrcode;
  static AudioStream stream;

  List items = [
    NavigationItem(Icon(MyFlutterApp.qr_scanner), Text('Scan QR code'), Color(0xff5732C4)),
    NavigationItem(Icon(Icons.volume_off), Text('Turn on volume'), Color(0xff062695)),
    NavigationItem(Icon(MyFlutterApp.search_location), Text('Locate the guide'),Color(0xff029BD8))];


  void _start() async {
    if(qrcode.isEmpty){
      getQRCodeState();
    }
    else{
      setState(() {
        _isPlaying = true;
      });
      items.update(1, new NavigationItem(Icon(Icons.volume_up), Text('Turn off volume'), Color(0xff3A4BD6)));
      print("volume turned on the volume");
      stream.start();
    }
  }

  void _stop() async {
    print("volume turned off the volume");
    setState(() {
      _isPlaying = false;
    });
    items.update(1, new NavigationItem(Icon(Icons.volume_off), Text('Turn on volume'), Color(0xff062695)));
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
    print(item.toString());
    print(isSelected);
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
    return Container(
      height: 56,
      padding: EdgeInsets.only(left: 30, top: 4, bottom: 4, right: 30),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Showcase>[
          Showcase(
              description: "Click here to scan the QR code of your guide",
              key: KeysToBeInherited.of(context).qRCodeKey,
              showcaseBackgroundColor: Color(0xffC7E6F1),
              descTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              overlayColor: Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                  print(selectedIndex);
                  getQRCodeState();
                },
                child:_buildItem(items[0], selectedIndex == 0),
              )
          ),
          Showcase(
              key : KeysToBeInherited.of(context).volumeKey,
              description : "Click here to turn on or off volume,\nit is turned off by default",
              showcaseBackgroundColor: Color(0xffC7E6F1),
              descTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              overlayColor: Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                  print(selectedIndex);
                  if(_isPlaying) _stop();else _start();
                },
                child:_buildItem(items[1], selectedIndex == 1),
              )
          ),
          Showcase(
              description: "Click here to locate your guide",
              key: KeysToBeInherited.of(context).locationKey,
              showcaseBackgroundColor: Color(0xffC7E6F1),
              descTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              overlayColor: Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                  gotoLiveLocationActivity(context);

                },
                child:_buildItem(items[2], selectedIndex == 2),
              )
          )
        ].toList()
      ),
    );
  }
}

class NavigationItem {
  Icon icon;
  Text title;
  Color color;

  NavigationItem(this.icon, this.title, this.color);
}
