import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onlineezzy/Utils/global.dart';
import 'package:onlineezzy/Utils/helper.dart';

class GoogleMapsService {
  Future<Map<String, dynamic>> getTravelTime({
    required String origin,
    required String destination,
    String mode = "driving",
  }) async {
    final url = Uri.parse(
      "${Helper.googleTimeCalcApi}"
          "?origin=$origin&destination=$destination&mode=$mode&key=${Global.mapApiKey}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if ((data["routes"] as List).isNotEmpty) {
        final route = data["routes"][0];
        final leg = route["legs"][0];
        return {
          "distance": leg["distance"]["text"], // e.g., "10 km"
          "duration": leg["duration"]["text"], // e.g., "15 mins"
        };
      } else {
        throw Exception("No routes found.");
      }
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  }
}