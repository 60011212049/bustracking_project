import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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
  BitmapDescriptor sourceIcon;
  List<Marker> markers = List<Marker>();
  List<BusstopModel> bus = HomePage.busstop;
  List<BusPositionModel> busPos = List<BusPositionModel>();
  Location location;
  bool checkWork = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    getDataPosition();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      getDataPosition();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> getDataPosition() async {
    var status = {};
    status['status'] = 'show';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busposition_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busPos = jsonData.map((i) => BusPositionModel.fromJson(i)).toList();
    setState(() {
      for (int i = 0; i < busPos.length; i++) {
        markers.add(
          Marker(
            icon: sourceIcon,
            markerId: MarkerId(busPos[i].cid),
            position: (busPos[i].longitude == '' || busPos[i].latitude == '')
                ? LatLng(16.251632, 103.248659)
                : LatLng(double.parse(busPos[i].latitude),
                    double.parse(busPos[i].longitude)),
            infoWindow: InfoWindow(
              title: busPos[i].cid,
            ),
          ),
        );
      }
      updatePinOnMap();
    });
  }

  void updatePinOnMap() async {
    print('update map');
    setState(() {
      double lat = 0, long = 0;
      for (int i = 0; i < busPos.length; i++) {
        long = double.parse(busPos[i].longitude);
        lat = double.parse(busPos[i].latitude);
        markers.removeWhere((m) => m.markerId.value == busPos[i].cid);
        markers.add(
          Marker(
            icon: sourceIcon,
            markerId: MarkerId(busPos[i].cid),
            position: (busPos[i].longitude == '' || busPos[i].latitude == '')
                ? LatLng(16.251632, 103.248659)
                : LatLng(double.parse(busPos[i].latitude),
                    double.parse(busPos[i].longitude)),
            infoWindow: InfoWindow(
              title: busPos[i].cid,
            ),
          ),
        );
      }
    });
  }

  //  Set new icon
  Future _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bmpd = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      BitmapDescriptor souIcon = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/direct_bus.png');
      setState(() {
        sourceIcon = souIcon;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GoogleMap(
          myLocationEnabled: true,
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
