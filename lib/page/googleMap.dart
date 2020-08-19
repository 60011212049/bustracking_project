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
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  LatLng _center = LatLng(16.245570, 103.250191);
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;
  BitmapDescriptor busstopIcon;
  BitmapDescriptor busPosIcon;
  BitmapDescriptor userIcon;
  List<Marker> markers = List<Marker>();
  List<BusstopModel> busstop = List<BusstopModel>();
  List<BusPositionModel> busPos = List<BusPositionModel>();
  Location location;
  bool checkWork = false;
  Timer timer;
  Set<Polyline> lines = {};
  bool checkSetSate = false;
  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    checkSetSate = true;
    super.dispose();
  }

  Future getDataBusstop() async {
    var status = {};
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busstop_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busstop = jsonData.map((i) => BusstopModel.fromJson(i)).toList();
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
    if (checkSetSate == false) {
      setState(() {
        for (int i = 0; i < busPos.length; i++) {
          markers.add(
            Marker(
              icon: busPosIcon,
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
    } else {}
  }

  void updatePinOnMap() async {
    // print('update map ' + timer.tick.toString());
    setState(() {
      double lat = 0, long = 0;
      for (int i = 0; i < busPos.length; i++) {
        long = double.parse(busPos[i].longitude);
        lat = double.parse(busPos[i].latitude);
        markers.removeWhere((m) => m.markerId.value == busPos[i].cid);
        markers.add(
          Marker(
            icon: busPosIcon,
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
    if (busstopIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor stopPin = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      BitmapDescriptor busPin = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/direct_bus.png');
      BitmapDescriptor userPin = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/place.png');
      await getDataBusstop();
      setState(
        () {
          busPosIcon = busPin;
          busstopIcon = stopPin;
          userIcon = userPin;
          for (int i = 0; i < busstop.length; i++) {
            markers.add(Marker(
              icon: busstopIcon,
              markerId: MarkerId('$i'),
              position: LatLng(double.parse(busstop[i].sLongitude),
                  double.parse(busstop[i].sLatitude)),
              infoWindow: InfoWindow(
                title: busstop[i].sName,
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
            icon: userIcon,
            markerId: MarkerId('me'),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
          ));
          setPolyLine();
          getDataPosition();
          timer = Timer.periodic(Duration(seconds: 1), (timer) {
            getDataPosition();
          });
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
      icon: userIcon,
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
          LatLng(16.249674, 103.246709),
          LatLng(16.249520, 103.246937),
          LatLng(16.249144, 103.247464),
          LatLng(16.248891, 103.247874),
          LatLng(16.248558, 103.248339),
          LatLng(16.248379, 103.248601),
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
          LatLng(16.248280, 103.250793),
          LatLng(16.248007, 103.250569),
          LatLng(16.247760, 103.250337),
          LatLng(16.247414, 103.250076),
          LatLng(16.247364, 103.250031),
          LatLng(16.247340, 103.249971),
          LatLng(16.247337, 103.249914),
          LatLng(16.247353, 103.249865),
          LatLng(16.247586, 103.249635),
          LatLng(16.247685, 103.249485),
          LatLng(16.247795, 103.249330),
          LatLng(16.247879, 103.249201),
          LatLng(16.247974, 103.249059),
          LatLng(16.248044, 103.248949),
          LatLng(16.248150, 103.248812),
          LatLng(16.248252, 103.248677),
          LatLng(16.248351, 103.248534),
          LatLng(16.248482, 103.248328),
          LatLng(16.248592, 103.248176),
          LatLng(16.248695, 103.248033),
          LatLng(16.248777, 103.247915),
          LatLng(16.248860, 103.247797),
          LatLng(16.248944, 103.247670),
          LatLng(16.249059, 103.247494),
          LatLng(16.249145, 103.247377),
          LatLng(16.249165, 103.247245),
          //ข้างสระ
          LatLng(16.249066, 103.247105),
          LatLng(16.248977, 103.247024),
          LatLng(16.248887, 103.246938),
          LatLng(16.248800, 103.246846),
          LatLng(16.248712, 103.246761),
          LatLng(16.248560, 103.246622),
          LatLng(16.248399, 103.246509),
          LatLng(16.248258, 103.246390),
          LatLng(16.248132, 103.246292),
          LatLng(16.247978, 103.246201),
          LatLng(16.247814, 103.246091),
          LatLng(16.247678, 103.246010),
          LatLng(16.247493, 103.245914),
          LatLng(16.247324, 103.245836),
          LatLng(16.247185, 103.245961),

          //หน้า RN ยาวจนกลับ
          LatLng(16.247089, 103.246105),
          LatLng(16.246995, 103.246229),
          LatLng(16.246883, 103.246394),
          LatLng(16.246783, 103.246545),
          LatLng(16.246657, 103.246722),
          LatLng(16.246520, 103.246891),
          LatLng(16.246396, 103.247064),
          LatLng(16.246286, 103.247223),
          LatLng(16.246189, 103.247379),
          LatLng(16.246064, 103.247568),
          LatLng(16.245912, 103.247737),
          LatLng(16.245804, 103.247917),
          LatLng(16.245706, 103.248099),
          LatLng(16.245604, 103.248296),
          LatLng(16.245495, 103.248509),
          LatLng(16.245394, 103.248710),
          LatLng(16.245286, 103.248897),
          LatLng(16.245150, 103.249085),
          LatLng(16.245026, 103.249266),
          LatLng(16.244871, 103.249498),
          LatLng(16.244709, 103.249713),
          LatLng(16.244541, 103.249930),
          LatLng(16.244417, 103.250127),
          LatLng(16.244252, 103.250360),
          LatLng(16.244084, 103.250600),
          LatLng(16.243905, 103.250855),
          LatLng(16.243760, 103.251066),
          LatLng(16.243567, 103.251347),
          LatLng(16.243388, 103.251571),
          LatLng(16.243231, 103.251811),
          LatLng(16.243080, 103.252017),
          LatLng(16.242963, 103.252162),
          LatLng(16.242829, 103.252353),
          LatLng(16.242851, 103.252539),
          LatLng(16.243015, 103.252673),
          //
          LatLng(16.243230, 103.252845),
          LatLng(16.243248, 103.253004),
          LatLng(16.243475, 103.253009),
          LatLng(16.243679, 103.252998),
          LatLng(16.243868, 103.252977),
          LatLng(16.244052, 103.252966),
          LatLng(16.244201, 103.252940),
          LatLng(16.244390, 103.252919),
          LatLng(16.244586, 103.252896),
          LatLng(16.244709, 103.252883),
          LatLng(16.244893, 103.252867),
          LatLng(16.245092, 103.252848),
          LatLng(16.245247, 103.252811),
          LatLng(16.245369, 103.252669),
          LatLng(16.245473, 103.252502),
          LatLng(16.245605, 103.252312),
          LatLng(16.245724, 103.252177),
          LatLng(16.245887, 103.252163),
          LatLng(16.246060, 103.252292),
          LatLng(16.246249, 103.252446),
          LatLng(16.246417, 103.252577),
          LatLng(16.246601, 103.252715),
          LatLng(16.246794, 103.252864),
          LatLng(16.246944, 103.252978),
          LatLng(16.247081, 103.253085),
          LatLng(16.247248, 103.253213),
          LatLng(16.247373, 103.253318),
          LatLng(16.247538, 103.253447),
          LatLng(16.247715, 103.253572),
          LatLng(16.247885, 103.253700),
          LatLng(16.248058, 103.253826),
          LatLng(16.248218, 103.253952),
          LatLng(16.248379, 103.254082),
          LatLng(16.248517, 103.254099),
          //
          LatLng(16.248651, 103.253996),
          LatLng(16.248796, 103.253876),
          LatLng(16.248952, 103.253722),
          LatLng(16.249118, 103.253548),
          LatLng(16.249248, 103.253369),
          LatLng(16.249370, 103.253226),
          LatLng(16.249505, 103.253004),
          LatLng(16.249617, 103.252824),
          LatLng(16.249726, 103.252613),
          LatLng(16.249824, 103.252381),
          LatLng(16.249888, 103.252224),
          LatLng(16.249959, 103.252029),
          LatLng(16.250054, 103.251803),
          LatLng(16.250125, 103.251548),
          LatLng(16.250199, 103.251204),
          LatLng(16.250234, 103.250922),
          LatLng(16.250265, 103.250552),
          LatLng(16.250273, 103.250255),
          LatLng(16.250261, 103.249903),
          LatLng(16.250225, 103.249575),
          LatLng(16.250165, 103.249218),
          LatLng(16.250079, 103.248947),
          LatLng(16.249943, 103.248573),
          LatLng(16.249856, 103.248362),
          LatLng(16.249737, 103.248081),
          LatLng(16.249630, 103.247911),
          LatLng(16.249492, 103.247639),
          LatLng(16.249325, 103.247452),
          LatLng(16.249245, 103.247299),
          LatLng(16.249378, 103.247124),
          LatLng(16.249563, 103.246869),
          LatLng(16.249703, 103.246661),
          LatLng(16.249850, 103.246492),
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
