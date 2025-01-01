import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:onlineezzy/Models/CustomerParcelListModel.dart';
import 'package:onlineezzy/Models/parcelListModel.dart';
import 'package:onlineezzy/Utils/global.dart';
import 'dart:convert';

import 'package:onlineezzy/Utils/helper.dart';
import 'package:onlineezzy/Utils/language.dart';


class ParcelListController extends GetxController {
  var isLoading = false.obs;
  List<ParcelListModel> parcelList = [];
  RxInt openSubListIndex = 55555555.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    fetchParcel();
    Global.requestLocationPermission();
    super.onInit();
  }

  Future<void> fetchParcel() async {
    isLoading.value = true;
    String token = Get.arguments[0];
    var headers = {
      'Authorization': 'Bearer ${token}'
    };

    final url = Uri.parse('${Helper.getParcelListForDB}');

    try {
      final response = await http.get(url,headers: headers);

      if (response.statusCode == 200) {
        //parcelList = ParcelListModel.fromJson(json.decode(response.body));

        final List<dynamic> parsedJson = json.decode(response.body);
        parcelList = parsedJson.map((item) => ParcelListModel.fromJson(item)).toList();

      } else {
        parcelList = [];
        Global.showToast(failedToFetchData);
      }
    } catch (e) {
      parcelList = [];
      Global.showToast(somethingWrong);
    } finally {
      isLoading.value = false;
    }
  }
}