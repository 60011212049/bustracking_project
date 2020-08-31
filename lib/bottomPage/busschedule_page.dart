import 'dart:convert';
import 'dart:io';

import 'package:bustracking_project/model/busschedule_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusSchedule extends StatefulWidget {
  @override
  _BusScheduleState createState() => _BusScheduleState();
}

class _BusScheduleState extends State<BusSchedule> {
  List<BusscheduleModel> busData;
  List<BusscheduleModel> busScheduleForSearch = List<BusscheduleModel>();
  TextEditingController editcontroller = TextEditingController();
  bool _isloading = false;
  List<DataRow> rowlist;
  TimeOfDay timeOfDay;
  int i = 0;
  @override
  void initState() {
    super.initState();
    this.i = 0;
    getDataBusSchedule();
  }

  Future getDataBusSchedule() async {
    busScheduleForSearch.clear();
    var status = {};
    status['status'] = 'showTimeNow';
    status['id'] = '';
    status['timeNow'] = TimeOfDay.now().hour.toString() +
        ':' +
        TimeOfDay.now().minute.toString() +
        ':00';
    print(TimeOfDay.now());
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busschedule_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ');
    List jsonData = json.decode(response.body);
    busData = jsonData.map((i) => BusscheduleModel.fromJson(i)).toList();
    busScheduleForSearch.addAll(busData);
    _isloading = true;
    this.i = 0;
    setState(() {});
  }

  void filterSearchResults(String query) {
    this.i = 0;
    List<BusscheduleModel> dummySearchList = List<BusscheduleModel>();
    dummySearchList.addAll(busData);
    if (query.isNotEmpty) {
      List<BusscheduleModel> dummyListData = List<BusscheduleModel>();
      dummySearchList.forEach((item) {
        if ((item.cid.toLowerCase()).contains(query) ||
            (item.tcTime.toLowerCase()).contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        this.i = 0;
        busScheduleForSearch.clear();
        busScheduleForSearch.addAll(dummyListData);
      });
      return;
    } else {
      this.i = 0;
      setState(() {
        busScheduleForSearch.clear();
        busScheduleForSearch.addAll(busData);
      });
    }
  }

  int countRount() {
    return i = i + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _isloading == false
            ? ListView(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: TextField(
                      onChanged: (value) {
                        this.i = 0;
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
                  DataTable(
                    columnSpacing: 80,
                    showCheckboxColumn: true,
                    sortAscending: true,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(label: textColumn('เวลา')),
                      DataColumn(label: textColumn('รถราง')),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 80,
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Quark',
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 150,
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Quark',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: TextField(
                      onChanged: (value) {
                        this.i = 0;
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
                    child: SingleChildScrollView(
                      child: DataTable(
                        sortAscending: true,
                        sortColumnIndex: 0,
                        columns: [
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: textColumn('เวลา'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: textColumn('รถราง'),
                            ),
                          ),
                        ],
                        rows: busScheduleForSearch
                            .map((data) => DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        child: Text(
                                          data.tcTime,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Quark',
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        child: Text(
                                          data.cid,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Quark',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
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
