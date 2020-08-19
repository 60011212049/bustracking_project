import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bustracking_project/bottomPage/addComment.dart';
import 'package:bustracking_project/bottomPage/busschedule_page.dart';
import 'package:bustracking_project/bottomPage/busstop_page.dart';
import 'package:bustracking_project/bottomPage/comment_page.dart';
import 'package:bustracking_project/custom_icons.dart';
import 'package:bustracking_project/custom_new_icons.dart';
import 'package:bustracking_project/model/busposition_model.dart';
import 'package:bustracking_project/model/busschedule_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/comment_model.dart';
import 'package:bustracking_project/model/member_model.dart';
import 'package:bustracking_project/page/assessment_page.dart';
import 'package:bustracking_project/page/busroute.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //* Local Variable *//
  List<MemberModel> mem;
  BitmapDescriptor markerIcon;
  List<MemberModel> member;
  var status = {};
  int selectedIndex = 0;
  List<BusPositionModel> busPos = List<BusPositionModel>();

  //* Set Tab BottomNavigator *//
  TabController _tabController;
  final _tabList = [
    Container(
      child: MapPage(),
    ),
    Container(
      child: BusStopPage(),
    ),
    Container(
      child: BusSchedule(),
    ),
    Container(
      child: CommentPage(),
    ),
  ];

  Future<void> getBusLocation() async {
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/buspossition_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busPos = jsonData.map((i) => BusPositionModel.fromJson(i)).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  /* Main method to run home */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarHome(),
      body: _tabList[selectedIndex],
      drawer: drawwerMenu(),
      bottomNavigationBar: bottomBar(),
    );
  }

  // ***** AppBar ****** //
  AppBar appBarHome() {
    return AppBar(
      title: Row(
        children: <Widget>[
          Image.asset(
            'asset/icons/bus_appbar.png',
            fit: BoxFit.cover,
            width: 60,
          ),
          Container(
            width: 10,
          ),
          Text('Bus GPS tracking'),
        ],
      ),
      actions: <Widget>[
        (selectedIndex == 3)
            ? IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddComment(),
                      ));
                },
              )
            : Container()
      ],
    );
  }

  // ***** Drawwer Menu ****** //
  Drawer drawwerMenu() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipOval(
              child: Container(
                child: Image.asset("asset/icons/student.png"),
                color: Colors.white,
              ),
            ),
            accountName: Text(
              'MSU Bus GPS Tracking',
              style: TextStyle(fontSize: 21),
            ),
            accountEmail: null,
          ),
          ListTile(
            title: Text(
              'แผนที่',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            trailing: Image.asset(
              "asset/icons/map_icon.png",
              width: 25,
            ),
            onTap: () {
              setState(() {
                selectedIndex = 0;
                Navigator.of(context).pop();
                _tabController.animateTo(0);
              });
            },
          ),
          ListTile(
            title: Text('แผนที่การเดินรถ',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/route_icon.png",
              width: 25,
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusRoute(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('จุดรับส่งผู้โดยสาร',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/point_icon.png",
              width: 25,
            ),
            onTap: () {
              setState(() {
                selectedIndex = 1;
                Navigator.of(context).pop();
                _tabController.animateTo(1);
              });
            },
          ),
          ListTile(
            title: Text('ตารางการเดินรถ',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/bus_icon.png",
              width: 25,
            ),
            onTap: () {
              setState(() {
                selectedIndex = 2;
                Navigator.of(context).pop();
                _tabController.animateTo(2);
              });
            },
          ),
          ListTile(
            title: Text('แบบประเมินแอพพลิเคชัน',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/task.png",
              width: 25,
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentFormPage(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('ติดต่อเรา',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/mail_icon.png",
              width: 25,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Divider(),
          ListTile(
            title: Text('ปิดเมนู',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Icon(Icons.close),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ***** BottomBarNavgator Menu ****** //
  FFNavigationBar bottomBar() {
    return FFNavigationBar(
      theme: FFNavigationBarTheme(
        barBackgroundColor: Colors.white,
        selectedItemBorderColor: Color(0xFF3a3a3a),
        selectedItemBackgroundColor: Colors.yellow[700],
        selectedItemIconColor: Color(0xFF3a3a3a),
        selectedItemLabelColor: Color(0xFF3a3a3a),
        unselectedItemTextStyle: TextStyle(fontSize: 15.0),
        selectedItemTextStyle: TextStyle(fontSize: 17.0),
      ),
      selectedIndex: selectedIndex,
      onSelectTab: (index) {
        setState(() {
          selectedIndex = index;
          print('select index : ' + selectedIndex.toString());
          _tabController.animateTo(selectedIndex);
          // _changeIndex(index);
        });
      },
      items: [
        FFNavigationBarItem(
          iconData: Icons2.map_for,
          label: 'แผนที่',
        ),
        FFNavigationBarItem(
          iconData: Icons1.location_5,
          label: 'จุดรับส่ง',
        ),
        FFNavigationBarItem(
          iconData: Icons1.directions_bus,
          label: 'ตารางเดินรถ',
        ),
        FFNavigationBarItem(
          iconData: Icons1.comment_5,
          label: 'ความคิดเห็น',
        ),
      ],
    );
  }
}
