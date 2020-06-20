import 'dart:convert';
import 'dart:io';
import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/model/comment_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:http/http.dart' as http;
import 'package:bustracking_project/model/member_model.dart';

class Service {

  static const String ip = '192.168.1.5';
  var status = {};
  List<MemberModel> member;
  String idx;

  Service(){
    getDataBusstop();
    getDataComment();
  }

  Service.getId(id){
    getDataMember(id);
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

  Future<List<MemberModel>> getDataMember(id) async {
    status['status'] = 'showId';
    status['id'] = id;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/member_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body.toString());
    List jsonData = json.decode(response.body);
    HomePage.mem = jsonData.map((i) => MemberModel.fromJson(i)).toList();
  }
  
}
