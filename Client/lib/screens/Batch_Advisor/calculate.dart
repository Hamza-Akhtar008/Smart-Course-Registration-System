import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menu_advisor.dart';

import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screenStudent.dart';
import '../main/components/side_menuStudent.dart';

import 'package:http/http.dart' as http;

class CalculateStudentCGPA extends StatefulWidget {
  @override
  _CalculateState createState() => _CalculateState();
}

class SemesterDetails {
  final String semester;
  final int courses;

  SemesterDetails({required this.semester, required this.courses});
}

class _CalculateState extends State<CalculateStudentCGPA> {
  File? pdfFile;
  bool uploading = false;
  String message = '';
  String filepath = "";
  List<int> bytes = [];
  bool isLoading = true;
  List<SemesterDetails> semesterDetailsList = [];
  bool isGPAButtonClicked = false;
  String searchText = '';
  @override
  void initState() {
    super.initState();
   
  }

  double calculateSGPA(String grade) {
    switch (grade) {
      case 'A+':
        return 4.00;
      case 'A':
        return 4.00;
      case 'A-':
        return 3.67;
      case 'B+':
        return 3.33;
      case 'B':
        return 3.00;
      case 'B-':
        return 2.67;
      case 'C+':
        return 2.33;
      case 'C':
        return 2.00;
      case 'C-':
        return 1.67;
      case 'D+':
        return 1.33;
      case 'D':
        return 1.00;
      default:
        return 0.00;
    }
  }

  List<double> calculateSemesterGPA(List<Map<String, String>> semesterCourses, double totalcredithours, double totalgradepoints) {
    double totalGradePoints = 0.0;
    int totalCreditHours = 0;
    totalcredithours=0;
    for (var course in semesterCourses) {
      String grade = course['grade'] ?? '';
      int creditHours = int.tryParse(course['creditHours'] ?? '0') ?? 0;
      if (creditHours > 3) {
        creditHours = 3;
        course['creditHours']='3';
      }
      totalcredithours+=creditHours;
      totalGradePoints += calculateSGPA(grade) * creditHours;
      if(totalGradePoints!=0.00) {
        totalCreditHours += creditHours;
        totalgradepoints += creditHours;
      }
    }

    return [totalCreditHours > 0 ? totalGradePoints / totalCreditHours : 0.0,totalgradepoints,totalcredithours];
  }

  List<Map<String, dynamic>> Transcriptdetailinfo = [];

  List<Map<String, String>> TranscriptInfo = [
    // ... your transcript info data
  ];

  void getTranscript() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'student_id': searchText,
    };
    final http.Response response = await http.post(
      Uri.parse(
          'http://localhost:5000/gettranscriptstudyplan/getStudyPlansandTranscript'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true &&
          responseData.containsKey('studyplan_details') &&
          responseData.containsKey('transcriptinfo')) {
        String transcriptInfoString = responseData['transcriptinfo'];
        List<Map<String, String>> transcriptInfo =
        List<Map<String, dynamic>>.from(jsonDecode(transcriptInfoString))
            .map((Map<String, dynamic> entry) => entry.map(
              (key, value) => MapEntry(key, value.toString()),
        ))
            .toList();

        String transcriptdetail = responseData['transcriptdetail'];
        List<Map<String, dynamic>> transcriptdetailInfo =
        List<Map<String, dynamic>>.from(jsonDecode(transcriptdetail));

        setState(() {
          TranscriptInfo = transcriptInfo;
          Transcriptdetailinfo = transcriptdetailInfo;
          semesterDetailsList = Transcriptdetailinfo.map((semester) {
            return SemesterDetails(
              semester: semester['semester'],
              courses: semester['courses'],
            );
          }).toList();
        });
        isLoading = false;
      } else {
        throw Exception('Invalid response structure');

      }
    } else {
      throw Exception('Failed to load transcript');

    }
  }

  Widget _buildSemesterTable() {
    if (isLoading) {
      return  CircularProgressIndicator();
    }

    double totalcredithours = 0;
    double totalgradepoints = 0;
    int start = 0;
    double cgpa = 0;
    return Column(
      children: semesterDetailsList.map((semesterDetails) {
        List<Map<String, String>> semesterCourses =
        TranscriptInfo.sublist(start, start + semesterDetails.courses);
        start += semesterDetails.courses;
        List<double> data =
        calculateSemesterGPA(semesterCourses, totalcredithours, totalgradepoints);
        totalcredithours = data[2];
        totalgradepoints = data[1];
        double eachgpa = 0.00;
        if (data[0] != 0.00) {
          cgpa += data[0] * data[2];
          print("Total CreditHours : ${data[2]}");
          print("CGPA : ${cgpa}");
          print("Total Grade Point : ${data[1]}");
          eachgpa = cgpa / data[1];
        } else {
          eachgpa = cgpa / data[1];
        }

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
                  Text(
                    'SGPA: ${data[0].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'CGPA: ${eachgpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            PaginatedSemesterTableWidget(
              courses: semesterCourses,
              semseter: semesterDetails.semester,
              isGPAButtonClicked: isGPAButtonClicked,
              onUpdateGrade: (grade,index) {
                updateGrade(semesterCourses, grade,index);
              },
            ),
          ],
        );
      }).toList(),
    );
  }
  void updateGrade(List<Map<String, String>> semesterCourses, String grade,int index) {
    setState(() {
     semesterCourses[index]['grade']=grade;
    });
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
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenuAdvisor(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardScreenStudent(
                      parameter: "Calulate Student CGPA",
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20.0),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                searchText = value;
                              });

                            },
                            decoration: InputDecoration(
                              labelText: 'Search by Roll No',
                              prefixIcon: Icon(Icons.search),
                              prefixStyle: TextStyle(color: Colors.black)
                            ),
                        style: TextStyle(color: Colors.black),  ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              getTranscript();
                            },
                            child: Text('Get Transcript'),
                          ),

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
  bool isGPAButtonClicked;
  Function(String,dynamic) onUpdateGrade;
  dynamic index;

  PaginatedSemesterTableWidget({
    required this.courses,
    required this.semseter,
    required this.isGPAButtonClicked,
    required this.onUpdateGrade,
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Theme(
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
            ),  child:  PaginatedDataTable(
      header: Text('${semseter}'),
      rowsPerPage: courses.length,
      columns: [
        DataColumn(label: Text('Course ID')),
        DataColumn(label: Text('Course Name')),
        DataColumn(
          label: Text(isGPAButtonClicked ? 'GPA' : 'Grade'),
        ),
        DataColumn(label: Text('Section')),
        DataColumn(label: Text('Credit Hours')),
      ],
      source: _SemesterDataSource(courses,isGPAButtonClicked,onUpdateGrade,index),
    ),
    ),
    ],
    );
  }
}

class _SemesterDataSource extends DataTableSource {
  final List<Map<String, String>> _courses;
  final bool isGPAButtonClicked;
  final Function(String,dynamic) onUpdateGrade;

  _SemesterDataSource(this._courses, this.isGPAButtonClicked, this.onUpdateGrade, index);

  @override
  DataRow getRow(int index) {
    final course = _courses[index];
    return DataRow(cells: [
      DataCell(Text(course['courseId'] ?? '')),
      DataCell(Text(course['Course_Name'] ?? '')),
      DataCell(
        isGPAButtonClicked
            ? Text(course['grade'] ?? '')
            : DropdownButtonFormField<String>(
          value: course['grade'] ?? '',
          items: ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D','']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue,) {
            onUpdateGrade(newValue ?? '',index);
          },
        ),
      ),
      DataCell(Text(course['section'] ?? '')),
      DataCell(Text(course['creditHours'] ?? 'null')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _courses.length;

  @override
  int get selectedRowCount => 0;
}