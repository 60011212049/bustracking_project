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
  BitmapDescriptor userIc;
  List<Marker> markers = List<Marker>();
  List<BusstopModel> bus = HomePage.busstop;
  List<BusPositionModel> busPos = List<BusPositionModel>();
  Location location;
  bool checkWork = false;
  Timer timer;
  Set<Polyline> lines = {};
  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    getDataPosition();
    setPolyLine();
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
    currentLocation = await getCurrentLocation();
    if (_markerIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bmpd = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      BitmapDescriptor souIcon = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/direct_bus.png');
      BitmapDescriptor userIcon = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/place.png');
      setState(
        () {
          sourceIcon = souIcon;
          _markerIcon = bmpd;
          userIc = userIcon;
          for (int i = 0; i < bus.length; i++) {
            markers.add(Marker(
              icon: _markerIcon,
              markerId: MarkerId('$i'),
              position: LatLng(double.parse(bus[i].sLongitude),
                  double.parse(bus[i].sLatitude)),
              infoWindow: InfoWindow(
                title: bus[i].sName,
                onTap: () {
                  showDialog(
                    context: context,
                    child: new SimpleDialog(
                      title: new Text('กรุณาเลือกรถราง'),
                    ),
                  );
                },
              ),
            ));
          }
          markers.add(Marker(
            icon: userIc,
            markerId: MarkerId('me'),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
          ));
        },
      );
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
    markers.removeWhere((m) => m.markerId.value == 'me');
    markers.add(Marker(
      icon: userIc,
      markerId: MarkerId('me'),
      position: LatLng(currentLocation.latitude, currentLocation.longitude),
    ));
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 17,
    )));
    setState(() {});
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
          polylines: lines,
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

  void setPolyLine() {
    lines.add(
      Polyline(
        points: [
          LatLng(16.251545, 103.248768),
          LatLng(16.251204, 103.248528),
          LatLng(16.250864, 103.248294),
          LatLng(16.251017, 103.248072),
          LatLng(16.250758, 103.247852),
          LatLng(16.250720, 103.247808),
          LatLng(16.250696, 103.247749),
          LatLng(16.250680, 103.247663),
          LatLng(16.250635, 103.247599),
          LatLng(16.250349, 103.247365),
          LatLng(16.250494, 103.247142),
          LatLng(16.250246, 103.246958),
          LatLng(16.250214, 103.246932),
          LatLng(16.250186, 103.246889),
          LatLng(16.250165, 103.246805),
          LatLng(16.250159, 103.246697),
          LatLng(16.250139, 103.246652),
          LatLng(16.250113, 103.246626),
          LatLng(16.249836, 103.246403),
          LatLng(16.249313, 103.247127),
          LatLng(16.249221, 103.247261),
          LatLng(16.248183, 103.248720),
          LatLng(16.248292, 103.248841),
          LatLng(16.248378, 103.248960),
          LatLng(16.248461, 103.249108),
          LatLng(16.248532, 103.249277),
          LatLng(16.248585, 103.249459),
          LatLng(16.248618, 103.249636),
          LatLng(16.248633, 103.249818),
          LatLng(16.248635, 103.250009),
          LatLng(16.248623, 103.250267),
          LatLng(16.248613, 103.250388),
          LatLng(16.248585, 103.250579),
          LatLng(16.248544, 103.250699),
          LatLng(16.248460, 103.250862),
          LatLng(16.247414, 103.250076),
          LatLng(16.247364, 103.250031),
          LatLng(16.247340, 103.249971),
          LatLng(16.247337, 103.249914),
          LatLng(16.247353, 103.249865),
          LatLng(16.248155, 103.248720),

          /**โซนหน้าบัญชี */
          LatLng(16.249218, 103.247207),
          LatLng(16.248973, 103.246899),
          LatLng(16.248661, 103.246582),
          LatLng(16.248338, 103.246313),
          LatLng(16.248046, 103.246114),
          LatLng(16.247782, 103.245944),
          LatLng(16.247292, 103.245699),
          LatLng(16.246448, 103.246864),
          LatLng(16.246368, 103.246986),
          LatLng(16.246049, 103.247550),
          LatLng(16.245997, 103.247606),
          LatLng(16.245695, 103.248085),
          /**โซนหน้ามนุษ */
          LatLng(16.245278, 103.248880),
          LatLng(16.244055, 103.250593),
          LatLng(16.244515, 103.249962),
          LatLng(16.244049, 103.250616),
          LatLng(16.243241, 103.251709),
          LatLng(16.242853, 103.252254),
          LatLng(16.242829, 103.252305),
          LatLng(16.242833, 103.252373),
          LatLng(16.242879, 103.252435),
          LatLng(16.243250, 103.252800),
          /**โซน ไอที วิศวะ */
          LatLng(16.243253, 103.252842),
          LatLng(16.243219, 103.252927),
          LatLng(16.243516, 103.252920),
          LatLng(16.243867, 103.252898),
          LatLng(16.244858, 103.252762),
          LatLng(16.245049, 103.252747),
          LatLng(16.245167, 103.252746),
          LatLng(16.245227, 103.252755),
          LatLng(16.245277, 103.252691),
          LatLng(16.245606, 103.252384),
          LatLng(16.245703, 103.252254),
          LatLng(16.245750, 103.252203),
          LatLng(16.245809, 103.252176),
          LatLng(16.245868, 103.252172),
          LatLng(16.245932, 103.252202),
          LatLng(16.246919, 103.252972),
          LatLng(16.247480, 103.253405),
          LatLng(16.248396, 103.254092),
          LatLng(16.248470, 103.254119),
          /**โซน เส้นรอบนอกตลาดน้อย */
          LatLng(16.248735, 103.253866),
          LatLng(16.249040, 103.253549),
          LatLng(16.249307, 103.253230),
          LatLng(16.249561, 103.252834),
          LatLng(16.249741, 103.252507),
          LatLng(16.250012, 103.251842),
          LatLng(16.250136, 103.251426),
          LatLng(16.250211, 103.251060),
          LatLng(16.250261, 103.250660),
          LatLng(16.250259, 103.250100),
          LatLng(16.250237, 103.249631),
          LatLng(16.250171, 103.249225),
          LatLng(16.250069, 103.248809),
          LatLng(16.249898, 103.248338),
          LatLng(16.249581, 103.247710),
          LatLng(16.249408, 103.247432),
          LatLng(16.249232, 103.247197),
          /**โซน กลับหอใน */
          LatLng(16.249308, 103.247105),
          LatLng(16.249833, 103.246377),
          LatLng(16.250146, 103.246634),
          LatLng(16.250176, 103.246690),
          LatLng(16.250178, 103.246796),
          LatLng(16.250209, 103.246898),
          LatLng(16.250238, 103.246927),
          LatLng(16.250521, 103.247132),
          LatLng(16.250372, 103.247361),
          LatLng(16.250647, 103.247591),
          LatLng(16.250698, 103.247660),
          LatLng(16.250708, 103.247728),
          LatLng(16.250731, 103.247795),
          LatLng(16.250763, 103.247837),
          LatLng(16.251046, 103.248067),
          LatLng(16.250887, 103.248281),
          LatLng(16.251209, 103.248511),
          LatLng(16.251541, 103.248699),
        ],
        endCap: Cap.squareCap,
        geodesic: false,
        polylineId: PolylineId("line_one"),
        color: Colors.green,
        width: 3,
      ),
    );
  }
}
