// To parse this JSON data, do
//
//     final memberModel = memberModelFromJson(jsonString);

import 'dart:convert';

List<MemberModel> memberModelFromJson(String str) => List<MemberModel>.from(json.decode(str).map((x) => MemberModel.fromJson(x)));

String memberModelToJson(List<MemberModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MemberModel {
    MemberModel({
        this.mid,
        this.mUsername,
        this.mPassword,
        this.mName,
        this.mEmail,
        this.mImage,
    });

    String mid;
    String mUsername;
    String mPassword;
    String mName;
    String mEmail;
    String mImage;

    factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        mid: json["Mid"],
        mUsername: json["m_username"],
        mPassword: json["m_password"],
        mName: json["m_name"],
        mEmail: json["m_email"],
        mImage: json["m_image"],
    );

    Map<String, dynamic> toJson() => {
        "Mid": mid,
        "m_username": mUsername,
        "m_password": mPassword,
        "m_name": mName,
        "m_email": mEmail,
        "m_image": mImage,
    };
}
