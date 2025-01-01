import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onlineezzy/Models/CustomerParcelListModel.dart';
import 'package:onlineezzy/Utils/global.dart';
import 'dart:convert';

import 'package:onlineezzy/Utils/helper.dart';
import 'package:onlineezzy/Utils/language.dart';
import 'package:onlineezzy/Utils/sPHelper.dart';

class MobileNumberController extends GetxController {
  var isLoading = false.obs;
  CustomerParcelListModel? parcelList;
  //final TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
      // TODO: implement onInit
    Global.requestLocationPermission();
    fetchCustomerPackage();
    super.onInit();
  }

  Future<void> fetchCustomerPackage() async {
    isLoading.value = true;
    int userId = await SPHelper.getUserId();
    String token = await SPHelper.getBearer();

    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${token}'
    };

    final url = Uri.parse('${Helper.getParcelListForCustomer}$userId');

    try {
      final response = await http.get(url,headers: headers);

      if (response.statusCode == 200) {
        parcelList = CustomerParcelListModel.fromJson(json.decode(response.body));
      } else {
        parcelList = null;
        Global.showToast(failedToFetchData);
      }
    } catch (e) {
      parcelList = null;
      Global.showToast(somethingWrong);
    } finally {
      isLoading.value = false;
    }
  }
}