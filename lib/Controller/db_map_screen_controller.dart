import 'dart:convert';
import 'dart:math' as Math;
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as aaaaaa;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onlineezzy/Models/CustomerParcelListModel.dart';
import 'package:onlineezzy/Models/addRouteModel.dart';
import 'package:onlineezzy/Models/parcelListModel.dart';
import 'package:onlineezzy/Models/saveRouteModel.dart';
import 'package:onlineezzy/Utils/GoogleMapsService.dart';
import 'package:onlineezzy/Utils/language.dart';
import 'package:onlineezzy/Utils/sPHelper.dart';
import '../Utils/global.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../Utils/helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as GL;
import 'package:http/http.dart' as http;

class DBMapScreenController extends GetxController{

  late SaveRouteModel mapDataForNavigation;
  AddRouteModel routesList = AddRouteModel();
  Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  PolylinePoints polylinePoints = PolylinePoints();
  late PointLatLng originLatLong;
  late PointLatLng destinationLatLong;
  List<LatLng> polylineCoordinates = [];
  List<PolylineWayPoint> wayPointsPoly = [];
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  late LatLng myLatLong;
  LatLng? latLongForDistCalc;
  LatLng? latLongForDistCalcWhileDriving;
  BitmapDescriptor? carBitMap;

  RxBool refreshMap = false.obs;
  RxBool navigationStarted = false.obs;
  RxBool finalDestinationReached = false.obs;
  RxBool navigationStartedtemp = true.obs;
  RxBool originLocationReached = false.obs;
  RxBool isDragged = false.obs;
  int locationReachedCounter = 0;
  RxString speedInKm = "0.0".obs;
  RxBool refreshKmTxt = false.obs;
  late StreamSubscription speedCalcListner;
  List<PolylineWayPoint> wayPointsPolyWhileDriving = [];
  List<LatLng> tempLatLongWhileDriving = [];
  double mainBearing = 0.1;
  double cameraMoveMapRotation = 0.0;
  BitmapDescriptor? rightArrowBitmap;
  double totalDistanceOfPolyLine = 0;
  LatLng currentPosition = LatLng(0.0, 0.0);
  GoogleMapController? _mapController;
  var middleOfCarImg = const Offset(0.5, 0.5);
  List<LatLng> storeArrowLatLong = [];
  DateTime? previousTime;
  RxBool refreshBottomSheet = true.obs;
  List<StatusAndTrackingIdDB> allParcelData = [];
  String myUserId = "0";
  String userPhoneNumber = "";
  String userName = "";
  late BuildContext tempContext;

  CameraPosition camPosition = const CameraPosition(
    target: LatLng(21.2094892, 72.8317058),
    zoom: 15.00,
  );


  @override
  void onInit() {
    Global.keepScreenOn();
    mapDataForNavigation = Get.arguments[0];
    destinationLatLong = PointLatLng(double.parse(mapDataForNavigation.wayPointsForSaveData[0][0]),double.parse(mapDataForNavigation.wayPointsForSaveData[0][1]));
    myUserId = Get.arguments[2];
    userPhoneNumber = Get.arguments[3];
    userName = Get.arguments[4];
    setUpMapData();
    super.onInit();
  }
  

  updateMap(){
    refreshMap(true);
    refreshMap(false);
  }

  void showVehicleOnMyLocation() async{
    MarkerId markerId = MarkerId("myVehicle");
    if(carBitMap == null){
      carBitMap = BitmapDescriptor.fromBytes(await Global.getBytesFromAsset(Helper.carImg, 100));
      markers[markerId] = Marker(markerId: markerId, icon: carBitMap!, position: myLatLong,anchor: middleOfCarImg);
      updateMap();
    }else{
      markers[markerId] = Marker(markerId: markerId, icon: carBitMap!, position: myLatLong,anchor: middleOfCarImg);
      updateMap();
    }
  }


  void showCustomerPin() async{
    MarkerId markerId = MarkerId("customerPin");
    BitmapDescriptor customerPin = BitmapDescriptor.fromBytes(await Global.getBytesFromAsset(Helper.customerPinImg, 200));
      markers[markerId] = Marker(markerId: markerId, icon: customerPin, position: LatLng(destinationLatLong.latitude, destinationLatLong.longitude),anchor: middleOfCarImg);
      updateMap();
  }

  manageWayPointsAndDrawRoutes(List<PolylineWayPoint> wayPointsPolyNew) async {

    for (int i = 0; i < wayPointsPolyNew.length; i += 20) {
      final batch = wayPointsPolyNew.sublist(i, i + 20 > wayPointsPolyNew.length ? wayPointsPolyNew.length : i + 20);
      if(i != 0){
        batch.insert(0,wayPointsPolyNew[i-1]);
      }

      bool isLastCall = i+20 >= wayPointsPolyNew.length;
      await drawRouteOnMap(batch, isLastCall, i == 0);
    }
  }

  Future<bool> drawRouteOnMap(List<PolylineWayPoint> waypointsBatch,bool isLastCall, bool firstLooping) async {

    if(navigationStarted.value && originLocationReached.value && firstLooping){
      waypointsBatch.insert(0, PolylineWayPoint(location: "${myLatLong.latitude},${myLatLong.longitude}"));
    }

    var firstWay = waypointsBatch.first.toString().split(',');
    var lastWay = waypointsBatch.last.toString().split(',');
    LatLng firstLatLong = LatLng(double.parse(firstWay[0]), double.parse(firstWay[1]));
    LatLng lastLatLong = LatLng(double.parse(lastWay[0]), double.parse(lastWay[1]));
    PointLatLng originPlace = PointLatLng(firstLatLong.latitude, firstLatLong.longitude);
    late PointLatLng destPlace;

    destPlace = PointLatLng(lastLatLong.latitude, lastLatLong.longitude);

    debugPrint("locationData ==>  ${originPlace}       ${destPlace}");

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Global.mapApiKey,
      request: PolylineRequest(
          //origin: originLatLong,
          origin: originPlace,
          destination: destPlace,
          mode: TravelMode.driving,
          wayPoints: routesList.wayPointsPoly.length >= 3 ?  waypointsBatch
              .sublist(1, waypointsBatch.length)
              .map((point) => point)
              .toList() : []
      ),
    );

    if(firstLooping){
      removeAllPolyLine();
    }

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      Global.showToast("Error From Google Api : ${result.errorMessage}");
    }

    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: Helper.redColor,
      width: 7,
    );
    polylines[id] = polyline;
    updateMap();
    await Future.delayed(const Duration(milliseconds: 1));
    return true;
  }

  addPinOnMap(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void recenterBtnPressed() {
    isDragged(false);
    if(navigationStarted.value){
      moveCameraOnMyLocation(myLatLong, mainBearing);
    }else{
      Set<Polyline> tempPolyLine = {};
      polylines.forEach((key, value) {
        tempPolyLine.add(value);
      });
      Global.setAllMarkerCenterInMap(tempPolyLine, mapController);
    }
  }

  void removeAllPolyLine(){
    polylineCoordinates = [];
    polylines.clear();
    wayPointsPoly = [];
    updateMap();
  }


  void animateCar(LatLng targetPosition) async{
    double angleOfCar = mainBearing - cameraMoveMapRotation;
    const duration = Duration(milliseconds: 3000);
    int steps = 20;
    double stepDuration = duration.inMilliseconds / steps;

    LatLng start = currentPosition;
    LatLng end = targetPosition;

    Timer.periodic(Duration(milliseconds: (stepDuration).toInt()), (Timer timer) async {
      double t = timer.tick / steps;
      if (t > 1) {
        timer.cancel();
        t = 1;
      }

      double lat = start.latitude + (end.latitude - start.latitude) * t;
      double lng = start.longitude + (end.longitude - start.longitude) * t;

      LatLng newPosition = LatLng(lat, lng);

      markers.removeWhere((key, value) => key.value.startsWith("myVehicle"));

      MarkerId markerId = MarkerId("myVehicle");
      if(isDragged.value){
        markers[markerId] = Marker(markerId: markerId, icon: carBitMap!, position: newPosition, anchor: middleOfCarImg, rotation: angleOfCar,);
      }else{
        markers[markerId] = Marker(markerId: markerId, icon: carBitMap!, position: newPosition, anchor: middleOfCarImg);
      }
      updateMap();

      if (t == 1) {
        currentPosition = end;

        if (_mapController != null) {

          if(!isDragged.value){
            _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));

            var c = await mapController.future;
            camPosition = CameraPosition(
              target: currentPosition,
              zoom: 17,
              bearing: mainBearing,
            );
            c.animateCamera(CameraUpdate.newCameraPosition(camPosition));
          }
        }

        updateMap();
      }
    });
  }


  void whenCameraMove(CameraPosition position) {
    cameraMoveMapRotation = position.bearing;

  }

  Future<void> changeStatusOfParcel(String status) async {
    //isLoading.value = true;
    List<String> parcelIds = [];

    allParcelData.forEach((element) {
      parcelIds.add(element.trackingNumber);
    });

    String token = await SPHelper.getBearer();
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${token}'
    };

    var bodys = {
        "trackingNumber": parcelIds,
        "status": status
    };

    final url = Uri.parse(Helper.updateParcelStatusApi);

    try {
      final response = await http.post(
        url,
          headers: headers,
          body: jsonEncode(bodys),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint("jsonDatasdsdsd ==> ${jsonData}");
        //final authResponse = UserLoginModel.fromJson(jsonData);
      } else {
        Global.showToast(failedToFetchData);
      }
    } catch (e) {
      Global.showToast(somethingWrong);
    }finally{
      //isLoading.value = false;
    }
  }

  Future<void> sendNotification(bool isOutOfDelivery) async {

    String msgText = Global.getMsgForNotification(userName,isOutOfDelivery);

    var bodys = {
      "appkey": Global.notificationAppkey,
      "authkey": Global.notificationAuthkey,
      "to": userPhoneNumber,
      "message": msgText
    };

    final url = Uri.parse(Helper.notificationApi);

    try {
      final response = await http.post(
        url,
        body: bodys,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint("jsonDatasdsdsd ==> ${jsonData}");
      } else {
        Global.showToast(failedToFetchData);
      }
    } catch (e) {
      Global.showToast(somethingWrong);
    }finally{
    }
  }

  void showDeliveredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Helper.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pin_drop_rounded,
                  size: 60,
                  color: Helper.redColor,
                ),
                SizedBox(height: 10),
                Text(
                  great,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  parcelDeliveredSuccessfully,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Helper.blackColor),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Helper.redColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(width: 100,child: Center(child: Text('Ok',style: TextStyle(color: Helper.whiteColor),))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
