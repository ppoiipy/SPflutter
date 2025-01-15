// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Users welcomeFromJson(String str) => Users.fromJson(json.decode(str));

String welcomeToJson(Users data) => json.encode(data.toJson());

class Users {
  final int? usrId;
  final String usrEmail;
  final String usrPassword;

  Users({
    this.usrId,
    required this.usrEmail,
    required this.usrPassword,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrEmail: json["usrEmail"],
        usrPassword: json["usrPassword"],
      );

  Map<String, dynamic> toJson() => {
        "usrId": usrId,
        "usrEmail": usrEmail,
        "usrPassword": usrPassword,
      };
}
