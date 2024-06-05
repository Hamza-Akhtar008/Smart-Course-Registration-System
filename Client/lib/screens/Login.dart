import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../responsive.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
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
              const Text(
                'Email',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: Color(0xFF334155)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xFF334155),
                    ),
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Color(0xFF334155)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Password',
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
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xFF334155),
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // Check if OTP is required
              if (isOTPRequired)
                Column(
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
                  ],
                ),
              const SizedBox(height: 35),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    // Navigate to the forgot password screen
                    Navigator.pushNamed(context, "/forgot_password_request");
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    performLogin(context);
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
                          ' Log In',
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

  Future<void> performLogin(BuildContext context) async {
    // Get email, password, and OTP from text fields
    final email = emailController.text;
    final password = passwordController.text;


    // Ensure that email and password are not empty
    if (email.isEmpty || password.isEmpty) {
      showLoginFailedToast("Please provide email and password");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'staff_email': email,
          'staff_password': password,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final bool otpRequired = responseData['otp'] || false;

        // If OTP is required, update the UI to include OTP input
        if (otpRequired) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('useremail', email);
          print(email);
Navigator.pushNamed(context, "/otp_screen");
        }
        else
          {
            final String token = responseData['token'];
            final String userType = responseData['userType'];
            final String userid = responseData['userid'];

            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('token', token);
            prefs.setString('usertype', userType);
            prefs.setString('userid', userid);

            showLoginSuccessToast('${responseData['message']}');

            Navigator.pushNamed(context, "/dashboard");
          }


      } else {
        showLoginFailedToast("Invalid credentials");
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
