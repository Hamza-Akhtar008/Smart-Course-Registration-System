import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../Component/Editabledata.dart';
import '../main/components/side_menu.dart'; // Adjust the import path

class ManageDepartment extends StatefulWidget {
  @override
  _ManageDepartmentState createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  List<Map<String, dynamic>> departments = [];

  @override
  void initState() {
    super.initState();
    // Call the method to fetch data when the widget is first created
    fetchData();
  }

  Future<void> fetchData() async {
    final url = 'http://localhost:5000/managedepart/getalldepart';
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
        // If the server returns a 200 OK response, parse the JSON
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Assuming your data is under a key like 'data'
        final List<dynamic> departmentData = responseData['data'];

        setState(() {
          departments = List<Map<String, dynamic>>.from(departmentData);
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load data');
      }
    } catch (error) {
      // Handle errors
      print('Error fetching data: $error');
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
            // We want this side menu only for a large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardScreen(parameter: "Manage Department"),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(right: 30.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_new_department');
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                          ),
                          child: Text('Add New Department'),
                        ),
                      ),
                    ),
                    EditableDataTable(
                      headers: ['depart_id', 'depart_name', 'Edit', 'Delete'],
                      data: departments,
                      deleteurl: 'http://localhost:5000/managedepart/delete_depart',
                      editurl: 'http://localhost:5000/managedepart/edit_depart',
                      redirect: '/manage_department',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
