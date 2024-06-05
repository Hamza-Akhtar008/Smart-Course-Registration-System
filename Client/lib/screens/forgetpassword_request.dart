import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../responsive.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgerPassword extends StatelessWidget {
  // Controllers for email, password, and OTP text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Flag to determine if OTP input is required
  bool isOTPRequired = false;

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
              text: ['Welcome to'' Smart Course Registration System'],
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
              Text(
                'Enter your email to reset password:',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  suffixStyle: TextStyle(color: Colors.black)
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  performLogin(context);
                },
                child: Text('Submit'),
              ),

            ],
          ),
        ),
      ),
    );
  }


  Future<void> performLogin(BuildContext context) async {
    // Get email, password, and OTP from text fields
    final email = emailController.text;



    // Ensure that email and password are not empty
    if (email.isEmpty ) {
      showLoginFailedToast("Please provide email");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/auth/reset_password_request'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'staff_email': email,

        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final bool otpRequired = responseData['otp'] || false;

        // If OTP is required, update the UI to include OTP input
        if (otpRequired) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('useremail', email);
          showLoginFailedToast("OTP sent to email for verification.");
          Navigator.pushNamed(context, "/forget_password");



        }



      } else {
        showLoginFailedToast("Invalid Email Address");
      }
    } catch (error) {
      print("Login failed: $error");
      showLoginFailedToast("An error occurred");
    }
  }

  void showLoginFailedToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void showLoginSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }
}
