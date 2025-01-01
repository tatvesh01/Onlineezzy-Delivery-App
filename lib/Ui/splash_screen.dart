import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utils/helper.dart';
import '../Controller/splash_screen_controller.dart';
import '../Utils/global.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  SplashScreenController splashScreenController = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {

    Global.deviceSize(context);

    return Scaffold(
      backgroundColor: Helper.bgColor,
      body: Container(
        height: Global.sHeight,
        width: Global.sWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Helper.deliveryVanImg,height: 200,width: 200,),
            SizedBox(height: 20,),
            Text(
              "Onlineezzy",
              style: TextStyle(color: Helper.blackColor, fontSize: 20,fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
