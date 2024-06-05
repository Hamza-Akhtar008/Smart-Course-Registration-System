import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_screenhod.dart';
import 'components/side_menu_advisor.dart';

class MainScreenBatchAdvisor extends StatefulWidget {
  @override
  _MainScreenBatchAdvisor createState() => _MainScreenBatchAdvisor();
}

class _MainScreenBatchAdvisor extends State<MainScreenBatchAdvisor> {
  List<Map<String, dynamic>> batches = [];

  void initState() {
    super.initState();
    getbatchadvisor();
  }

  Future<void> getbatchadvisor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid') ?? '';
    String token = prefs.getString('token') ?? '';
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final data = {'HODID': userId};

    final response = await http.post(
      Uri.parse('http://localhost:5000/managebatch_advisor/get_advisor'),
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> batchData = responseData['students'];

      setState(() {
        batches = List<Map<String, dynamic>>.from(batchData);
        print(batches);
      });
    } else {
      throw Exception('Failed to load student information');
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenuAdvisor(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) SideMenuAdvisor(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreenHOD(parameter: "Dashboard"),
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
                              'University Information:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity, // Take full width
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFF334155),
                            width: 2,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advisor ID:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['AdvisorID'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            SizedBox(height: 16),
                            Text(
                              'Name:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['advisor_name'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            SizedBox(height: 16),
                            Text(
                              'Email:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['advisor_email'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            SizedBox(height: 16),
                            Text(
                              'Contact:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['advisor_contact'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            SizedBox(height: 16),

                            SizedBox(height: 16),
                            Text(
                              'Department:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['depart_id'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            SizedBox(height: 16),
                            Text(
                              'Batch:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (batches.isNotEmpty)
                              Text(
                                batches[0]['batch_id'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                          ],
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
}
