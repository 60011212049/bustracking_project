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
import 'package:bustracking_project/page/editProfile.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:bustracking_project/page/loginPage.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  static List<MemberModel> mem;
  static List<BusstopModel> busstop;
  static List<CommentModel> comment;
  static List<BusscheduleModel> busschedule;
  HomePage.sent(List<MemberModel> result) {
    mem = result;
  }
  HomePage();
  @override
  _HomePageState createState() => _HomePageState(mem);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<MemberModel> member;
  var status = {};
  int selectedIndex = 0;
  _HomePageState(List<MemberModel> res) {
    member = res;
  }

  List<BusPositionModel> busPos = List<BusPositionModel>();
  //* Set Tab BottomNavigator *//
  TabController _tabController;
  final _tabList = [
    Container(
      child: Container(child: MapPage()),
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
    Timer.periodic(Duration(seconds: 1), (timer) {});
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
          Text('Bus tracking'),
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

  // ***** Drawwer Menu ****** //
  Drawer drawwerMenu() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipOval(
              child: Container(
                child: (member[0].mImage != '')
                    ? Image.network(
                        'http://192.168.1.5/controlModel/images/member/' +
                            member[0].mImage)
                    : Image.asset("asset/icons/student.png"),
                color: Colors.white,
              ),
            ),
            accountEmail: Text(member[0].mEmail),
            accountName: Text(member[0].mName),
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
          ListTile(
            title: Text('ตั้งค่าโปรไฟล์',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/settings.png",
              width: 25,
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: Text('ออกจากระบบ',
                style: TextStyle(
                  fontSize: 18.0,
                )),
            trailing: Image.asset(
              "asset/icons/logout.png",
              width: 25,
            ),
            onTap: () async {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LogingPage()),
                  (Route<dynamic> route) => false);
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
}

class BusRoute extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "แผนที่การเดินรถ",
            textScaleFactor: 1.2,
          ),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Expanded(
                child: Image.asset('asset/images/bus_route.jpg'),
              )
            ],
          ),
        ));
  }
}
