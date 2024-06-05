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

class ManageStudent extends StatefulWidget {
  @override
  _ManageStudentState createState() => _ManageStudentState();
}

class _ManageStudentState extends State<ManageStudent> {
  List<Map<String, dynamic>> studentData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/managestudentrecords/get_all_student'), headers: headers,);
      if (response.statusCode == 200) {
        // Assuming your API response is a JSON array
        List<dynamic> responseData = json.decode(response.body)['students'];

        setState(() {
          studentData = List<Map<String, dynamic>>.from(responseData);
          print(studentData);
        });
      } else {
        // Handle errors
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error loading data: $error');
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
                  DashboardScreen(parameter: "Manage Student Records"),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_new_student');
                          // Handle the action for adding a new student
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                        ),
                        child: Text('Add New Student Records'),
                      ),
                    ),
                  ),
                  EditableDataTable(
                    headers: ['student_id', 'student_name', 'student_email', 'student_contact', 'student_address','batch_id','depart_id', 'Edit', 'Delete'],
                    data: studentData,
                    deleteurl: 'http://localhost:5000/managestudentrecords/delete_studnt',
                    editurl: 'http://localhost:5000/managestudentrecords/edit_student',
                    redirect: '/manage_student',
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
