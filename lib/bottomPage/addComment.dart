import 'dart:convert';
import 'dart:io';
import 'package:bustracking_project/model/comment_model.dart';
import 'package:bustracking_project/model/statusModel.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class AddComment extends StatefulWidget {
  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  double ratingTrue;
  var _namecontroller = TextEditingController();
  var _detailcontroller = TextEditingController();
  StatusCodeMember statuss;

  Future<List<CommentModel>> _sentDataComment() async {
    var status = {};
    status['status'] = 'add';
    status['id'] = HomePage.mem[0].mid;
    status['name'] = _namecontroller.text;
    status['detail'] = _detailcontroller.text;
    status['point'] = ratingTrue.toString();
    status['image'] = '';
    String jsonSt = json.encode(status);
    print(jsonSt);
    var response = await http.post(
        'https://busprojectth.000webhostapp.com/comment_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    if (response.statusCode == 200) {
      statuss = StatusCodeMember.fromJson(json.decode(response.body));
      if (statuss.toString() == 'Bad') {
        setState(() {
          AddComment().createState();
          Toast.show("เพิ่มไม่สำเร็จ", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
        print("Login Fail");
      } else {
        Toast.show("เพิ่มรีวิวสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        print('add Success !');
        setState(() {
          Navigator.pop(context);
        });
      }
    } else {
      setState(() {
        //_isLoading = false;
        //Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เพิ่มความคิดเห็น',
          textScaleFactor: 1.4,
        ),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: Text(
                        'คะแนนการรีวิวการใช้งาน',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: RatingBar(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            unratedColor: Colors.grey[300],
                            onRatingUpdate: (rating) {
                              print(rating);
                              ratingTrue = rating;
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(
                      height: 5,
                      color: Colors.black,
                    ),
                    Container(
                      height: 20,
                    ),
                    TextField(
                      maxLength: 20,
                      style: TextStyle(fontSize: 22.0),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'ชื่อเล่น',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 22.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      controller: _namecontroller,
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'ข้อความ',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 22.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      maxLength: 500,
                      controller: _detailcontroller,
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
                              "เพิ่มความคิดเห็น",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quark',
                              ),
                            ),
                            onPressed: () {
                              print(_namecontroller.text);
                              print(_detailcontroller.text);

                              setState(() {
                                // _isLoading = false;
                                _sentDataComment();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
