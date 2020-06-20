// To parse this JSON data, do
//
//     final busstopModel = busstopModelFromJson(jsonString);

import 'dart:convert';

List<BusstopModel> busstopModelFromJson(String str) => List<BusstopModel>.from(json.decode(str).map((x) => BusstopModel.fromJson(x)));

String busstopModelToJson(List<BusstopModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BusstopModel {
    BusstopModel({
        this.sid,
        this.sName,
        this.sLongitude,
        this.sLatitude,
        this.sImage,
    });

    String sid;
    String sName;
    String sLongitude;
    String sLatitude;
    String sImage;

    factory BusstopModel.fromJson(Map<String, dynamic> json) => BusstopModel(
        sid: json["Sid"],
        sName: json["s_name"],
        sLongitude: json["s_longitude"],
        sLatitude: json["s_latitude"],
        sImage: json["s_image"],
    );

    Map<String, dynamic> toJson() => {
        "Sid": sid,
        "s_name": sName,
        "s_longitude": sLongitude,
        "s_latitude": sLatitude,
        "s_image": sImage,
    };
}
