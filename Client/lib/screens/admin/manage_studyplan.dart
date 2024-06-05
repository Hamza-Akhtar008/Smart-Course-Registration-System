import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../Component/Editabledata.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main/components/side_menu.dart';

class ManageStudyPlan extends StatefulWidget {


  @override
  _ManageStudyPlanState createState() => _ManageStudyPlanState();
}

class _ManageStudyPlanState extends State<ManageStudyPlan> {
  List<Map<String, dynamic>> studyPlans = [];

  @override
  void initState() {
    super.initState();
     getAllStudyPlans();
  }

   Future<void> getAllStudyPlans() async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     final String? token = prefs.getString('token');
     final Map<String, String> headers = {
       'Authorization': '${token}',
       'Content-Type': 'application/json', // Add any other headers you need
     };
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/managestudyplan/gettallstudplans'),headers: headers);

      if (response.statusCode == 200) {
        // Parse the response JSON and return the data
        final List<dynamic> responseData = json.decode(response.body)['data'];

        setState(() {
          studyPlans = List<Map<String, dynamic>>.from(responseData);

        });

      } else {
        // Handle other status codes or errors
        print('Error fetching study plans: ${response.statusCode}');

      }
    } catch (error) {
      // Handle network errors
      print('Network error: $error');

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
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  DashboardScreen(parameter: "Manage Study Plan"),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_new_study_plan');
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                        ),
                        child: Text('Add New Study Plan'),
                      ),
                    ),
                  ),
                  EditableDataTable(
                    headers: ['studplanid', 'depart_id', 'batch_id', 'studyplan_details', 'Edit', 'Delete'],
                    data:studyPlans,
                    deleteurl: 'http://localhost:5000/managestudyplan/deletestudyplan',
                    editurl: 'http://localhost:5000/managestudyplan/editStudyPlanbyid',
                    redirect: '/manage_study_plan',
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
