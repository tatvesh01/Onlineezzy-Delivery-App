import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as LatLngs;
import 'package:location/location.dart';
import 'package:onlineezzy/Utils/helper.dart';
import 'package:permission_handler/permission_handler.dart';

class Global {
  static String mapApiKey = "";
  static String notificationAppkey = "";
  static String notificationAuthkey = "";

  static double sWidth = 0, sHeight = 0;
  static FluWakeLock _fluWakeLock = FluWakeLock();

  static deviceSize(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
  }

  static showToast(String txt) {
    Fluttertoast.showToast(msg: txt, toastLength: Toast.LENGTH_SHORT,);
  }

  static void keepScreenOn(){
    _fluWakeLock.enable();
  }

  static void stopKeepScreenOn(){
    _fluWakeLock.disable();
  }


  static Future<void> requestLocationPermission() async {
    if(Platform.isIOS){
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }else{
      final status = await Permission.location.request();
      Location location = Location();

      if (status.isGranted) {
        await location.requestService();
      } else if (status.isDenied) {
        await location.requestService();
        print("Location permission denied");
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }


  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  static void setAllMarkerCenterInMap(Set<Polyline> tempPolyLine,Completer<GoogleMapController> mapController) async{

    double minLat = tempPolyLine.first.points.first.latitude;
    double minLong = tempPolyLine.first.points.first.longitude;
    double maxLat = tempPolyLine.first.points.first.latitude;
    double maxLong = tempPolyLine.first.points.first.longitude;
    tempPolyLine.forEach((poly) {
      poly.points.forEach((point) {
        if(point.latitude < minLat) minLat = point.latitude;
        if(point.latitude > maxLat) maxLat = point.latitude;
        if(point.longitude < minLong) minLong = point.longitude;
        if(point.longitude > maxLong) maxLong = point.longitude;
      });
    });

    final c = await mapController.future;
    c.animateCamera(CameraUpdate.newLatLngBounds(LatLngs.LatLngBounds(
        southwest: LatLngs.LatLng(minLat, minLong),
        northeast: LatLngs.LatLng(maxLat,maxLong)
    ), 80));
  }

  static double calculateDistanceInMeter(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    var radiusOfEarth = 6371;
    return 1000 * radiusOfEarth * 2 * asin(sqrt(a));
  }

  static String getMsgForNotification(String name, bool isOutOfDelivery){

    String msg = "";
    if(isOutOfDelivery){
      msg = '''مرحبًا ${name}،
مندوبنا الآن في الطريق إليك لتوصيل طلبك! 🚚
يمكنك تتبع خط سير المندوب ومعرفة الوقت المتوقع لوصوله من خلال الرابط التالي:
[Here you put link app for ios and Android]

شكرًا لاختيارك OnlineEzzy
إذا كان لديك أي استفسار، لا تتردد في التواصل معنا.

مع أطيب التحيات،
فريق التوصيل EPS''';
    }
    else{
      msg = '''مرحبًا ${name}،
تم تسليم طلبك بنجاح! 🎉
نشكرك على اختيار OnlineEzzy، ونتمنى أن تكون تجربتك معنا مرضية.

إذا كان لديك أي ملاحظات أو استفسارات، يرجى التواصل معنا عبر الواتس اب  0507710060.

مع أطيب التحيات،
فريق التوصيل EPS''';
    }

    return msg;
  }
}
