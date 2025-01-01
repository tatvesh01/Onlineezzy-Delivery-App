import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:onlineezzy/Controller/db_map_screen_controller.dart';
import 'package:onlineezzy/Models/CustomerParcelListModel.dart';
import '../Utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../Utils/global.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DBMapScreen extends StatelessWidget {
  DBMapScreen({Key? key}) : super(key: key);

  DBMapScreenController mapNavSCont = Get.put(DBMapScreenController());

  @override
  Widget build(BuildContext context) {
    mapNavSCont.tempContext = context;
    Global.deviceSize(context);
    return WillPopScope(
      onWillPop: () async{
        mapNavSCont.mapController = Completer();
        mapNavSCont.locationSubscription.cancel();
        try{mapNavSCont.speedCalcListner.cancel();}catch(e){}
        Global.stopKeepScreenOn();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Navigation',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
          centerTitle: true,
          backgroundColor: Helper.whiteColor,
          actions: [

            Obx(()=>
            mapNavSCont.isDragged.value ?
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: (){
                  mapNavSCont.recenterBtnPressed();
                },
                child: Icon(Icons.filter_center_focus,color: Helper.redColor,size: 25),
              ),
            ):Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.filter_center_focus,color: Helper.greyColor,size: 25,),
            ),
            ),

            ],
          /*widgets: [Obx(()=> mapNavSCont.navigationStarted.value ? !mapNavSCont.refreshKmTxt.value ? Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text("${mapNavSCont.speedInKm.value} km/h",style: TextStyle(color: Helper.whiteColor,fontSize: 15,fontWeight: FontWeight.w500),),
        ):SizedBox() :SizedBox())]*/),

        body: Container(
          height: Global.sHeight,
          width: Global.sWidth,
          color: Helper.bgColor,
          child: Stack(
            children: [
              mapBox(),
              bottomSheet(),

            ],
          ),
        ),
      ),
    );
  }

  Widget mapBox() {
    return Obx(() => mapNavSCont.refreshMap.value
        ? SizedBox()
        : Container(
      height: Global.sHeight-150,
      width: Global.sWidth,
      child: Listener(
        onPointerDown: (PointerDownEvent event){
          mapNavSCont.isDragged(true);
        },
        child: GoogleMap(
          //myLocationEnabled: true,
          mapType: MapType.terrain,
          initialCameraPosition: mapNavSCont.camPosition,
          polylines:
          Set<Polyline>.of(mapNavSCont.polylines.values),
          markers: Set<Marker>.of(mapNavSCont.markers.values),
          onCameraMove: mapNavSCont.whenCameraMove,
          onMapCreated: (GoogleMapController controller) {
            mapNavSCont.googleMapCreated(controller);
          },
        ),
      ),
    ));
  }

  Widget navigationButton(BuildContext context) {
    return SizedBox(
      width: Global.sWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          SizedBox(height: 5,),

      Obx(()=>
          mapNavSCont.finalDestinationReached.value ?
          InkWell(
            onTap: (){
              mapNavSCont.changeStatusOfParcel("تم التسليم"); // Delivered
              mapNavSCont.sendNotification(false); // Delivered notification
              Get.back();
            },
            child: Container(
              height: 50,
              width: Global.sWidth * 0.5,
              decoration: BoxDecoration(
                  color: Helper.redColor,
                  borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: Center(child: Text("تم التسليم",style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.w500),)),
            ),
          ):InkWell(
            onTap: (){

              if(mapNavSCont.navigationStarted.value){
                //mapNavSCont.changeStatusOfParcel("Postpone");
                mapNavSCont.navigationStarted(false);
                mapNavSCont.locationSubscription.pause();
                mapNavSCont.speedCalcListner.cancel();
              }else{
                mapNavSCont.changeStatusOfParcel("في طريق"); // On the way
                mapNavSCont.sendNotification(true); // On the way notification
                mapNavSCont.navigationStarted(true);
                mapNavSCont.locationSubscription.resume();
                mapNavSCont.showVehicleOnMyLocation();
                mapNavSCont.speedCalculator();
              }
            },
            child: Container(
              height: 50,
              width: Global.sWidth * 0.5,
              decoration: BoxDecoration(
                  color: Helper.redColor,
                  borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child:  Center(child: Text(!mapNavSCont.navigationStarted.value ? "في طريق" :  "يلغي",style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.w500),))
            ),
          ),
          ),

          SizedBox(height: 15,)

        ],
      ),
    );
  }

  Widget bottomSheet(){
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // Height when sheet is collapsed
      minChildSize: 0.12,     // Minimum height
      maxChildSize: 0.5,     // Maximum height when expanded
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                Obx(() => Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: Helper.lightGreyColor
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0,right: 5),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Icon(Icons.location_pin, color: Colors.orange,size: 25,),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: mapNavSCont.refreshBottomSheet.value?SizedBox():Text(mapNavSCont.mapDataForNavigation.allAddress[0],style: TextStyle(color: Helper.blackColor,fontWeight: FontWeight.w500),maxLines: 1,overflow: TextOverflow.ellipsis,),
                        )
                      ],
                    ),
                  ),
                ),),

                SizedBox(height: 10,),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoTile(Icons.map, !mapNavSCont.refreshBottomSheet.value ? '${mapNavSCont.distanceInKMStr}' : "0 km", 'Distance'),
                    _buildInfoTile(Icons.access_time, mapNavSCont.durationOfDistance.toString(), 'Duration'),
                  ],
                ),),
                SizedBox(height: 15,),
                navigationButton(context),

              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildInfoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

}
