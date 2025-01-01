import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onlineezzy/Models/parcelListModel.dart';
import 'package:onlineezzy/Models/saveRouteModel.dart';
import 'package:onlineezzy/Ui/db_map_screen.dart';
import '../Utils/language.dart';
import 'package:onlineezzy/Controller/ParcelListController.dart';
import 'package:onlineezzy/Utils/global.dart';
import 'package:onlineezzy/Utils/helper.dart';
import 'package:onlineezzy/Models/ParcelListModel.dart' as CPM;

class ParcelListScreen extends StatelessWidget {
  ParcelListController controller = Get.put(ParcelListController());
  final TextEditingController phoneController = TextEditingController(text: "212626824018");

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Helper.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          yourPickUp,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(Helper.menuIconImg,height: 25,width: 25,),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          Obx(() =>
              Container(
                margin: EdgeInsets.only(right: 8),
                  alignment: Alignment.center,
                  height: 20,
                  width: 20,
                  child: !controller.isLoading.value?
                  InkWell(
                    onTap: (){
                      controller.fetchParcel();
                    },
                    child: Icon(Icons.refresh, color: Colors.black),
                  ) : CircularProgressIndicator(color: Helper.blackColor,strokeWidth: 3,)),),

          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Helper.redColor,
              ),
              child:  Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(Helper.iconImg),
                        // Add your image asset
                        fit: BoxFit.cover,
                      ),
                      color: Helper.whiteColor,
                      border: Border.all(color: Helper.whiteColor,width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Overlapping badge
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home',style: TextStyle(fontWeight: FontWeight.w500),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout',style: TextStyle(fontWeight: FontWeight.w500),),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          SizedBox(height: 10,),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Helper.redColor,),
                );
              }

              if (controller.parcelList.isEmpty) {
                return Center(
                  child: Text(
                    noDataFound,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black54,),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.parcelList.length,
                itemBuilder: (context, index) {
                  final item = controller.parcelList[index];
                  return MedicineCard(
                    name: item.name,
                    email: item.email,
                    mobile: item.phone,
                    dest: item.destination,
                    allData: item.statusAndTrackingIdsDB,
                    numbers: index,
                    cont: controller
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
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
                  Icons.logout,
                  size: 60,
                  color: Helper.redColor,
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Do you want to logout from the application?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Helper.greyColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Helper.whiteColor),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Helper.redColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: Text('Logout',style: TextStyle(color: Helper.whiteColor),),
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

class MedicineCard extends StatelessWidget {
  final String name;
  final String email;
  final String mobile;
  final String dest;
  final List<StatusAndTrackingIdDB> allData;
  final int numbers;
  final ParcelListController cont;

  MedicineCard({
    required this.name,
    required this.email,
    required this.mobile,
    required this.dest,
    required this.allData,
    required this.numbers,
    required this.cont,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mobile,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dest,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: (){

                  if(cont.parcelList[numbers].latitude == "" || cont.parcelList[numbers].longitude == "" || cont.parcelList[numbers].phone == ""){
                    Global.showToast("Delivery Coordinates or Phone number does not exist, wait until assigned.");
                  }else{
                    SaveRouteModel mapDataForNavigation = SaveRouteModel(wayPointsForSaveData: [[cont.parcelList[numbers].latitude, cont.parcelList[numbers].longitude]], allAddress: [dest]);
                    Get.to(()=>DBMapScreen(),arguments: [mapDataForNavigation,cont.parcelList[numbers].statusAndTrackingIdsDB,cont.parcelList[numbers].id,cont.parcelList[numbers].phone,cont.parcelList[numbers].name]);
                  }
                },
                child: Container(
                  height: 35,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Helper.redColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(track,style: TextStyle(color: Helper.whiteColor,fontSize: 12,fontWeight: FontWeight.bold),),
                ),
              )

            ],
          ),

          /*Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: (){
                if(numbers == cont.openSubListIndex.value){
                  cont.openSubListIndex.value = 555555555;
                }else{
                  cont.openSubListIndex.value = numbers;
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Obx(()=>
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(numbers != cont.openSubListIndex.value ? "${viewMore}" : "${viewLess}",style: TextStyle(color: Helper.greyColor,fontSize: 14,fontWeight: FontWeight.bold),),
                      Text(" (${allData.length}) ",style: TextStyle(color: Helper.greyColor,fontSize: 14,fontWeight: FontWeight.bold),),
                      Transform.rotate(angle:numbers == cont.openSubListIndex.value ? 3.14159 : 0,child: Icon(Icons.expand_circle_down_outlined, color: Helper.greyColor,size: 17)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),

          Obx(() => numbers == cont.openSubListIndex.value ?
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Helper.lightGreyColor,
              borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: allData.length,
              itemBuilder: (context, nestedIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Status: "+allData[nestedIndex].status.toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                   *//* SizedBox(height: 2),
                    Text(
                      "Updated At: "+allData[nestedIndex].lastUpdate.toString(),
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),*//*
                    Divider(),
                    SizedBox(height: 4),
                  ],
                );
              },
            ),
          ) :SizedBox(),)*/
        ],
      ),
    );
  }

}