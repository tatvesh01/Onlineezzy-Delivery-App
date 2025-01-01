import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:onlineezzy/Controller/customer_map_screen_controller.dart';
import '../Utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../Utils/global.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerMapScreen extends StatelessWidget {
  CustomerMapScreen({Key? key}) : super(key: key);

  CustomerMapScreenController customerMapScreenCont = Get.put(CustomerMapScreenController());

  @override
  Widget build(BuildContext context) {
    Global.deviceSize(context);
    return WillPopScope(
      onWillPop: () async{
        customerMapScreenCont.mapController = Completer();
        try{customerMapScreenCont.locationSubscription.cancel();}catch(e){}
        try{customerMapScreenCont.speedCalcListner.cancel();}catch(e){}
        Global.stopKeepScreenOn();
        Get.back(result: true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Navigation',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
          centerTitle: true,
          backgroundColor: Helper.whiteColor,
          actions: [

            Obx(()=>
            customerMapScreenCont.isDragged.value ?
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: (){
                  customerMapScreenCont.recenterBtnPressed();
                },
                child: Icon(Icons.filter_center_focus,color: Helper.redColor,size: 25),
              ),
            ):Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.filter_center_focus,color: Helper.greyColor,size: 25,),
            ),
            ),

            ],
          /*widgets: [Obx(()=> customerMapScreenCont.navigationStarted.value ? !customerMapScreenCont.refreshKmTxt.value ? Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text("${customerMapScreenCont.speedInKm.value} km/h",style: TextStyle(color: Helper.whiteColor,fontSize: 15,fontWeight: FontWeight.w500),),
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
    return Obx(() => customerMapScreenCont.refreshMap.value
        ? SizedBox()
        : Container(
      height: Global.sHeight-250,
      width: Global.sWidth,
      child: Listener(
        onPointerDown: (PointerDownEvent event){
          customerMapScreenCont.isDragged(true);
        },
        child: GoogleMap(
          //myLocationEnabled: true,
          mapType: MapType.terrain,
          initialCameraPosition: customerMapScreenCont.camPosition,
          polylines:
          Set<Polyline>.of(customerMapScreenCont.polylines.values),
          markers: Set<Marker>.of(customerMapScreenCont.markers.values),
          onCameraMove: customerMapScreenCont.whenCameraMove,
          onMapCreated: (GoogleMapController controller) {
            customerMapScreenCont.googleMapCreated(controller);
          },
        ),
      ),
    ));
  }

  Widget bottomSheet(){
    return DraggableScrollableSheet(
      initialChildSize: 0.25, // Height when sheet is collapsed
      minChildSize: 0.25,     // Minimum height
      maxChildSize: 0.25,     // Maximum height when expanded
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
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
                        child: customerMapScreenCont.refreshBottomSheet.value?SizedBox():Text(customerMapScreenCont.mapDataForNavigation.allAddress[0],style: TextStyle(color: Helper.blackColor,fontWeight: FontWeight.w500),maxLines: 1,overflow: TextOverflow.ellipsis,),
                      )
                    ],
                  ),
                ),
              ),),

              SizedBox(height: 10,),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile(Icons.map, !customerMapScreenCont.refreshBottomSheet.value ? '${customerMapScreenCont.distanceInKMStr}' : "0 km", 'Distance'),
                  _buildInfoTile(Icons.access_time, customerMapScreenCont.durationOfDistance.toString(), 'Duration'),
                ],
              ),)
            ],
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
