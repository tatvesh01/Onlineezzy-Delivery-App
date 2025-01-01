import 'dart:convert';

List<ParcelListModel> parcelListModelFromJson(String str) => List<ParcelListModel>.from(json.decode(str).map((x) => ParcelListModel.fromJson(x)));

String parcelListModelToJson(List<ParcelListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParcelListModel {
  String id;
  String email;
  String name;
  String phone;
  String latitude;
  String longitude;
  String destination;
  List<StatusAndTrackingIdDB> statusAndTrackingIdsDB;

  ParcelListModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.destination,
    required this.statusAndTrackingIdsDB,
  });

  factory ParcelListModel.fromJson(Map<String, dynamic> json) => ParcelListModel(
    id: json["id"],
    email: json["email"],
    name: json["name"],
    phone: json["phone"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    destination: json["destinationCoordinates"] ?? "Full Address Here",
    statusAndTrackingIdsDB: List<StatusAndTrackingIdDB>.from(json["status_and_tracking_ids"].map((x) => StatusAndTrackingIdDB.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "destinationCoordinates": destination,
    "status_and_tracking_ids": List<dynamic>.from(statusAndTrackingIdsDB.map((x) => x.toJson())),
  };
}

class StatusAndTrackingIdDB {
  String status;
  String trackingNumber;
  DateTime lastUpdate;

  StatusAndTrackingIdDB({
    required this.status,
    required this.trackingNumber,
    required this.lastUpdate,
  });

  factory StatusAndTrackingIdDB.fromJson(Map<String, dynamic> json) => StatusAndTrackingIdDB(
    status: json["status"],
    trackingNumber: json["trackingNumber"],
    lastUpdate: DateTime.parse(json["lastUpdate"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "trackingNumber": trackingNumber,
    "lastUpdate": lastUpdate.toIso8601String(),
  };
}