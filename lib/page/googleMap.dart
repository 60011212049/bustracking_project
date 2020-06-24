import 'dart:async';
import 'dart:convert';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  static List<Marker> markers = List<Marker>();
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  LatLng _center = LatLng(16.245570, 103.250191);
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;
  BitmapDescriptor _markerIcon;
  List<Marker> markers = <Marker>[];
  List<BusstopModel> bus = HomePage.busstop;

  //  Set new icon
  Future _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bmpd = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      setState(() {
        _markerIcon = bmpd;
        for (int i = 0; i < bus.length; i++) {
          markers.add(Marker(
            icon: _markerIcon,
            markerId: MarkerId('$i'),
            position: LatLng(double.parse(bus[i].sLongitude),
                double.parse(bus[i].sLatitude)),
            infoWindow: InfoWindow(
              title: bus[i].sName,
            ),
          ));
        }
      });
    }
  }

  //  Set location now
  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // Permission denied
      }
      return null;
    }
  }

  Future _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 16,
    )));
  }

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          markers: Set<Marker>.of(markers),
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.5,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: FloatingActionButton(
          onPressed: _goToMe,
          child: Icon(Icons.accessibility_new),
        ),
      ),
    );
  }
}
