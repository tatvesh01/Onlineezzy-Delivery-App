import 'dart:convert';

CustomerParcelListModel customerParcelListModelFromJson(String str) => CustomerParcelListModel.fromJson(json.decode(str));

String customerParcelListModelToJson(CustomerParcelListModel data) => json.encode(data.toJson());

class CustomerParcelListModel {
  String phone;
  String address;
  String latitude;
  String longitude;
  int user;
  List<StatusAndTrackingId> statusAndTrackingIds;

  CustomerParcelListModel({
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.user,
    required this.statusAndTrackingIds,
  });

  factory CustomerParcelListModel.fromJson(Map<String, dynamic> json) => CustomerParcelListModel(
    phone: json["phone"],
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    user: json["user_id"],
    statusAndTrackingIds: List<StatusAndTrackingId>.from(json["status_and_tracking_ids"].map((x) => StatusAndTrackingId.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "user_id": user,
    "status_and_tracking_ids": List<dynamic>.from(statusAndTrackingIds.map((x) => x.toJson())),
  };
}

class StatusAndTrackingId {
  String status;
  String trackingId;
  String dateAdded;
  String? imageUrl;
  Pickup pickup;
  String destinationCoordinates;

  StatusAndTrackingId({
    required this.status,
    required this.trackingId,
    required this.dateAdded,
    required this.imageUrl,
    required this.pickup,
    required this.destinationCoordinates,
  });

  factory StatusAndTrackingId.fromJson(Map<String, dynamic> json) => StatusAndTrackingId(
    status: json["status"],
    trackingId: json["tracking_id"],
    dateAdded:json["date_added"],
    imageUrl: json["image_url"] ?? "https://i.pinimg.com/736x/df/82/cb/df82cba068241200d3ae04e96b62ef9e.jpg",
    pickup: pickupValues.map[json["pickup"]]!,
    destinationCoordinates: json["destinationCoordinates"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "tracking_id": trackingId,
    "date_added": dateAdded,
    "image_url": imageUrl,
    "pickup": pickupValues.reverse[pickup],
    "destinationCoordinates": destinationCoordinates,
  };
}

enum Pickup {
  ONLINE_EZZY
}

final pickupValues = EnumValues({
  "OnlineEzzy": Pickup.ONLINE_EZZY
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}