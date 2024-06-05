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
class ManageBatchAdvisor extends StatefulWidget {
  @override
  _ManageBatchAdvisorState createState() => _ManageBatchAdvisorState();
}
class _ManageBatchAdvisorState extends State<ManageBatchAdvisor> {
  List<Map<String, dynamic>> batchAdvisors = [];
  @override
  void initState() {
    super.initState();
    // Call the method to fetch data when the widget is first created
    fetchData();
  }

  Future<void> fetchData() async {
    final url = 'http://localhost:5000/managebatch_advisor/getallbatchadvisor'; // Replace with your API endpoint
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
        final List<dynamic> hodsData = responseData['data'];

        setState(() {

          batchAdvisors = List<Map<String, dynamic>>.from(hodsData);

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
                  DashboardScreen(parameter: "Manage Batch Advisor"),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_new_batch_advisor');
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
                        ),
                        child: Text('Add New Batch Advisor'),
                      ),
                    ),
                  ),
                  EditableDataTable(
                    headers: ['AdvisorID', 'depart_id','batch_id', 'advisor_name', 'advisor_email', 'advisor_contact','Edit','Delete'],
                      data: batchAdvisors,
                    deleteurl: 'http://localhost:5000/managebatch_advisor/delete_advisor',
                    editurl:'http://localhost:5000/managebatch_advisor/editbatchadvisor',
                    redirect:  '/manage_batch_advisor',
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