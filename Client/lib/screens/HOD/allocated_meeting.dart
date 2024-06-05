import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import 'package:smart_course_registration_system/screens/main/components/side_menuStudent.dart';

import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_screenhod.dart';
import '../main/components/side_menuHod.dart';

class AllocateMeeting extends StatefulWidget {
  @override
  _AllocateMeeting createState() => _AllocateMeeting();
}

class _AllocateMeeting extends State<AllocateMeeting> {
  List<Map<String, dynamic>> applications = [];
  List<Map<String, dynamic>> course = [];
  TextEditingController hodCommentController = TextEditingController(); // Controller for HOD comment
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';
    String student_id = prefs.getString('student_id') ?? '';
    String applicationId = prefs.getString('applicationId') ?? '';
    final data = {'student_id': student_id, 'applicationId': applicationId};
    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/registrationappication/get_registrationApplication'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('registrationapp')) {
        Map<String, dynamic> registrationAppData = responseData['registrationapp'];

        // Extract course information
        List<dynamic> coursesJson = json.decode(registrationAppData['courses']);
        List<Map<String, dynamic>> courses = List<Map<String, dynamic>>.from(coursesJson);
        print(courses);
        setState(() {
          // Set registration application data
          applications = [registrationAppData];
          course = courses;
          // Set courses data
        });
      } else {
        print('No registration application found.');
      }
    } else {
      throw Exception('Failed to load applications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenuHOD(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) SideMenuHOD(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreenHOD(parameter: "Allocate Meeting"),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity, // Take full width
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF334155),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Meeting Details:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select Date and Time:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },

                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF334155),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [

                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                selectedDate != null
                                    ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                                    : 'Select Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null && pickedTime != selectedTime) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF334155),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                selectedTime != null
                                    ? 'Selected Time: ${selectedTime!.format(context)}'
                                    : 'Select Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (!isApplicationProcessed()) // Check if application is not already approved or rejected
                        Column(
                          children: [

                            SizedBox(height: 20),

                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _approveApplication(),
                                  child: Text('Allocate'),
                                ),


                              ],
                            ),
                          ],
                        ),
                      if (isApplicationProcessed()) // If application is already processed
                        Center(

                          child: Text(
                            'Date Time Already Allocated',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isApplicationProcessed() {
   if(applications.isNotEmpty)
     {
       if(applications[0]['meeting_date']!=null && applications[0]["meeting_time"]!=null)
         {
           return true;
         }
       else
         {
           return false;
         }
     }
   else
     {
       return true;
     }

  }


  void _approveApplication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String meeting_id = prefs.getString('meeting_id') ?? " ";
    String student_id = prefs.getString('student_id') ?? '';

    // Format the selected date and time into strings
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime = selectedTime!.format(context);

    final Map<String, dynamic> data = {
      'student_id': student_id,
      'meeting_id': meeting_id,
      'meeting_date': formattedDate, // Pass formatted date string
      'meeting_time': formattedTime, // Pass formatted time string
    };

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse('http://localhost:5000/meeting/allocate_meeting');

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      showLoginFailedToast("Meeting Date Time Allocated  Successfully");
      Navigator.pushNamed(context, '/schedule_meeting');
    } else {
      showLoginFailedToast("Meeting Date Time Not Allocated Successfully");
      Navigator.pushNamed(context, '/schedule_meeting');
    }
  }


  void showLoginFailedToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red, // Red color for failure
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
