import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) => UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
  String token;
  String userEmail;
  int userId;
  String userNicename;
  String userDisplayName;
  String role;

  UserLoginModel({
    required this.token,
    required this.userEmail,
    required this.userId,
    required this.userNicename,
    required this.userDisplayName,
    required this.role,
  });

  factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
    token: json["token"],
    userEmail: json["user_email"],
    userId: json["user_id"],
    userNicename: json["user_nicename"],
    userDisplayName: json["user_display_name"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user_email": userEmail,
    "user_id": userId,
    "user_nicename": userNicename,
    "user_display_name": userDisplayName,
    "role": role,
  };
}
