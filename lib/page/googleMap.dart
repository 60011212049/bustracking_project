import 'dart:async';
import 'package:bustracking_project/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  LatLng _center = LatLng(16.245570, 103.250191);
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;
  BitmapDescriptor _markerIcon;

  //  Set new icon
  Future _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bmpd = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      setState(() {
        _markerIcon = bmpd;
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
          markers: {
            addMarker(
                1, 'จุดจอดรถหลังหอในหญิงวาปีปทุม', '16.251141', '103.248427'),
            addMarker(
                2, 'จุดจอดรถข้างหอในหญิงบรบือ', '16.250817', '103.247967'),
            addMarker(3, 'จุดจอดรถหลังพลาซ่า', '16.250503', '103.247541'),
            addMarker(
                4, 'จุดจอดรถข้างหอในชายเชียงยืน', '16.250243', '103.247031'),
            addMarker(5, 'จุดจอดรถตรงข้ามคณะบัญชี', '16.248827', '103.247917'),
            addMarker(6, 'จุดจอดรถหน้าคณะวิทยาศาสตร์ตึก 2', '16.248245',
                '103.250757'),
            addMarker(7, 'จุดจอดรถหน้าคณะวิทยาศาสตร์ตึก 1', '16.247671',
                '103.250325'),
            addMarker(8, 'จุดจอดรถหน้าคณะสถาปัตยกรรมศาสตร์', '16.247542',
                '103.249492'),
            addMarker(9, 'จุดจอดรถหน้าคณะบัญชี', '16.248582', '103.248006'),
            addMarker(10, 'จุดจอดรถข้างคณะบัญชี ตรงข้ามอาคารพละ', '16.248999',
                '103.246995'),
            addMarker(11, 'จุดจอดรถตึก RN ตรงข้ามอาคารพละ', '16.247420',
                '103.245828'),
            addMarker(
                12, 'จุดจอดรถหน้าคณะนิติศาสตร์', '16.246386', '103.247082'),
            addMarker(
                13, 'จุดจอดรถหน้าคณะมนุษยศาสตร์', '16.245935', '103.247804'),
            addMarker(
                14, 'จุดจอดรถหน้าคณะวิลัยการเมือง', '16.245070', '103.249303'),
            addMarker(
                15, 'จุดจอดรถหน้าคณะสิ่งแวดล้อม', '16.243316', '103.251687'),
            addMarker(16, 'จุดจอดรถหน้าคณะพยาบาล', '16.245438', '103.252435'),
            addMarker(17, 'จุดจอดรถหน้าคณะวิศวะ', '16.246772', '103.252752'),
            addMarker(
                18, 'จุดจอดรถหน้าคณะสาธารณสุข', '16.248023', '103.253691'),
            addMarker(19, 'จุดจอดรถตรงข้ามตลาดน้อย', '16.250214', '103.250589'),
            addMarker(20, 'จุดจอดรถตรงข้ามเซเว่นพลาซ่า(หอใน)', '16.249833',
                '103.248341'),
          },
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

  Marker addMarker(id, name, x, y) {
    return Marker(
      icon: _markerIcon,
      markerId: MarkerId(id.toString()),
      position: LatLng(double.parse(x), double.parse(y)),
      infoWindow: InfoWindow(
        title: name,
      ),
    );
  }
}
