import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';

import '../dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/components/side_menu.dart';

class StudyPlanDetails extends StatefulWidget {
  @override
  _StudyPlanDetailsState createState() => _StudyPlanDetailsState();
}

class _StudyPlanDetailsState extends State<StudyPlanDetails> {
  late String studyplanid;
  List<String> headers = ['studplanid'];

   List<Map<String, dynamic>> futureStudyPlans = [];
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studyplanid = prefs.getString('studplanid') ?? '';
      if (studyplanid.isNotEmpty) {
        // Initiate the data retrieval when the widget is first created
 getAllStudyPlans();
      }
    });
  }
  Widget _buildSemesterTable() {
    return Column(
      children: futureStudyPlans.map((semesterDetails) {
        List<Map<String, String>> semesterCourses = [];

        semesterDetails.forEach((key, value) {
          if (key.contains('courses') && value != null) {
            if (value is String) {

              String correctedCoursesString = value;

              try {
                correctedCoursesString = correctedCoursesString.substring(1, correctedCoursesString.length - 1);
                correctedCoursesString = correctedCoursesString.substring(1, correctedCoursesString.length - 1);
                List<Map<String, String>> dynamicCourses = correctedCoursesString
                    .split(RegExp(r'},\s*{'))
                    .map((entry) {
                  List<String> keyValuePairs = entry.split(', ');

                  Map<String, String> courseMap = {};

                  keyValuePairs.forEach((keyValue) {
                    List<String> keyValueList = keyValue.split(':');
                    String key = keyValueList[0].trim().replaceAll(RegExp(r'^"|"$'), ''); // Remove surrounding quotes
                    String value = keyValueList[1].trim().replaceAll(RegExp(r'^"|"$'), ''); // Remove surrounding quotes

                    courseMap[key] = value;
                  });

                  return courseMap;
                })
                    .toList();

                semesterCourses = dynamicCourses;
              } catch (e) {
                print('Error processing courses string: $e');
                print('Course content: $value');
              }
            } else {

            }
          }
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Semester No : ${semesterDetails['semester_no']?.toString() ?? ''}",style: TextStyle(color: Colors.black,fontSize: 30), ),
                  PaginatedSemesterTableWidget(
                    courses: semesterCourses,
                    semseter: semesterDetails['semester_no']?.toString() ?? '',
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
  void getAllStudyPlans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/managestudyplan/gettstudplansbyid'),
        headers: head,
        body: jsonEncode({'studplanid': studyplanid}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true &&
            responseData.containsKey('study_plan_details')
        ) {
          String transcriptInfoString = responseData['study_plan_details'];
          List<Map<String, String>> transcriptInfo =
          List<Map<String, dynamic>>.from(jsonDecode(transcriptInfoString))
              .map((Map<String, dynamic> entry) => entry.map(
                (key, value) => MapEntry(key, value.toString()),
          )).toList();
          setState(() {
  futureStudyPlans =transcriptInfo;
});


        } else {
          throw Exception('Invalid response structure');

        }


      } else {
        print('Error fetching study plans: ${response.statusCode}');
        throw Exception('Failed to fetch study plans');
      }
    } catch (error) {
      print('Network error: $error');
      throw Exception('Network error');
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardScreen(
                        parameter: "Study Plan Details"),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [

                          SizedBox(height: 20.0),

                          SizedBox(height: 20.0),
                          _buildSemesterTable(),
                        ],
                      ),
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
class PaginatedSemesterTableWidget extends StatelessWidget {
  final List<Map<String, String>> courses;
  String semseter;
  PaginatedSemesterTableWidget(
      {required this.courses, required this.semseter});

  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Theme(
        data: ThemeData(
        dataTableTheme: DataTableThemeData(
        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
    headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF334155)),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(20),
    color: Color(0xFFE5E7EB),
    ),
    dataTextStyle: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    headingTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    ),
    child: PaginatedDataTable(
      
      rowsPerPage: courses.length,
      columns: [

        DataColumn(label: Text('Course Name')),

        DataColumn(label: Text('credit hours')),
      ],
      source: _SemesterDataSource(courses),
    )
    )]);
  }
}

class _SemesterDataSource extends DataTableSource {
  final List<Map<String, String>> _courses;

  _SemesterDataSource(this._courses);

  @override
  DataRow getRow(int index) {
    final course = _courses[index];
    return DataRow(cells: [

      DataCell(Text(course['course_name'] ?? '')),

      DataCell(Text(course['credit_hours']  ??  'null')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _courses.length;

  @override
  int get selectedRowCount => 0;
}
