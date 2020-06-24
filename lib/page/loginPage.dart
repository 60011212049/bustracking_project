import 'dart:convert';
import 'dart:io';
import 'package:bustracking_project/model/busschedule_model.dart';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/comment_model.dart';
import 'package:bustracking_project/model/member_model.dart';
import 'package:bustracking_project/page/googleMap.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:bustracking_project/page/home.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class LogingPage extends StatefulWidget {
  @override
  _LogingPageState createState() => _LogingPageState();
}

class _LogingPageState extends State<LogingPage> {
  Service service;
  var busstop;
  bool _isHidden = true;
  var _usernamecontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();
  bool _isLoading = false;
  var status = {};
  bool pass = false;
  BitmapDescriptor _markerIcon;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
  }

  Future _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bmpd = await BitmapDescriptor.fromAssetImage(
          configuration, 'asset/icons/placeholder.png');
      setState(() {
        _markerIcon = bmpd;
      });
    }
  }

  Future<List<BusstopModel>> getDataBusstop() async {
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busstop_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    HomePage.busstop = jsonData.map((i) => BusstopModel.fromJson(i)).toList();
    _createMarker();
  }

  Future<List<CommentModel>> getDataComment() async {
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    print(jsonSt);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/comment_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    List jsonData = json.decode(response.body);
    HomePage.comment = jsonData.map((i) => CommentModel.fromJson(i)).toList();
  }

  Future<List<CommentModel>> getDataBusSchedule() async {
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    print(jsonSt);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busschedule_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    List jsonData = json.decode(response.body);
    HomePage.busschedule =
        jsonData.map((i) => BusscheduleModel.fromJson(i)).toList();
  }

  Future _login() async {
    status['status'] = 'getProfile';
    status['username'] = _usernamecontroller.text;
    status['password'] = _passwordcontroller.text;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/member_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body.toString());
    List jsonData = json.decode(response.body);
    var member = jsonData.map((i) => MemberModel.fromJson(i)).toList();
    if (response.statusCode == 200) {
      var datauser = json.decode(response.body);
      if (datauser.length == 0) {
        setState(() {
          _isLoading = false;
          Toast.show("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        var getBus = await getDataBusstop();
        getDataComment();
        getDataBusSchedule();
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage.sent(member),
              ));
        });
        print('Login Success !');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("asset/backgrounds/BG1.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter),
            color: Colors.grey[700]),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : listviewInput(),
      ),
    );
  }

  ListView listviewInput() {
    return ListView(
        padding:
            EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0, bottom: 20.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: 50.0, right: 20.0, left: 20.0, bottom: 20.0),
                child: Image.asset(
                  'asset/icons/msubuslogo.png',
                  height: 200,
                  width: 200,
                ),
              ),
              inputData(_usernamecontroller, 'ชื่อผู้ใช้งาน'),
              inputData(_passwordcontroller, 'รหัสผ่าน'),
              SizedBox(height: 50.0),
              ButtonTheme(
                minWidth: 300.0,
                height: 60.0,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.0),
                  ),
                  color: Colors.yellow[700],
                  child: Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 27.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quark',
                    ),
                  ),
                  onPressed: () {
                    print(_usernamecontroller.text);
                    print(_passwordcontroller.text);
                    setState(() {
                      _isLoading = true;
                      _login();
                    });
                    // _login();
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: Text('2020 \u00a9 Thanapol Boonprakom')),
              ),
            ],
          ),
        ]);
  }

  Padding inputData(controller, hintText) {
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, right: 0.0, left: 0.0, bottom: 10.0),
        child: Container(
          child: TextField(
            style: TextStyle(fontSize: 22.0),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 22.0,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              prefixIcon: hintText == "ชื่อผู้ใช้งาน"
                  ? Icon(Icons.email)
                  : Icon(Icons.lock),
              suffixIcon: hintText == "รหัสผ่าน"
                  ? IconButton(
                      onPressed: _toggleVisibility,
                      icon: _isHidden
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    )
                  : null,
            ),
            controller: controller,
            obscureText: hintText == "รหัสผ่าน" ? _isHidden : false,
          ),
        ));
  }

  void _createMarker() {
    for (int i = 0; i < HomePage.busstop.length; i++) {
      print('i > ' + i.toString());
      MapPage.markers.add(Marker(
          icon: _markerIcon,
          markerId: MarkerId(i.toString()),
          position: LatLng(double.parse(HomePage.busstop[i].sLatitude),
              double.parse(HomePage.busstop[i].sLongitude)),
          infoWindow: InfoWindow(
            title: HomePage.busstop[i].sName,
          )));
    }
  }
}
