// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

List<CommentModel> commentModelFromJson(String str) => List<CommentModel>.from(
    json.decode(str).map((x) => CommentModel.fromJson(x)));

String commentModelToJson(List<CommentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommentModel {
  CommentModel({
    this.rid,
    this.rName,
    this.rPoint,
    this.rDetail,
    this.cStatus,
    this.cImage,
  });

  String rid;
  String rName;
  String rPoint;
  String rDetail;
  String cStatus;
  String cImage;

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        rid: json["Rid"],
        rName: json["r_name"],
        rPoint: json["r_point"],
        rDetail: json["r_detail"],
        cStatus: json["c_status"],
        cImage: json["c_image"],
      );

  Map<String, dynamic> toJson() => {
        "Rid": rid,
        "r_name": rName,
        "r_point": rPoint,
        "r_detail": rDetail,
        "c_status": cStatus,
        "c_image": cImage,
      };
}
