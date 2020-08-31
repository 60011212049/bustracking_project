import 'dart:io';

import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper({this.startLng, this.startLat, this.endLng, this.endLat});

  String url = 'https://api.openrouteservice.org/v2/directions/';
  String apiKey = '5b3ce3597851110001cf624866aa9f3bf2e44721a476d06be0c6550f';
  String journeyMode =
      'driving-hgv'; // Change it if you want or make it variable
  double startLng;
  double startLat;
  double endLng;
  double endLat;

  Future getData(List<BusstopModel> busstop, int id,
      List<BusPositionModel> busPos, int idPos) async {
    bool check = false;
    double lat2, lon2;
    String str = '';
    print('object : $idPos');
    // print('Start is true $idPos >> ' +
    //     startLat.toString() +
    //     ' ' +
    //     startLng.toString() +
    //     ' ' +
    //     lat2.toString() +
    //     ' ' +
    //     lon2.toString());
    // print('End is true $idPos >> ' +
    //     endLat.toString() +
    //     ' ' +
    //     endLng.toString() +
    //     ' ' +
    //     lat2.toString() +
    //     ' ' +
    //     lon2.toString());
    for (var i = 0; i <= 19;) {
      lat2 = double.parse(busstop[i].sLongitude);
      lon2 = double.parse(busstop[i].sLatitude);
      if ((lat2 == startLat && lon2 == startLng) && check == false) {
        check = true;
        i++;
        continue;
      }
      if (check == true && (lat2 == endLat && lon2 == endLng)) {
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
        continue;
      }
      i++;
    }

    String jsonSt =
        '{"coordinates":[[$startLng,$startLat],$str[$endLng,$endLat]]}';
    // '{"coordinates":[[$startLng,$startLat],[103.246851,16.246536],[103.247516,16.250286],[103.246497,16.249822],[103.247495,16.249122],[103.248825,16.248215],[103.250391,16.248524],[103.250037,16.247278],[103.245864,16.247082],[103.249018,16.245074],[103.251443,16.243405],[103.252923,16.244136],[103.25214,16.246032],[103.253578,16.24768],[103.252269,16.249709],[103.249276,16.249997],[103.246894,16.249431],[103.247795,16.250811],[$endLng,$endLat]]}';
    print(jsonSt);
    http.Response response = await http.post(
        'https://api.openrouteservice.org/v2/directions/driving-car',
        body: jsonSt,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: apiKey
        });
    if (response.statusCode == 200) {
      print(response.body);
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode.toString() + ' is status');
    }
  }

  Future getDataStartStop(
      String latStart, String lngStart, String latStop, String lngStop) async {
    http.Response response = await http.get(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf624866aa9f3bf2e44721a476d06be0c6550f&start=$lngStart,$latStart&end=$lngStop,$latStop',
    );
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode.toString() + ' is status');
    }
  }
}
