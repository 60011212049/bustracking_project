import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AssessmentFormPage extends StatefulWidget {
  @override
  _AssessmentFormPageState createState() => _AssessmentFormPageState();
}

class _AssessmentFormPageState extends State<AssessmentFormPage> {
  Set<Polyline> lines = {};

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(16.245570, 103.250191), zoom: 17);

  @override
  void initState() {
    super.initState();
    lines.add(
      Polyline(
        points: [
          LatLng(16.249208, 103.247260),
          LatLng(16.249135, 103.247371),
          LatLng(16.249066, 103.247469),
          LatLng(16.248732, 103.247924),
        ],
        endCap: Cap.squareCap,
        geodesic: false,
        polylineId: PolylineId("line_one"),
        color: Colors.red,
        width: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: lines,
      ),
    );
  }
}
