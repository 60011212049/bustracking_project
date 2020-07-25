import 'dart:io';

import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper({this.startLng, this.startLat, this.endLng, this.endLat});

  String url = 'https://api.openrouteservice.org/v2/directions/';
  String apiKey = '5b3ce3597851110001cf624866aa9f3bf2e44721a476d06be0c6550f';
  String journeyMode =
      'driving-car'; // Change it if you want or make it variable
  double startLng;
  double startLat;
  double endLng;
  double endLat;

  Future getData(List<BusstopModel> busstop, int id,
      List<BusPositionModel> busPos, int idPos) async {
    String str = '';
    bool check = false;
    bool ched = false;
    double lat2, lon2;
    print('object : ' + idPos.toString());
    for (var i = 0; i >= 0; i++) {
      lat2 = double.parse(busstop[i].sLongitude);
      lon2 = double.parse(busstop[i].sLatitude);
      if ((lat2 > startLat - 0.0005 && lat2 < startLat + 0.0005) &&
          (lon2 > startLng - 0.0005 && lon2 < startLng + 0.0005) &&
          ched == false) {
        // print('check !! Start ...........');
        // print(lat2.toString() + ',' + lon2.toString());
        // print(startLat.toString() + ',' + startLng.toString());
        check = true;
        ched = true;
      }

      if (check == true &&
          ((lat2 > endLat - 0.0005 && lat2 < endLat + 0.0005) &&
              (lon2 > endLng - 0.0005 && lon2 < endLng + 0.0005))) {
        // print('End .........');
        // print(lat2.toString() + ',' + lon2.toString());
        // print(endLat.toString() + ',' + endLng.toString());
        // print('break');
        break;
      }
      if (check == true) {
        str = str +
            '[' +
            busstop[i].sLatitude +
            ',' +
            busstop[i].sLongitude +
            '],';
      }
      if (i == busstop.length - 1) {
        i = 0;
      }
    }
    // check = false;

    // for (var i = 0; i < busstop.length; i++) {
    //   //print(i.toString() + ' : ' + id.toString());
    //   // if (i == id) {
    //   //   break;
    //   // }
    //   str =
    //       str + '[' + busstop[i].sLatitude + ',' + busstop[i].sLongitude + '],';
    // }
    String jsonSt =
        '{"coordinates":[[$startLng,$startLat],$str[$endLng,$endLat]]}';
    // '{"coordinates":[[$startLng,$startLat],[103.246851,16.246536],[103.247516,16.250286],[103.246497,16.249822],[103.247495,16.249122],[103.248825,16.248215],[103.250391,16.248524],[103.250037,16.247278],[103.245864,16.247082],[103.249018,16.245074],[103.251443,16.243405],[103.252923,16.244136],[103.25214,16.246032],[103.253578,16.24768],[103.252269,16.249709],[103.249276,16.249997],[103.246894,16.249431],[103.247795,16.250811],[$endLng,$endLat]]}';
    print(jsonSt);
    http.Response response = await http.post(
        'https://api.openrouteservice.org/v2/directions/driving-hgv',
        body: jsonSt,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: apiKey
        });
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode.toString() + ' is status');
    }
  }
}
