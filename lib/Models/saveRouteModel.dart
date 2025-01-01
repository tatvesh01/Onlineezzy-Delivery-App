class SaveRouteModel{
  List<dynamic> wayPointsForSaveData;
  List<dynamic> allAddress;

  SaveRouteModel({required this.wayPointsForSaveData,required this.allAddress});

  factory SaveRouteModel.fromJson(Map<String, dynamic> json) {
    return SaveRouteModel(
      wayPointsForSaveData: json['wayPointsForSaveData'] ?? [],
      allAddress: json['allAddress'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    "wayPointsForSaveData": wayPointsForSaveData,
    "allAddress": allAddress,
  };

}