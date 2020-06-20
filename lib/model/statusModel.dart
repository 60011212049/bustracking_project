// To parse this JSON data, do
//
//     final statusCodeMember = statusCodeMemberFromJson(jsonString);

import 'dart:convert';

StatusCodeMember statusCodeMemberFromJson(String str) => StatusCodeMember.fromJson(json.decode(str));

String statusCodeMemberToJson(StatusCodeMember data) => json.encode(data.toJson());

class StatusCodeMember {
    String status;

    StatusCodeMember({
        this.status,
    });

    factory StatusCodeMember.fromJson(Map<String, dynamic> json) => StatusCodeMember(
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
    };
}
