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
  bool _isloading = false;
  List<DataRow> rowlist;
  @override
  void initState() {
    super.initState();
    getDataBusSchedule();
  }

  Future getDataBusSchedule() async {
    var status = {};
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busschedule_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ');
    List jsonData = json.decode(response.body);
    busData = jsonData.map((i) => BusscheduleModel.fromJson(i)).toList();
    _isloading = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _isloading == false
            ? ListView(
                children: <Widget>[
                  DataTable(sortAscending: true, sortColumnIndex: 0, columns: [
                    DataColumn(
                      label: textColumn('รอบที่'),
                    ),
                    DataColumn(label: textColumn('เวลา')),
                    DataColumn(label: textColumn('รถราง')),
                  ], rows: [
                    DataRow(
                      cells: [
                        DataCell(textRow('')),
                        DataCell(textRow('')),
                        DataCell(textRow('')),
                      ],
                    )
                  ]),
                ],
              )
            : ListView(
                children: <Widget>[
                  DataTable(
                    sortAscending: true,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                        label: textColumn('รอบที่'),
                      ),
                      DataColumn(label: textColumn('เวลา')),
                      DataColumn(label: textColumn('รถราง')),
                    ],
                    rows: busData
                        .map((data) => DataRow(
                              cells: [
                                DataCell(textRow(data.tCid)),
                                DataCell(textRow(data.tcTime)),
                                DataCell(textRow(data.cid)),
                              ],
                            ))
                        .toList(),
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
