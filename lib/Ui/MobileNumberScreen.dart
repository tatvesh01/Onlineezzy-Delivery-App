import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onlineezzy/Models/saveRouteModel.dart';
import 'package:onlineezzy/Ui/customer_map_screen.dart';
import '../Utils/language.dart';
import 'package:onlineezzy/Controller/MobileNumberController.dart';
import 'package:onlineezzy/Utils/global.dart';
import 'package:onlineezzy/Utils/helper.dart';

class MobileNumberScreen extends StatelessWidget {
  final MobileNumberController controller = Get.put(MobileNumberController());

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
          yourParcel,
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
                        controller.fetchCustomerPackage();
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
          // Search Bar
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              alignment: Alignment.center,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 8,
                    child: TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: enterMobileNumber,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 8)
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: (){
                        if(controller.phoneController.text.length > 9){
                          controller.fetchCustomerPackage(controller.phoneController.text);
                        }else{
                          Global.showToast(enterCorrectMobileNumber);
                        }
                      },
                      child: Container(
                        height: 40,
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
                        child: Text(submit,style: TextStyle(color: Helper.whiteColor,fontSize: 14,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),*/

          // Frequently Ordered Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                yourOrder,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Medicines List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Helper.redColor,),
                );
              }

              if (controller.parcelList == null) {
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
                itemCount: controller.parcelList!.statusAndTrackingIds.length,
                itemBuilder: (context, index) {
                  final item = controller.parcelList!.statusAndTrackingIds[index];
                  return MedicineCard(
                    imageUrl: item.imageUrl!,
                    title: item.trackingId,
                    description: item.dateAdded.toString(),
                    status: item.status,
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
  final String title;
  final String description;
  final String status;
  final String imageUrl;
  final MobileNumberController cont;

  MedicineCard({
    required this.title,
    required this.description,
    required this.status,
    required this.imageUrl,
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medicine Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Text(
                  cont.customerName,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),*/
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          status == "في طريق" ?  InkWell(
            onTap: (){
              SaveRouteModel mapDataForNavigation = SaveRouteModel(wayPointsForSaveData: [[cont.parcelList!.latitude, cont.parcelList!.longitude]], allAddress: [cont.parcelList!.address]);
              //SaveRouteModel mapDataForNavigation = SaveRouteModel(wayPointsForSaveData: [["21.2300", "72.9009"]], allAddress: ["Abc complex"]);
              Get.to(()=>CustomerMapScreen(),arguments: [mapDataForNavigation, cont.parcelList!.user])?.then((value) {
                if (value == true) {
                  cont.fetchCustomerPackage();
                }
              });

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
          ) :SizedBox()

        ],
      ),
    );
  }
}