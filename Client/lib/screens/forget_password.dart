import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../responsive.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTPScreenForgetPassword extends StatefulWidget {




  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreenForgetPassword> {
  final TextEditingController otpController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: buildMobileLayout(context),
      tablet: buildTabletLayout(context),
      desktop: buildDesktopLayout(context),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              child: Image.asset('assets/images/main.jpeg', fit: BoxFit.fill),
            ),
            buildAnimatedText(context),
            buildImageAboveForm(context),
            buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    color: Color(0xFFF3F4F6),
                    child: Image.asset('assets/images/main.jpeg', fit: BoxFit.fill),
                  ),
                  buildAnimatedText(context),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  buildImageAboveForm(context),
                  buildForm(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Color(0xFFF3F4F6),
                  child: Image.asset('assets/images/main.jpeg', fit: BoxFit.fill),
                ),
                buildAnimatedText(context),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                buildImageAboveForm(context),
                buildForm(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedText(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2,
      left: 50,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          children: [
            TypewriterAnimatedTextKit(
              totalRepeatCount: 100,
              speed: Duration(milliseconds: 200),
              pause: Duration(milliseconds: 1000),
              text: ['Welcome to Smart Course Registration System'],
              textStyle: TextStyle(
                color: Color(0xFFF3F4F6),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageAboveForm(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 3,
      child: Image.asset('assets/images/background.png'),
    );
  }

  Widget buildForm(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OTP',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: otpController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: Color(0xFF334155),
                    ),
                    hintText: 'Enter OTP',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    sendOTP(context); // Call the sendOTP function
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xFF334155),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          ' Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendOTP(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email=  prefs.getString('useremail');

      final response = await http.post(
        Uri.parse('http://localhost:5000/auth/reset_password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_email':email,
          'otp':otpController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        showSuccessToast(responseData['message']);
        Navigator.pushNamed(context, "/");
      } else {
        showErrorToast("Failed to send OTP");
      }
    } catch (error) {
      print("Failed to send OTP: $error");
      showErrorToast("An error occurred");
    }
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }
}
