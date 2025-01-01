import 'package:get/get.dart';
import '../Ui/login_screen.dart';
import '../Utils/sPHelper.dart';

class SplashScreenController extends GetxController{

  @override
  void onInit() {

    SPHelper.sharedPrefInit();
    redirectScreen();
    super.onInit();
  }

  void redirectScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(()=>LoginScreen());
    });
  }


}