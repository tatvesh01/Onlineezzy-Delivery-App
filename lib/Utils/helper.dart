import 'dart:ui';

class Helper{

  //colors
  static Color bgColor = const Color(0xFFFFFFFF);
  static Color whiteColor = const Color(0xFFFFFFFF);
  static Color blackColor = const Color(0xFF000000);
  static Color greyColor = const Color(0xFFB2B2B2);
  static Color lightGreyColor = const Color(0xA0F1F0F0);
  static Color redColor = const Color(0xFFBB0025);
  static Color redColorLight = const Color(0xFFEE0B4D);
  static Color lightBlueColor = const Color(0xFF3FBCFF);
  static Color lightGreenColor = const Color(0xFF3EA61D);
  static Color transparentColor = const Color(0xFFFFFF);
  static Color polyLineColor = const Color(0xFF2222FF);

  //images
  static String deliveryVanImg = "assets/images/delivery_van.png";
  static String iconImg = "assets/images/app_icon.png";
  static String carImg = "assets/images/car_img.png";
  static String customerPinImg = "assets/images/customer_pin.png";
  static String menuIconImg = "assets/images/menu_icon.png";
  static String espLogo = "assets/images/esp_logo.jpeg";

  static int destReachTimeMinMtr = 50;
  static int drawDotedRouteAgainAfterDriveMeters = 5;
  static int drawReRouteTimeMinMtr = 8;

  static String roleCustomer = "customer";
  static String roleDeliveryBoy = "deliveryBoy";

  static String deliveryBoyForFB = "DeliveryBoy";


  //API URL

  static String loginApi = "https://********.com/wp-json/jwt-auth/v1/token?username=";
  static String getParcelListForCustomer = "https://********.com/wp-json/custom/v1/GetPackage?userId=";
  static String getParcelListForDB = "https://********.com/wp-json/custom/v1/GetPackages";
  static String updateParcelStatusApi = "https://********.com/wp-json/custom/v1/updateStatus";

  static String googleTimeCalcApi = "https://********.com/maps/api/directions/json";
  static String notificationApi = "https://********.io/api/create-message";

}