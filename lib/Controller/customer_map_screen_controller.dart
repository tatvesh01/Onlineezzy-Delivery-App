import 'dart:math' as Math;
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as aaaaaa;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onlineezzy/Models/addRouteModel.dart';
import 'package:onlineezzy/Models/saveRouteModel.dart';
import 'package:onlineezzy/Utils/GoogleMapsService.dart';
import '../Utils/global.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../Utils/helper.dart';
import 'package:geolocator/geolocator.dart';


class CustomerMapScreenController extends GetxController{

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
  RxBool refreshBottomSheet = true.obs;
  RxBool navigationStarted = false.obs;
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
  LatLng DBPosition = LatLng(0.0, 0.0);
  int myUserId = 0;

  CameraPosition camPosition = const CameraPosition(
    target: LatLng(21.2094892, 72.8317058),
    zoom: 15.00,
  );
  late StreamSubscription<DocumentSnapshot> _subscription;

  @override
  void onInit() {
    mapDataForNavigation = Get.arguments[0];
    myUserId = Get.arguments[1];
    originLatLong = PointLatLng(double.parse(mapDataForNavigation.wayPointsForSaveData[0][0]),double.parse(mapDataForNavigation.wayPointsForSaveData[0][1]));

    Global.keepScreenOn();
    setUpMapData();
    startListenLatLongFromFB();
    super.onInit();
  }

  void startListenLatLongFromFB() {
    _subscription = FirebaseFirestore.instance
        .collection(Helper.deliveryBoyForFB)
        .doc(myUserId.toString())
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        DBPosition = LatLng(data['lat'], data['long']);
        mainBearing = data['bearing'];
        updateLatLongOnMap(DBPosition);
      } else {
        Global.showToast("Delivery not On the way, check in Database");
      }
    });
  }

  void setUpMapData() async {
    carBitMap = BitmapDescriptor.fromBytes(await Global.getBytesFromAsset(Helper.carImg, 100));
    mapDataForNavigation = Get.arguments[0];
    LatLng loopingLatLong = LatLng(double.parse(mapDataForNavigation.wayPointsForSaveData[0][0]), double.parse(mapDataForNavigation.wayPointsForSaveData[0][1]));

    originLocationReached(true);
    refreshBottomSheet(true);
    refreshBottomSheet(false);

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(Helper.deliveryBoyForFB)
        .doc(myUserId.toString())
        .get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      DBPosition = LatLng(data['lat'], data['long']);
      debugPrint("DBPosition ==> ${DBPosition}");
    }else{
      Global.showToast("Delivery not On the way, check in Database");
    }

    LatLng loopingLatLong1 = DBPosition;
    originLatLong = PointLatLng(loopingLatLong.latitude,loopingLatLong.longitude);
    destinationLatLong = PointLatLng(loopingLatLong1.latitude,loopingLatLong1.longitude);
    routesList.addData(PolylineWayPoint(location: "${loopingLatLong.latitude},${loopingLatLong.longitude}"), loopingLatLong, mapDataForNavigation.allAddress[0]);
    routesList.addData(PolylineWayPoint(location: "${loopingLatLong1.latitude},${loopingLatLong1.longitude}"), loopingLatLong1, mapDataForNavigation.allAddress[0]);
    showCustomerPin();

    manageWayPointsAndDrawRoutes(routesList.wayPointsPoly).then((value) {
      Set<Polyline> tempPolyLine = {};
      polylines.forEach((key, value) {
        tempPolyLine.add(value);
      });
      Global.setAllMarkerCenterInMap(tempPolyLine,mapController);
    });
  }

  googleMapCreated(GoogleMapController controller){
    if(!mapController.isCompleted){
      mapController.complete(controller);
      _mapController = controller;
    }
  }

  void updateLatLongOnMap(LatLng dbPosition){
    DateTime currentTime = DateTime.now();
    if(previousTime == null){
      previousTime = currentTime;
      updateLocationAndUi(dbPosition);
      reDrawPoliLineOnMap();
    }

    Duration difference = currentTime.difference(previousTime!);
    if(difference.inSeconds >= 3){
      updateLocationAndUi(dbPosition);
      reDrawPoliLineOnMap();
      previousTime = DateTime.now();
    }
  }

  void showCustomerPin() async{
    MarkerId markerId = MarkerId("customerPin");
    BitmapDescriptor customerPin = BitmapDescriptor.fromBytes(await Global.getBytesFromAsset(Helper.customerPinImg, 200));
    markers[markerId] = Marker(markerId: markerId, icon: customerPin, position: LatLng(originLatLong.latitude, originLatLong.longitude),anchor: middleOfCarImg);
    updateMap();
  }

  void reDrawPoliLineOnMap()async {
    PointLatLng originTemp = PointLatLng(DBPosition.latitude, DBPosition.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Global.mapApiKey,
      request: PolylineRequest(
        //origin: originLatLong,
          origin: originTemp,
          destination: originLatLong,
          mode: TravelMode.driving,
          wayPoints: []
      ),
    );

    calculateDistance();
    removeAllPolyLine();
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
  }

  updateLocationAndUi(LatLng newLocationData) async {
    debugPrint("location update ==> onLocationChanged");

      myLatLong = LatLng(newLocationData.latitude ?? 0.0, newLocationData.longitude ?? 0.0);
      animateCar(myLatLong);

      double calcDestinationInMtr = Global.calculateDistanceInMeter(originLatLong.latitude, originLatLong.longitude,DBPosition.latitude,DBPosition.longitude);
      if(calcDestinationInMtr <= 50){
        Global.showToast("Your Final Destination Reached");
        navigationStarted(false);
        locationReachedCounter = 0;
        await Future.delayed(const Duration(seconds: 1));
        removeAllPolyLine();
      }

      if(navigationStarted.value){
        if(latLongForDistCalcWhileDriving != null){
          double distanceInMeter = Global.calculateDistanceInMeter(myLatLong.latitude, myLatLong.longitude, latLongForDistCalcWhileDriving!.latitude, latLongForDistCalcWhileDriving!.longitude);
          if(distanceInMeter >= Helper.drawReRouteTimeMinMtr){
            originLatLong = PointLatLng(myLatLong.latitude,myLatLong.longitude);
            //drawRouteOnMap(wayPointsPolyWhileDriving);
            manageWayPointsAndDrawRoutes(wayPointsPolyWhileDriving);
            latLongForDistCalcWhileDriving = myLatLong;
          }
        }else{
          latLongForDistCalcWhileDriving = myLatLong;
        }
      }
  }

  moveCameraOnMyLocation(LatLng myLatLong, double mainBearings) async {
    final c = await mapController.future;
    camPosition = CameraPosition(
      target: myLatLong,
      zoom: 17,
      bearing: mainBearings,
    );
    c.animateCamera(CameraUpdate.newCameraPosition(camPosition));
  }

  speedCalculator(){
    speedCalcListner = Geolocator.getPositionStream().listen((speedPositions) {
      double speedMps = speedPositions.speed;
      double speedInKmDbl = speedMps * 3.6;
      speedInKm = (speedInKmDbl.toStringAsFixed(2)).obs;
      refreshKmTxt(true);
      refreshKmTxt(false);
    });
  }

  updateMap(){
    refreshMap(true);
    refreshMap(false);
  }

  String distanceInKMStr = "0";
  String durationOfDistance = "0 Mins";
  int tempCounter = 0;

  calculateDistance()async{
    if(tempCounter == 0){
      final googleMapsService = GoogleMapsService();
      final result = await googleMapsService.getTravelTime(
        origin: DBPosition.latitude.toString()+","+DBPosition.longitude.toString(),
        destination: originLatLong.latitude.toString()+","+originLatLong.longitude.toString(),
      );

      distanceInKMStr = result['distance'];
      durationOfDistance = result['duration'];
      refreshBottomSheet(true);
      refreshBottomSheet(false);
      tempCounter++;
    }else{
      if(tempCounter >= 3){
        tempCounter = 0;
      }else{
        tempCounter++;
      }
    }
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

    double angleOfCar = mainBearing;
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

}