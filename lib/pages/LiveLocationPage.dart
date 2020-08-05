import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class LiveLocationPage extends StatefulWidget {
  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  LocationData _currentLocation;
  MapController _mapController;
  LatLng guide_position;
  bool _liveUpdate = true;
  bool _permission = false;

  String _serviceError = '';
  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initLocationService();
    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk1");
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.HIGH,
      interval: 1000,
    );
    LocationData location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        var permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.GRANTED;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService
              .onLocationChanged()
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;

                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                      LatLng(_currentLocation.latitude,
                          _currentLocation.longitude),
                      _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk8");
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk9");
        _serviceError = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;
    LatLng guideLatLng;
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation.latitude, _currentLocation.longitude);
    } else {
      currentLatLng = LatLng(0, 0);
    }
    var markers = <Marker>[
      Marker(
        width: 100.0,
        height: 100.0,
        point: currentLatLng,
        builder: (ctx) => Container(
          child: Icon(
            Icons.directions_walk,
            color: Color(0xff25c4db),
            size: 50,
          ),
        ),
      ),
      Marker(
        width: 100.0,
        height: 100.0,
        point: guide_position,
        builder: (ctx) => Container(
          child: Icon(
            Icons.location_on,
            color: Color(0xff25c4db),
            size: 40,
          ),
        ),
      ),
    ];
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'Location',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      //drawer: buildDrawer(context, route),
      body: StreamBuilder(
          stream: Firestore.instance.collection("guides").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("exist");
              if (snapshot.data.documents[0]['lastLocation']['latitude'] !=
                      null &&
                  snapshot.data.documents[0]['lastLocation']['longitude'] !=
                      null)
                guide_position = new LatLng(
                    snapshot.data.documents[0]['lastLocation']['latitude'],
                    snapshot.data.documents[0]['lastLocation']['longitude']);
            } else {
              guide_position = new LatLng(31, -8);
              print("null");
              print(snapshot.data);
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: _serviceError.isEmpty
                      ? Text('your current position'
                          '(${currentLatLng.latitude}, ${currentLatLng.longitude}).')
                      : Text('Error occured while acquiring location: '),
                ),
                Flexible(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(
                          currentLatLng.latitude, currentLatLng.longitude),
                      zoom: 16,
                    ),
                    layers: [
                      new TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']),
                      MarkerLayerOptions(markers: markers)
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
