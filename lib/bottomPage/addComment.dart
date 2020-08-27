import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bustracking_project/service/service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:http_parser/http_parser.dart';

class AddComment extends StatefulWidget {
  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  double ratingTrue;
  var _namecontroller = TextEditingController();
  var _detailcontroller = TextEditingController();
  File image;
  var fileName;

  Future addTransciption(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var status = {};
    status['status'] = 'add';
    status['aid'] = pref.getInt('tokenId');
    status['type'] = 'เพิ่มข้อมูลรีวิว ' + id;
    status['time'] = DateTime.now().toString();
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/transcription_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Map<String, dynamic>> _uploadImage() async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse('http://' + Service.ip + '/controlModel/upload.php'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    print(mimeTypeData[0]);
    print(mimeTypeData[1]);
    print(image.path);
    print(file.filename);
    fileName = file.filename;
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        Toast.show("ไม่สามารถอัพรูปภาพได้ กรุณาใช้รูปภาพอื่น", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return null;
      } else {
        var res = await sentDataComment();
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future sentDataComment() async {
    var status = {};
    status['status'] = 'add';
    if (_namecontroller.text == '') {
      status['name'] = 'No name';
    } else {
      status['name'] = _namecontroller.text;
    }
    status['detail'] = _detailcontroller.text;
    status['point'] = ratingTrue.toString();
    status['image'] = fileName;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/comment_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    if (response.statusCode == 200) {
      if (response.body.toString() == 'Bad') {
        setState(() {
          Toast.show("เพิ่มข้อมูลไม่สำเร็จ", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        Toast.show("เพิ่มข้อมูลสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        addTransciption(_detailcontroller.text);
        Navigator.pop(context);
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เพิ่มความคิดเห็น',
          style: TextStyle(
            color: Color(0xFF3a3a3a),
            fontSize: 25,
          ),
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
                        style: TextStyle(
                          fontSize: 25,
                        ),
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
                      height: 5,
                    ),
                    Container(
                      height: 100,
                      child: TextField(
                        maxLength: 20,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          labelText: 'ชื่อเล่น',
                          labelStyle: TextStyle(
                            fontSize: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'ชื่อเล่น',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                        controller: _namecontroller,
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: TextField(
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            labelText: 'ข้อความ',
                            labelStyle: TextStyle(
                              fontSize: 20,
                            ),
                            hintText: 'ข้อความ',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          maxLength: 500,
                          controller: _detailcontroller,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Center(
                          child: image == null
                              ? Container()
                              : Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 300,
                                      maxHeight: 100,
                                    ),
                                    child: Image.file(
                                      image,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'เพิ่มรูปภาพจากกล้อง',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () async {
                            var image;
                            try {
                              image = await ImagePicker.pickImage(
                                  source: ImageSource.camera);
                              this.image = image;
                            } catch (e) {}

                            setState(() {});
                          },
                        ),
                        Text(
                          'หรืออัลบั้ม',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.image),
                          onPressed: () async {
                            var image;
                            try {
                              image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              this.image = image;
                            } catch (e) {}

                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: ButtonTheme(
                        minWidth: 250,
                        height: 60,
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
                            onPressed: () async {
                              print(_namecontroller.text);
                              print(_detailcontroller.text);
                              try {
                                if (image == null) {
                                  sentDataComment();
                                } else {
                                  final Map<String, dynamic> response =
                                      await _uploadImage();
                                }
                              } catch (e) {}
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
