// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

List<CommentModel> commentModelFromJson(String str) => List<CommentModel>.from(json.decode(str).map((x) => CommentModel.fromJson(x)));

String commentModelToJson(List<CommentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommentModel {
    CommentModel({
        this.rid,
        this.mid,
        this.rName,
        this.rPoint,
        this.rDetail,
        this.rImage,
    });

    String rid;
    String mid;
    String rName;
    String rPoint;
    String rDetail;
    String rImage;

    factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        rid: json["Rid"],
        mid: json["Mid"],
        rName: json["r_name"],
        rPoint: json["r_point"],
        rDetail: json["r_detail"],
        rImage: json["r_image"],
    );

    Map<String, dynamic> toJson() => {
        "Rid": rid,
        "Mid": mid,
        "r_name": rName,
        "r_point": rPoint,
        "r_detail": rDetail,
        "r_image": rImage,
    };
}
