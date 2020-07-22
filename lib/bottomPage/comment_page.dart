import 'dart:convert';
import 'dart:io';

import 'package:bustracking_project/model/comment_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  double rat = 0;
  List<CommentModel> comment;
  @override
  void initState() {
    super.initState();
    this.comment = HomePage.comment;
    calRating();
  }

  void calRating() {
    rat = 0;
    double x = 0;
    for (var i = 0; i < comment.length; i++) {
      rat = rat + double.parse(comment[i].rPoint.toString());
      print('> ' + comment[i].rPoint.toString());
      x = x + 1;
    }
    print('number > ' + rat.toString());
    rat = double.parse((rat / x).toStringAsFixed(1));
    print('Sum : ' + rat.toString() + ' i : ' + x.toString());
  }

  Future<Null> refreshList() async {
    //await Future.delayed(Duration(seconds: 2));
    print('Refresh list');
    var status = {};
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
    this.comment = jsonData.map((i) => CommentModel.fromJson(i)).toList();
    setState(() {
      calRating();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: Text(
                        'คะแนนการรีวิวการใช้งาน',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rat.toString(),
                          style: TextStyle(fontSize: 40),
                        ),
                        RatingBarIndicator(
                          rating: rat,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 40.0,
                          unratedColor: Colors.grey[300],
                        ),
                      ],
                    ),
                    Divider(
                      height: 5,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    for (var i = comment.length - 1; i >= 0; i--)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                        child: Container(
                            child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 2, 0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.yellow[700],
                                    radius: 22,
                                    child: Text('user'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        comment[i].rName,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 5),
                                        child: RatingBarIndicator(
                                          rating: double.parse(
                                              comment[i].rPoint.toString()),
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          unratedColor: Colors.grey[300],
                                        ),
                                      ),
                                      Container(
                                        width: 310,
                                        child: Text(
                                          comment[i].rDetail,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
        onRefresh: refreshList,
      ),
    );
  }
}
