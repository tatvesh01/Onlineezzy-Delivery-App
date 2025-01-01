import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onlineezzy/Controller/login_screen_controller.dart';
import 'package:onlineezzy/Models/saveRouteModel.dart';
import 'package:onlineezzy/Ui/MobileNumberScreen.dart';
import 'package:onlineezzy/Ui/customer_map_screen.dart';
import 'package:onlineezzy/Ui/db_map_screen.dart';
import 'package:onlineezzy/Utils/sPHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utils/helper.dart';
import '../Utils/global.dart';
import '../Utils/language.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  LoginScreenController loginScreenController =
      Get.put(LoginScreenController());

  @override
  Widget build(BuildContext context) {
    Global.deviceSize(context);

    return Scaffold(
      backgroundColor: Helper.bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
        child: SingleChildScrollView(
          child: Container(
            height: Global.sHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(Helper.iconImg),
                              // Add your image asset
                              fit: BoxFit.cover,
                            ),
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
                    const SizedBox(height: 10),
                    // "Login Now" Text
                    Text(
                      loginNow,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      enterDetailsToContinue,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Button 1
                        Obx(() => GestureDetector(
                          onTap: () => loginScreenController.selectButton(1),
                          child: Container(
                            width: Global.sWidth*0.42,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: loginScreenController.selectedButton.value == 1
                                  ? Helper.redColor
                                  : Helper.greyColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)
                              )
                            ),
                            child: Text(
                              deliveryBoy,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                        // Button 2
                        Obx(() => GestureDetector(
                          onTap: () => loginScreenController.selectButton(2),
                          child: Container(
                            width: Global.sWidth*0.42,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: loginScreenController.selectedButton.value == 2
                                  ? Helper.redColor
                                  : Helper.greyColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                )
                            ),
                            child: Text(
                              client,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                      ],
                    ),

                    SizedBox(height: 15,),

                    TextField(
                      controller: loginScreenController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        filled: true,
                        // Enables the background color
                        fillColor: Helper.whiteColor,
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                        hintText: email,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Helper.redColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password TextField
                    Obx(
                      () => loginScreenController.refreshPassword.value
                          ? TextField(
                              controller: loginScreenController.passwordController,
                              obscureText: loginScreenController.isObscured,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                filled: true,
                                fillColor: Helper.whiteColor,
                                prefixIcon:
                                    Icon(Icons.lock_outline, color: Colors.grey),
                                hintText: password,
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    loginScreenController.isObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    loginScreenController.isObscured =
                                        !loginScreenController.isObscured;
                                    loginScreenController.refreshPassword(false);
                                    loginScreenController.refreshPassword(true);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Helper.redColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ),

                    /*Container(
                      height: 55,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Helper.blackColor.withOpacity(0.8), width: 1),
                      ),
                      child: Obx(
                        () => DropdownButton<String>(
                          value: loginScreenController.selectedItem.value.isEmpty
                              ? null
                              : loginScreenController.selectedItem.value,
                          // Show hint if no selection
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          underline: const SizedBox(),
                          // Remove default underline
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          items: loginScreenController.dropdownItems
                              .map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              loginScreenController.updateSelectedItem(newValue);
                            }
                          },
                          hint: Text(
                            selectOption,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),*/

                    /*const SizedBox(height: 10),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Add your forgot password logic here
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Helper.redColor),
                        ),
                      ),
                    ),*/
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (loginScreenController
                                  .emailController.text.isNotEmpty &&
                              loginScreenController
                                  .passwordController.text.isNotEmpty /*&&
                              loginScreenController.selectedItem.value != ""*/) {

                            /*SPHelper.setRole(Helper.roleDeliveryBoy);
                            loginScreenController.loginUser(Helper.roleDeliveryBoy);*/

                            if(loginScreenController.selectedButton.value == 2){
                              SPHelper.setRole(Helper.roleCustomer);
                              loginScreenController.loginUser(Helper.roleCustomer);
                            }else{
                              SPHelper.setRole(Helper.roleDeliveryBoy);
                              loginScreenController.loginUser(Helper.roleDeliveryBoy);
                            }

                          } else {
                            Global.showToast(fillAllField);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Helper.redColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          login,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Helper.whiteColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => InfoDialog(
                            title: "Information",
                            message: "Express land and air delivery services\nIntegrated logistics services\nSpeed... Safety... Guarantee...",
                            assetImagePath: Helper.espLogo,
                            fbLink: "https://www.facebook.com/epspalestine",
                            mobileNo: "+972597332111",
                            email: "tareq@eps.ps",
                          ),
                        );
                      },
                      child: Text(
                        "Contracted with EPS",
                        style: TextStyle(
                          fontSize: 15,
                          color: Helper.blackColor,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),

                  ],
                ),
                Obx(() =>
                loginScreenController.isLoading.value ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: CircularProgressIndicator(color: Helper.redColor,),
                  ),
                ):SizedBox()
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String assetImagePath;
  final String fbLink;
  final String mobileNo;
  final String email;

  const InfoDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.assetImagePath,
    required this.fbLink,
    required this.mobileNo,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Helper.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                assetImagePath,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Title Section
            /*Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),*/

            // Message Section
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Helper.blackColor,
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Message Section
            InkWell(
              onTap: () async {
                var url = Uri.parse(fbLink);
                if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
                }
              },
              child: Text(
                fbLink,
                style: TextStyle(
                  fontSize: 12,
                  color: Helper.blackColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mobileNo,
              style: TextStyle(
                fontSize: 16,
                color: Helper.blackColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
           Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Helper.blackColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Helper.redColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Helper.whiteColor
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
