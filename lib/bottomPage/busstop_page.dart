import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/route_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/network.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusStopPage extends StatefulWidget {
  @override
  _BusStopPageState createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  List<BusstopModel> bus = HomePage.busstop;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: bus.length,
            itemBuilder: (BuildContext buildContext, int index) {
              return ListTile(
                title: Text(bus[index].sName, style: TextStyle(fontSize: 22)),
                leading: CircleAvatar(
                  backgroundColor: Colors.yellow[700],
                  radius: 22,
                  child: Text(bus[index].sid),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Detail(bus, index),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}

// ignore: must_be_immutable
class Detail extends StatefulWidget {
  List<BusstopModel> bus = List<BusstopModel>();
  int index;
  Detail(bus, index) {
    this.bus = bus;
    this.index = index;
    print(index);
  }
  @override
  DetailState createState() => DetailState(bus, index);
}

class DetailState extends State<Detail> {
  var status = {};
  List<BusstopModel> busstop = List<BusstopModel>();
  List<RouteApi> route = List<RouteApi>();
  bool _isLoading = false;
  int id;
  List<double> listDura = List<double>();
  List<BusPositionModel> busPos = List<BusPositionModel>();

  DetailState(List<BusstopModel> bus, int index) {
    this.busstop = bus;
    this.id = index;
    print(busstop[0].sLatitude + ' ; ' + busstop[0].sLongitude);
  }
  @override
  void initState() {
    super.initState();
    getDataPosition();
  }

  Future<Null> getDataPosition() async {
    var status = {};
    status['status'] = 'show';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busposition_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busPos = jsonData.map((i) => BusPositionModel.fromJson(i)).toList();
    for (var i = 0; i < busPos.length; i++) {
      var result = await getJsonData(busPos[i].latitude, busPos[i].longitude,
          busstop[id].sLongitude, busstop[id].sLatitude, i);
    }
    print('list :: ' + listDura.toString());
    setState(() {
      _isLoading = true;
    });
  }

  Future<double> getJsonData(
      String lat1, String long1, String lat2, String long2, int i) async {
    NetworkHelper network = NetworkHelper(
      startLat: double.parse(lat1),
      startLng: double.parse(long1),
      endLat: double.parse(lat2),
      endLng: double.parse(long2),
    );

    try {
      var data = await network.getData(busstop, id, busPos, i);
      print(data['routes'][0]['summary']);
      listDura.add(
          double.parse(data['routes'][0]['summary']['duration'].toString()) /
              60);
      if (listDura.length == busPos.length) {
        setState(() {});
      }
      return data['routes'][0]['summary']['duration'];
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จุดจอดรถ'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Center(
                            child: Image.asset(
                              'asset/backgrounds/msu_pic.JPG',
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          busstop[id].sName,
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              _isLoading == true
                  ? Wrap(
                      children: <Widget>[
                        DataTable(
                          sortAscending: true,
                          sortColumnIndex: 0,
                          columns: [
                            DataColumn(
                              label: textColumn('รถราง'),
                            ),
                            DataColumn(label: textColumn('เวลาโดยประมาณ')),
                          ],
                          rows: busPos
                              .map((data) => DataRow(
                                    cells: [
                                      DataCell(textRow(data.cid)),
                                      listDura.length == busPos.length
                                          ? DataCell(
                                              textRow(listDura[
                                                          int.parse(data.pid) -
                                                              1]
                                                      .toInt()
                                                      .toString() +
                                                  ' นาที'),
                                            )
                                          : DataCell(textRow('')),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ],
                    )
                  : Container(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Text('กำลังข้อมูล..'),
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ],
      ),
    );
  }

  Text textRow(data) {
    return Text(
      data,
      style: TextStyle(
        fontSize: 15,
        fontFamily: 'Quark',
      ),
    );
  }

  Text textColumn(String data) {
    return Text(
      data,
      style: TextStyle(
        fontSize: 19,
        fontFamily: 'Quark',
        color: Color(0xFF3a3a3a),
      ),
    );
  }
}
