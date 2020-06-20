import 'package:bustracking_project/model/busschedule_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:flutter/material.dart';

class BusSchedule extends StatefulWidget {
  @override
  _BusScheduleState createState() => _BusScheduleState();
}

class _BusScheduleState extends State<BusSchedule> {
  List<BusscheduleModel> busData;
  @override
  void initState() {
    super.initState();
    this.busData = HomePage.busschedule;
    print('>>>>> ' + busData.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            DataTable(
              sortAscending: true,
              sortColumnIndex: 0,
              columns: [
                DataColumn(
                  label: textColumn('รอบที่'),
                ),
                DataColumn(
                  label: textColumn('เวลา')
                ),
                DataColumn(
                  label: textColumn('รถราง')
                ),
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
