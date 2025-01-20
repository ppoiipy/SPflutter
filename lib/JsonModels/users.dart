// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Users welcomeFromJson(String str) => Users.fromJson(json.decode(str));

String welcomeToJson(Users data) => json.encode(data.toJson());

class Users {
  int? usrId;
  String usrEmail;
  String usrPassword;
  String? gender;
  String? dateOfBirth;
  double? height;
  double? weight;
  double? goalWeight;
  int? activityLevel;

  // Constructor
  Users({
    this.usrId,
    required this.usrEmail,
    required this.usrPassword,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.goalWeight,
    this.activityLevel,
  });

  // Convert Users object to JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'usrId': usrId,
      'usrEmail': usrEmail,
      'usrPassword': usrPassword,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'weight': weight,
      'goalWeight': goalWeight,
      'activityLevel': activityLevel,
    };
  }

  // Convert JSON back to Users object
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      usrId: json['usrId'],
      usrEmail: json['usrEmail'],
      usrPassword: json['usrPassword'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      height: json['height'],
      weight: json['weight'],
      goalWeight: json['goalWeight'],
      activityLevel: json['activityLevel'],
    );
  }
}
