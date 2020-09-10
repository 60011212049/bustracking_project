import 'dart:convert';
import 'dart:io';

import 'package:bustracking_project/bottomPage/busstop_page.dart';
import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/dution_model.dart';
import 'package:bustracking_project/model/route_model.dart';
import 'package:bustracking_project/service/network.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class DetailBus extends StatefulWidget {
  List<BusstopModel> busstop = List<BusstopModel>();
  int index;

  DetailBus(List<BusstopModel> bus, int i) {
    this.busstop = bus;
    this.index = i;
  }

  @override
  DetailState createState() => DetailState(busstop, index);
}

class DetailState extends State<DetailBus> {
  var status = {};
  List<BusstopModel> busstop = List<BusstopModel>();
  List<RouteApi> route = List<RouteApi>();
  bool _isLoading = false;
  int id;
  List<BusPositionModel> busPos = List<BusPositionModel>();

  //** ส่วนของ คำนวนเวลาที่จะแสดง  **//
  List<String> modMili = List<String>();
  List<DurationCal> listDuration = List<DurationCal>();

  //** ส่วนของ noti   **//
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  //** Constructor   **//
  DetailState(List<BusstopModel> bus, int index) {
    this.busstop = bus;
    this.id = index;
  }

  @override
  void initState() {
    super.initState();
    getDataPosition();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('direct_bus');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
      print("onDidReceiveLocalNotification called.");
    });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      // when user tap on notification.
      print("onSelectNotification called.");
      setState(() {});
    });
  }

  sendNotification(int id, String bus, int time, String sName) async {
    TimeOfDay timeOfDay = TimeOfDay.now();
    var now = new DateTime.now();
    var notificationTime = new DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute + time,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    Toast.show("รับการแจ้งเตือนก่อนรถมา 1 นาทีสำเร็จ", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        1,
        'รถราง $bus ใกล้มาถึงแล้ว !',
        'จะมาถึงในอีก 1 นาทีที่$sName',
        notificationTime,
        platformChannelSpecifics);
  }

  getDataPosition() async {
    var blng, blat;
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
      blat = busPos[i].latitude;
      blng = busPos[i].longitude;
      var idStop = int.parse(
          busstop.firstWhere((element) => element.sid == busPos[i].sid).sid);
      getJsonData(
          busstop
              .firstWhere((element) => element.sid == idStop.toString())
              .sLongitude,
          busstop
              .firstWhere((element) => element.sid == idStop.toString())
              .sLatitude,
          busstop[id].sLongitude,
          busstop[id].sLatitude,
          int.parse(busPos[i].pid),
          int.parse(busPos[i].sid),
          int.parse(busstop[id].sid),
          busPos[i]);
    }
    // print(listDuration[0].index.toString() +
    //     ' ' +
    //     listDuration[0].time.toString());
    _isLoading = true;
    setState(() {});
  }

  Future<double> getJsonData(String lat1, String long1, String lat2,
      String long2, int i, int sid, int bussid, BusPositionModel bus) async {
    NetworkHelper network = NetworkHelper(
      startLat: double.parse(lat1),
      startLng: double.parse(long1),
      endLat: double.parse(lat2),
      endLng: double.parse(long2),
    );

    try {
      if (sid == 1 && bussid == 1) {
        var data1 = await network.getDataStartStop(lat1, long1, lat2, long2);
        var wayBus = await network.getDataStartStop(
            lat2, long2, bus.latitude, bus.longitude);
        // print(data['routes'][0]['summary']);
        var modBus = ((double.parse(wayBus['features'][0]['properties']
                            ['segments'][0]['steps'][0]['duration']
                        .toString())
                    .ceil())
                .toInt() %
            60);
        if (modBus < 60) {
          modBus = modBus.truncate().toInt();
        } else {
          modBus = (modBus.toInt() % 60);
        }
        var mod = ((double.parse(data1['features'][0]['properties']['segments']
                            [0]['steps'][0]['duration']
                        .toString())
                    .ceil())
                .toInt() %
            60);
        if (mod < 60) {
          mod = mod.truncate().toInt();
        } else {
          mod = (mod.toInt() % 60);
        }
        DurationCal obj = DurationCal(
            (double.parse(data1['features'][0]['properties']['segments'][0]
                        ['steps'][0]['duration']
                    .toString()) /
                60),
            i,
            (mod + modBus));
        listDuration.add(obj);

        if (listDuration.length == busPos.length) {
          setState(() {});
        }
        return data1['features'][0]['properties']['segments'][0]['steps'][0]
            ['duration'];
      }
      //* no busstop one *//
      else {
        var mod;
        var data = await network.getData(busstop, id, busPos, i);
        var wayBus = await network.getDataStartStop(
            lat2, long2, bus.latitude, bus.longitude);
        // print(data['routes'][0]['summary']);
        print(wayBus['features'][0]['properties']['segments'][0]['steps'][0]);
        print(data['routes'][0]['summary']['duration']);
        double sumDuration = data['routes'][0]['summary']['duration'] -
            wayBus['features'][0]['properties']['segments'][0]['steps'][0]
                ['duration'];
        if (sumDuration < 60) {
          mod = sumDuration.truncate().toInt();
        } else {
          mod = (sumDuration.toInt() % 60);
        }

        DurationCal obj = DurationCal((sumDuration / 60), i, mod);
        listDuration.add(obj);
        if (listDuration.length == busPos.length) {
          setState(() {});
        }
        return data['routes'][0]['summary']['duration'];
      }
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                children: <Widget>[
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
                      columnSpacing: 60,
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
                                  listDuration.length == busPos.length
                                      ? DataCell(
                                          textRow(int.parse(listDuration
                                                      .firstWhere((element) =>
                                                          element.index
                                                              .toString() ==
                                                          data.pid)
                                                      .time
                                                      .toStringAsFixed(0))
                                                  .toString() +
                                              '.' +
                                              listDuration
                                                  .firstWhere((element) =>
                                                      element.index
                                                          .toString() ==
                                                      data.pid)
                                                  .mod
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'กำลังโหลดข้อมูลเวลาที่รถรางจะมาถึง อาจจะใช้เวลาเล็กน้อย..',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
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
