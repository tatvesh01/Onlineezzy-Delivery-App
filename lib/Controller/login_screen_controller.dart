import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onlineezzy/Models/userLoginModel.dart';
import 'package:onlineezzy/Ui/MobileNumberScreen.dart';
import 'package:onlineezzy/Ui/ParcelListScreen.dart';
import 'package:onlineezzy/Utils/global.dart';
import 'package:onlineezzy/Utils/helper.dart';
import 'package:onlineezzy/Utils/language.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onlineezzy/Utils/sPHelper.dart';

class LoginScreenController extends GetxController{

  bool isObscured = true;
  RxBool refreshPassword = true.obs;
  var selectedItem = "".obs;
  var isLoading = false.obs;
  final dropdownItems = [imCustomer, imDeliveryBoy];
  //DB
  /*TextEditingController emailController = TextEditingController(text: "009");
  TextEditingController passwordController = TextEditingController(text: "2jldf3hEnl%X3ZBfvc(E2@%23H");*/
  //customer
  /*TextEditingController emailController = TextEditingController(text: "test007");
  TextEditingController passwordController = TextEditingController(text: "J8of%KpKbo%(wISBQNNBrYGl");*/
  //original
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var selectedButton = 1.obs;


  @override
  void onInit() {
    super.onInit();
  }

  void updateSelectedItem(String value) {
    selectedItem.value = value;
  }

  void selectButton(int buttonIndex) {
    selectedButton.value = buttonIndex;
  }

  Future<void> loginUser(String userRole) async {
    isLoading.value = true;
    final url = Uri.parse(Helper.loginApi+"${emailController.text}"+"&password="+passwordController.text);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final authResponse = UserLoginModel.fromJson(jsonData);

        if(userRole == Helper.roleCustomer){
          if(authResponse.role == "customer"){
            SPHelper.setName(authResponse.userDisplayName);
            SPHelper.setBearer(authResponse.token);
            SPHelper.setUserId(authResponse.userId);
            Get.to(()=>MobileNumberScreen());
          }else{
            Global.showToast(thisIsNotCustomerCred);
          }
        }else{
          if(authResponse.role == "delivery_person"){
            SPHelper.setBearer(authResponse.token);
            SPHelper.setUserId(authResponse.userId);
            Get.to(()=>ParcelListScreen(),arguments: [authResponse.token]);
          }else{
            Global.showToast(thisIsNotDBCred);
          }
        }
      } else {
        Global.showToast(failedToFetchData);
      }
    } catch (e) {
      Global.showToast(somethingWrong);
    }finally{
      isLoading.value = false;
    }
  }





}