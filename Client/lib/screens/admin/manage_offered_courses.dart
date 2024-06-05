import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../Component/Editabledata.dart';
import '../dashboard/dashboard_screen.dart';
import '../main/components/side_menu.dart';

class ManageOfferedCourse extends StatefulWidget {
  @override
  _ManageOfferedCourseState createState() => _ManageOfferedCourseState();
}

class _ManageOfferedCourseState extends State<ManageOfferedCourse> {
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }
  Future<void> _fetchCourses() async {
    final url = 'http://localhost:5000/managecourse/getAllCourses';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> coursesData = json.decode(response.body);

        // Update the state with the retrieved courses
        setState(() {
          courses = List<Map<String, dynamic>>.from(coursesData);
          print(courses);
        });
      } else {
        // Handle the error
        print('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error fetching courses: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: Column(
                children: [
                  DashboardScreen(parameter: "Manage Offered Course"),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_new_course');

                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                        ),
                        child: Text('Add New Course'),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 52.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/offer_course');

                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                        ),
                        child: Text('Offer Course'),
                      ),
                    ),
                  ),
                  EditableDataTable(
                    headers: ['CourseID', 'Course_Name', 'Course_Type', 'Course_Description', 'Edit','Delete'],
                      data: courses,
                    deleteurl: 'http://localhost:5000/managecourse/deleteCourse', editurl:'http://localhost:5000/managecourse/editCourse',
                    redirect: '/manage_offered_courses',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
