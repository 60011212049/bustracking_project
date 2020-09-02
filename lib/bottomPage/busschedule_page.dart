import 'dart:convert';
import 'dart:io';

import 'package:bustracking_project/model/busschedule_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/screenutill.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BusSchedule extends StatefulWidget {
  @override
  _BusScheduleState createState() => _BusScheduleState();
}

class _BusScheduleState extends State<BusSchedule> {
  List<BusstopModel> busstop = List<BusstopModel>();
  List<BusscheduleModel> busData = List<BusscheduleModel>();
  List<BusscheduleModel> busScheduleForSearch = List<BusscheduleModel>();
  List<BusscheduleModel> busdefault = List<BusscheduleModel>();
  TextEditingController editcontroller = TextEditingController();
  bool _isloading = false;
  List<DataRow> rowlist;
  TimeOfDay timeOfDay;
  int i = 0, j = 0, selectInt = 0;
  List<int> listTimeAvg = [
    0,
    30,
    60,
    120,
    240,
    300,
    360,
    390,
    450,
    480,
    540,
    600,
    630,
    690,
    750,
    870,
    930,
    990,
    1050,
    1110,
  ];
  String _selectedTpye;
  @override
  void initState() {
    super.initState();
    this.i = 0;
    this.j = 0;
    getDataBusSchedule();
    getDataBusstop();
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
    _selectedTpye = busstop[0].sName;
    this.i = 0;
    this.j = 0;
    setState(() {});
  }

  Future getDataBusSchedule() async {
    busScheduleForSearch.clear();
    var status = {};
    status['status'] = 'show';
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
    busdefault.addAll(busData);
    countTime(0);
    _isloading = true;
    this.i = 0;
    this.j = 0;
    setState(() {});
  }

  void filterSearchResults(String query) {
    this.i = 0;
    this.j = 0;
    List<BusscheduleModel> dummySearchList = List<BusscheduleModel>();
    dummySearchList.addAll(busScheduleForSearch);
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
        this.j = 0;
        busScheduleForSearch.clear();
        busScheduleForSearch.addAll(dummyListData);
      });
      return;
    } else {
      this.i = 0;
      this.j = 0;
      setState(() {
        busScheduleForSearch.clear();
        busScheduleForSearch.addAll(busdefault);
      });
    }
  }

  int countRount() {
    return i = i + 1;
  }

  String countTime(int i) {
    List<BusscheduleModel> dummySearchList = List<BusscheduleModel>();
    dummySearchList.addAll(busData);
    List<BusscheduleModel> dummyListData = List<BusscheduleModel>();
    dummySearchList.forEach((item) {
      int hh = int.parse(item.tcTime.substring(0, 2));
      int mm = int.parse(item.tcTime.substring(3, 5));
      int ss = int.parse(item.tcTime.substring(6, 8));
      // print('test minute' + element.tcTime);
      ss = ss + listTimeAvg[i];
      if (ss >= 60) {
        mm = mm + ss ~/ 60;
        ss = ss % 60;
        if (mm >= 60) {
          mm = mm % 60;
          hh = hh + 1;
        }
      }
      BusscheduleModel dummy = BusscheduleModel();
      dummy.sid = item.sid;
      dummy.cid = item.cid;
      dummy.tCid = item.tCid;
      dummy.tcDate = item.tcDate;
      dummy.tcTime = (hh < 10 ? ('0' + hh.toString()) : hh.toString()) +
          ':' +
          (mm < 10 ? ('0' + mm.toString()) : mm.toString()) +
          ':' +
          (ss < 10 ? ('0' + ss.toString()) : ss.toString());
      dummyListData.add(dummy);
    });
    setState(() {
      this.i = 0;
      this.j = 0;
      busScheduleForSearch.clear();
      busScheduleForSearch.addAll(dummyListData);
      if (editcontroller.text.isEmpty) {
        busdefault.clear();
        busdefault.addAll(dummyListData);
      }
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Container(
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
            ),
            Container(
              height: 60,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, bottom: 4, top: 10),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      color: Color(0xFFF2F2F2)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      iconEnabledColor: Color(0xFF595959),
                      items: busstop.map((value) {
                        return DropdownMenuItem<String>(
                          value: value.sName,
                          onTap: () {
                            print(value.sid);
                            editcontroller.text = '';
                            countTime(int.parse(value.sid) - 1);
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Text(
                              value.sName,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        );
                      }).toList(),
                      hint: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text(
                          'จุดจอดรถหลังหอหญิงวาปีปทุม',
                          style:
                              TextStyle(color: Color(0xFF8B8B8B), fontSize: 17),
                        ),
                      ), // setting hint
                      onChanged: (String value) {
                        setState(() {
                          _selectedTpye = value; // saving the selected value
                        });
                      },
                      value: _selectedTpye, // displaying the selected value
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '**เวลาที่รถมาจะถึง จากจุดที่รถออกมาจนถึงจุดที่เราเลือก**',
              style: TextStyle(fontSize: 12),
            ),
            _isloading == true
                ? Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        sortAscending: true,
                        sortColumnIndex: 0,
                        columns: [
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: textColumn('เวลาที่รถจะมาถึงจุด'),
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
                  )
                : Container(
                    child: DataTable(
                      sortAscending: true,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                          label: Container(
                            width: 150,
                            child: textColumn('เวลาที่รถจะมาถึงจุด'),
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
                              ))
                          .toList(),
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
