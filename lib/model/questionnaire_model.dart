// To parse this JSON data, do
//
//     final questionnaireModel = questionnaireModelFromJson(jsonString);

import 'dart:convert';

List<QuestionnaireModel> questionnaireModelFromJson(String str) =>
    List<QuestionnaireModel>.from(
        json.decode(str).map((x) => QuestionnaireModel.fromJson(x)));

String questionnaireModelToJson(List<QuestionnaireModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuestionnaireModel {
  QuestionnaireModel({
    this.aId,
    this.aDetail,
    this.aPoint,
  });

  String aId;
  String aDetail;
  String aPoint;

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) =>
      QuestionnaireModel(
        aId: json["a_id"],
        aDetail: json["a_detail"],
        aPoint: json["a_point"],
      );

  Map<String, dynamic> toJson() => {
        "a_id": aId,
        "a_detail": aDetail,
        "a_point": aPoint,
      };
}
