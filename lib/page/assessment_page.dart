import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:wasm';

import 'package:bustracking_project/model/questionnaire_model.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class AssessmentFormPage extends StatefulWidget {
  @override
  _AssessmentFormPageState createState() => _AssessmentFormPageState();
}

class _AssessmentFormPageState extends State<AssessmentFormPage> {
  List<QuestionnaireModel> quest = List<QuestionnaireModel>();
  int id = 0;
  String radioButtonItem = '';
  bool loading = false;
  double ratingTrue;
  var point = {};

  List<String> _type = [
    'นักเรียน',
    'นิสิต',
    'บุคลากรในมหาลัย',
    'ประชาชนทั่วไป'
  ];
  String _selectedTpye;

  @override
  void initState() {
    super.initState();
    getDataQuest();
  }

  Future getDataQuest() async {
    print('quest');
    var status = {};
    status['status'] = 'show';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/assesment_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    quest = jsonData.map((i) => QuestionnaireModel.fromJson(i)).toList();
    loading = true;
    setState(() {});
  }

  Future sentDataStatic() async {
    print('quest');
    var status = {};
    point.forEach((key, value) async {
      status['status'] = 'updateData';
      status['id'] = key;
      String jsonSt = json.encode(status);
      print(jsonSt);
      var res = await http.post(
          'http://' + Service.ip + '/controlModel/assesment_model.php',
          body: jsonSt,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      p(res.body);
    });
  }

  void p(String x) {
    print(x);
  }

  Future sentDataQuest() async {
    var status = {};
    double pnt = 0;
    status['status'] = 'add';
    status['sex'] = radioButtonItem;
    status['type'] = _selectedTpye;
    point.forEach((key, value) {
      status['e_' + key.toString()] = value;
      pnt = pnt + value;
    });
    status['point'] = pnt / quest.length;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/evaluation_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    if (response.statusCode == 200) {
      if (response.body.toString() == 'Bad') {
        setState(() {
          Toast.show("ไม่สามารถส่งแบบประเมินได้", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        sentDataStatic();
        Toast.show("ส่งแบบประเมินสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แบบประเมินแอปพลิเคชัน'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เพศ',
                  style: TextStyle(fontSize: 26),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 45,
                    ),
                    Radio(
                      value: 1,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'ชาย';
                          id = 1;
                        });
                      },
                    ),
                    Text(
                      'ชาย',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quark',
                      ),
                    ),
                    Radio(
                      value: 2,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'หญิง';
                          id = 2;
                        });
                      },
                    ),
                    Text(
                      'หญิง',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quark',
                      ),
                    ),
                  ],
                ),
                Text(
                  'ผู้ใช้งาน',
                  style: TextStyle(fontSize: 26),
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 250,
                    child: DropdownButton(
                      isExpanded: true,
                      hint: Text(
                        'กรุณาเลือกผู้ใช้งาน',
                        style: TextStyle(fontSize: 20),
                      ), // Not necessary for Option 1
                      value: _selectedTpye,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTpye = newValue;
                        });
                      },
                      items: _type.map((location) {
                        return DropdownMenuItem(
                          child: new Text(
                            location,
                            style: TextStyle(fontSize: 20),
                          ),
                          value: location,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Text(
                  'แบบสอบถาม',
                  style: TextStyle(fontSize: 26),
                ),
                loading != true
                    ? Container()
                    : Column(
                        children: [
                          for (var quest in quest)
                            Card(
                              child: ListTile(
                                title: Text(
                                  quest.aDetail,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 10),
                                      child: RatingBar(
                                        initialRating: 0,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        unratedColor: Colors.grey[300],
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                          point[quest.aId] = rating;
                                          ratingTrue = rating;
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                Container(
                  height: 30,
                ),
                Center(
                  child: ButtonTheme(
                    minWidth: 250.0,
                    height: 60.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.0),
                        ),
                        color: Colors.blue[700],
                        child: Text(
                          "ส่งแบบประเมิน",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Quark',
                          ),
                        ),
                        onPressed: () {
                          sentDataQuest();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
