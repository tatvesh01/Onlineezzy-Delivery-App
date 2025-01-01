import 'package:shared_preferences/shared_preferences.dart';

class SPHelper {
  static late SharedPreferences prefs;

  static sharedPrefInit() async {
    prefs = await SharedPreferences.getInstance();
  }

  static setRole(String role){
    prefs.setString("role", role);
  }

  static Future<String> getRole() async{
    String role = await prefs.getString("role") ?? "NA";
    return role;
  }

  static setName(String name){
    prefs.setString("name", name);
  }

  static Future<String> getName() async{
    String name = await prefs.getString("name") ?? "NA";
    return name;
  }

  static setBearer(String bearer){
    prefs.setString("bearer", bearer);
  }

  static Future<String> getBearer() async{
    String bearer = await prefs.getString("bearer") ?? "NA";
    return bearer;
  }

  static setUserId(int userId){
    prefs.setInt("userId", userId);
  }

  static Future<int> getUserId() async{
    int userId = await prefs.getInt("userId") ?? 0;
    return userId;
  }

}
