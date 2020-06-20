// To parse this JSON data, do
//
//     final busscheduleModel = busscheduleModelFromJson(jsonString);

import 'dart:convert';

List<BusscheduleModel> busscheduleModelFromJson(String str) => List<BusscheduleModel>.from(json.decode(str).map((x) => BusscheduleModel.fromJson(x)));

String busscheduleModelToJson(List<BusscheduleModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BusscheduleModel {
    BusscheduleModel({
        this.tCid,
        this.cid,
        this.sid,
        this.tcDate,
        this.tcTime,
    });

    String tCid;
    String cid;
    String sid;
    DateTime tcDate;
    String tcTime;

    factory BusscheduleModel.fromJson(Map<String, dynamic> json) => BusscheduleModel(
        tCid: json["TCid"],
        cid: json["Cid"],
        sid: json["Sid"],
        tcDate: DateTime.parse(json["TC_date"]),
        tcTime: json["TC_time"],
    );

    Map<String, dynamic> toJson() => {
        "TCid": tCid,
        "Cid": cid,
        "Sid": sid,
        "TC_date": "${tcDate.year.toString().padLeft(4, '0')}-${tcDate.month.toString().padLeft(2, '0')}-${tcDate.day.toString().padLeft(2, '0')}",
        "TC_time": tcTime,
    };
}
