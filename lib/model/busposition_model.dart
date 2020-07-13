// To parse this JSON data, do
//
//     final busPositionModel = busPositionModelFromJson(jsonString);

import 'dart:convert';

List<BusPositionModel> busPositionModelFromJson(String str) =>
    List<BusPositionModel>.from(
        json.decode(str).map((x) => BusPositionModel.fromJson(x)));

String busPositionModelToJson(List<BusPositionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BusPositionModel {
  BusPositionModel({
    this.pid,
    this.cid,
    this.longitude,
    this.latitude,
    this.cDate,
    this.cTime,
  });

  String pid;
  String cid;
  String longitude;
  String latitude;
  String cDate;
  String cTime;

  factory BusPositionModel.fromJson(Map<String, dynamic> json) =>
      BusPositionModel(
        pid: json["Pid"],
        cid: json["Cid"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        cDate: json["c_date"],
        cTime: json["c_time"],
      );

  Map<String, dynamic> toJson() => {
        "Pid": pid,
        "Cid": cid,
        "longitude": longitude,
        "latitude": latitude,
        "c_date": cDate,
        "c_time": cTime,
      };
}
