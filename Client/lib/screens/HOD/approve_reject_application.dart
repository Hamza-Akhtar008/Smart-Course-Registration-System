import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_course_registration_system/screens/main/components/side_menuStudent.dart';

import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_screenhod.dart';
import '../main/components/side_menuHod.dart';

class SemesterDetails {
  final String semester;
  final int courses;
  SemesterDetails({required this.semester, required this.courses});
}
class ApproveRejectApplication extends StatefulWidget {
  @override
  _ApproveRejectApplication createState() => _ApproveRejectApplication();
}

class _ApproveRejectApplication extends State<ApproveRejectApplication> {
  List<Map<String, dynamic>> applications = [];
  List<Map<String, dynamic>> course = [];
  TextEditingController hodCommentController = TextEditingController(); // Controller for HOD comment
  bool isLoading = true;
  List<Map<String, dynamic>> Transcriptdetailinfo = [];
  List<Map<String, String>> TranscriptInfo = [
    // ... your transcript info data
  ];
  List<SemesterDetails> semesterDetailsList = [];
  void initState() {
    super.initState();
    fetchApplications();
  }
  void getTranscript() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    final String student_id = prefs.getString('student_id') ?? '';
    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'student_id': student_id,
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
  Widget _buildSemesterTable() {


    double totalcredithours=0;
    double totalgradepoints=0;
    int start = 0;
    double cgpa=0;
    return Column(
      children: semesterDetailsList.map((semesterDetails) {
        // Get the courses for the current semester
        List<Map<String, String>> semesterCourses = TranscriptInfo
            .sublist(start, start + semesterDetails.courses);
        start += semesterDetails.courses;
        List<double> data  = calculateSemesterGPA(semesterCourses,totalcredithours,totalgradepoints);
        totalcredithours=data[2];
        totalgradepoints=data[1];
        double eachgpa=0.00;
        if(data[0]!=0.00)
        {
          cgpa += data[0]*data[2];
          print("Total CreditHours : ${data[2]}");
          print("CGPA : ${cgpa}" );
          print("Total Grade Point : ${data[1]}");
          eachgpa = cgpa/data[1];
        }
        else
        {
          eachgpa = cgpa/data[1];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white70, // Choose your desired background color
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.black, // Choose your desired border color
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
            ),

          ],
        );
      }).toList(),
    );
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
                      DashboardScreenHOD(parameter: "Appprove or Reject Application"),
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
                              'Application Details:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      (course.isNotEmpty)
                          ? ApplicationTable(data: course)
                          : CircularProgressIndicator(),
                      SizedBox(height: 20),
                      if (!isApplicationProcessed()) // Check if application is not already approved or rejected
                        Column(
                          children: [
                            Text(
                              'Give Comments:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: hodCommentController,
                              decoration: InputDecoration(
                                hintText: 'HOD Comment',
                                hintStyle: TextStyle(color: Colors.black), // Change hint color to black
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _approveApplication(true, false),
                                  child: Text('Approve'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _approveApplication(false, true),
                                  child: Text('Reject'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Call the _buildSemesterTable function
                                    getTranscript();

                                  },
                                  child: Text('Get Transcript'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (isApplicationProcessed()) // If application is already processed
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Application already ${isApproved() ? 'Approved' : 'Rejected'}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      _buildSemesterTable(),
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
    // Check if application is already approved or rejected
    return applications.isNotEmpty && (applications[0]['isApproved'] || applications[0]['isRejected']);
  }

  bool isApproved() {
    // Check if application is approved
    return applications.isNotEmpty && applications[0]['isApproved'];
  }
  void _approveApplication(bool approve, bool reject) async {
    String hodComment = hodCommentController.text.trim();
    if (hodComment.isEmpty) {
      // Show error message indicating that the comment cannot be empty
      _showErrorSnackBar('HOD comment cannot be empty');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String studentId = prefs.getString('student_id') ?? '';
    String applicationId = prefs.getString('applicationId') ?? '';
    final Map<String, dynamic> data = {
      'student_id': studentId,
      'application_id': applicationId,
      'hodComments': hodComment,
      'isApproved': approve, // Pass true for approval, false for rejection
      'isRejected': reject, // Pass true for rejection, false for approval
    };

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse('http://localhost:5000/registrationappication/update_registration_application');

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
   if(approve)
     {
       showLoginFailedToast("Application Approved Succesfully");
       Navigator.pushNamed(context, '/view_application');
     }
   else
     {
       showLoginFailedToast("Application Rejected Succesfully");
       Navigator.pushNamed(context, '/view_application');
     }
    } else {
      showLoginFailedToast("Application Not Updated Succesfully");
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

class ApplicationTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  ApplicationTable({required this.data});

  @override
  _ApplicationTableState createState() => _ApplicationTableState();
}
class _ApplicationTableState extends State<ApplicationTable> {
  List<Map<String, dynamic>> filteredData = [];
  String selectedStatus = 'none';

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredData = widget.data;

    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
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
          ),
          child: PaginatedDataTable(
            columns: [
              DataColumn(label: Text('Course ID ')),
              DataColumn(label: Text('Course Name')),
              DataColumn(label: Text('Section')),
              DataColumn(label: Text('course Type')),
              DataColumn(label: Text('Course Pre reg')),
              DataColumn(label: Text('Department')),
            ],
            source: _ApplicationDataSource(filteredData),
            header: Text('Selected Courses'),
            rowsPerPage: filteredData.length,
          ),
        ),
      ],
    );
  }
}

class _ApplicationDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;


  _ApplicationDataSource(this._data);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final application = _data[index];

    return DataRow(cells: [
      DataCell(Center(child: Text('${application['CourseID']}'))),
      DataCell(Center(child: Text('${application['Course_Name']}'))),
      DataCell(Center(child: Text('${application['section']}'))),
      DataCell(Center(
          child: Text(
          '${application['course_type']}'))),
      DataCell(Center(
          child: Text(
              '${application['Course_Pre_reg']}'))),
      DataCell(Center(
          child: Text(
              '${application['depart_id']}'))),

    ]);
  }



  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
class PaginatedSemesterTableWidget extends StatelessWidget {
  final List<Map<String, String>> courses;
  String semseter;
  PaginatedSemesterTableWidget(
      {required this.courses, required this.semseter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ Theme(
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
          header: Text('${semseter}'),
          rowsPerPage: courses.length,
          columns: [
            DataColumn(label: Text('Course ID')),
            DataColumn(label: Text('Course Name')),
            DataColumn(label: Text('Grade')),
            DataColumn(label: Text('Section')),
            DataColumn(label: Text('credit hours')),
          ],
          source: _SemesterDataSource(courses),
        ),
      ),
      ],
    );
  }
}

class _SemesterDataSource extends DataTableSource {
  final List<Map<String, String>> _courses;

  _SemesterDataSource(this._courses);

  @override
  DataRow getRow(int index) {
    final course = _courses[index];
    return DataRow(cells: [
      DataCell(Text(course['courseId'] ?? '')),
      DataCell(Text(course['Course_Name'] ?? '')),
      DataCell(Text(course['grade'] ?? '')),
      DataCell(Text(course['section'] ?? '')),
      DataCell(Text(course['creditHours']  ??  'null')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _courses.length;

  @override
  int get selectedRowCount => 0;
}
