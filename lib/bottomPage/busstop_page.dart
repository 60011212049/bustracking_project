import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/dution_model.dart';
import 'package:bustracking_project/model/route_model.dart';
import 'package:bustracking_project/page/detailPage.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/network.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BusStopPage extends StatefulWidget {
  @override
  _BusStopPageState createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  List<BusstopModel> bus = List<BusstopModel>();
  List<BusstopModel> busForSearch = List<BusstopModel>();
  TextEditingController editcontroller = TextEditingController();
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    getDataBusstop();
  }

  Future getDataBusstop() async {
    busForSearch.clear();
    var status = {};
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busstop_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    bus = jsonData.map((i) => BusstopModel.fromJson(i)).toList();
    busForSearch.addAll(bus);
    _isloading = true;
    setState(() {});
  }

  void filterSearchResults(String query) {
    List<BusstopModel> dummySearchList = List<BusstopModel>();
    dummySearchList.addAll(bus);
    if (query.isNotEmpty) {
      List<BusstopModel> dummyListData = List<BusstopModel>();
      dummySearchList.forEach((item) {
        if ((item.sName.toLowerCase()).contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        busForSearch.clear();
        busForSearch.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        busForSearch.clear();
        busForSearch.addAll(bus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _isloading == false
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('กำลังโหลดข้อมูล'),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: TextField(
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      controller: editcontroller,
                      showCursor: false,
                      style: TextStyle(
                          fontSize: 17.0, height: 0.7, color: Colors.black),
                      decoration: InputDecoration(
                          isDense: true,
                          labelText: "ค้นหา",
                          labelStyle: TextStyle(fontSize: 18),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: busForSearch.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        return ListTile(
                          title: Text(busForSearch[index].sName,
                              style: TextStyle(fontSize: 20)),
                          leading: CircleAvatar(
                            backgroundColor: Colors.yellow[700],
                            radius: 22,
                            child: Text(
                              busForSearch[index].sid,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          onTap: () {
                            for (int i = 0; i < bus.length; i++) {
                              if (bus[i].sid == busForSearch[index].sid) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Detail(bus, i),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ignore: must_be_immutable
