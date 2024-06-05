import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/screens/dashboard/dashboard_screenhod.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menuHod.dart';
import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screenStudent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main/components/side_menuStudent.dart';

class HODBatchAdvisorViewCourses extends StatefulWidget {
  @override
  _HODBatchAdvisorViewCourses createState() => _HODBatchAdvisorViewCourses();
}

class _HODBatchAdvisorViewCourses extends State<HODBatchAdvisorViewCourses> {
  List<Map<String, dynamic>> courseList = [];
  List<Map<String, dynamic>> mergedata = [];
  List<Map<String, dynamic>> cartList = [];

  void initState() {
    super.initState();
    searchCourses("");
  }

  void addToCart(Map<String, dynamic> course) {
    setState(() {
      bool courseAlreadyAdded = cartList.any(
              (cartCourse) => cartCourse['CourseID'] == course['CourseID']);

      if (courseAlreadyAdded) {
        showErrorToast("Course Already Added");
      } else {
        cartList.add(course);
      }
    });
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void removeFromCart(Map<String, dynamic> course) {
    setState(() {
      cartList.remove(course);
    });
  }

  Future<void> searchCourses(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid') ?? '';
    String token = prefs.getString('token') ?? '';
    String admintype = prefs.getString('usertype')!;
    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };
    final data = {
      'student_id': userId,
      'SearchName': query,
      'user_type':admintype,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:5000/offercourse/getcourseofferings'),
        headers: headers,
        body: json.encode(data),
      );
      mergedata.clear();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic>? batchData = responseData['data'];
        final List<dynamic> coursename = responseData['course_name'];
        final List<dynamic> coursepre = responseData['course_pre'];
        final List<dynamic> course_type = responseData['course_type'];

        print(coursename);
        print(coursepre);
        print(course_type);

        if (batchData != null) {
          setState(() {
            courseList = List<Map<String, dynamic>>.from(batchData);

            for (int i = 0; i < courseList.length; i++) {
              final Map<String, dynamic> mergedItem = {
                "Course_Name": coursename[i],
                "Course_Pre_reg": coursepre[i],
                "course_type": course_type[i],
                "section": courseList[i]["Semester"] +
                    courseList[i]["section"],
                "depart_id": courseList[i]["depart_id"],
                "CourseID": courseList[i]["CourseID"],
              };

              mergedata.add(mergedItem);
            }
            courseList = mergedata;
          });
        } else {
          print('Data does not contain the expected key "data".');
        }
      } else {
        print(
            'Failed to load student information. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching offered courses: $error');
    }
  }

  Future<void> addNewRegistrationApplication() async {
    if(cartList.isEmpty)
    {
      showErrorToast('Please Select Courses First');
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid') ?? '';
    String token = prefs.getString('token') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final List<Map<String, dynamic>> courses = cartList.map((course) {
      return {
        'CourseID': course['CourseID'],
        'Course_Name': course['Course_Name'],
        'section': course['section'],
        'course_type': course['course_type'],
        'Course_Pre_reg': course['Course_Pre_reg'],
        'depart_id': course['depart_id'],
      };
    }).toList();

    final Map<String, dynamic> data = {
      'student_id': userId,
      'courses': courses,
      // Add other necessary fields here
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/registrationappication/add_new_registrationApplication'),
        headers: headers,
        body: json.encode(data),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        // Handle success
        showErrorToast('Registration application submitted successfully.');
        // Optionally clear the cartList after successful registration
        setState(() {
          cartList.clear();
        });
      } else {

        showErrorToast('${responseData['message']}');
      }
    } catch (error) {
      // Handle exception
      showErrorToast('Error submitting registration application: $error');
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
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenuHOD(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardScreenHOD(
                        parameter: "Course Registration"),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (query) {
                          searchCourses(query);
                        },
                        decoration: InputDecoration(
                          labelText: 'Search by Course Name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // List of Offered Courses
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'List of Offered Courses ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),

                    Column(
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
                          ),  child:
                        PaginatedDataTable(
                          header: Text('List of Offered Courses'),
                          columns: [
                            DataColumn(label: Text('Course Code')),
                            DataColumn(label: Text('Course Name')),
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Course Type')),
                            DataColumn(label: Text('Course Pre-Reg')),
                            DataColumn(label: Text('Department')),

                          ],
                          source: _MyTableDataSource(
                            courseList: courseList,
                            addToCart: addToCart,
                          ),
                          onPageChanged: (int pageIndex) {
                            // Handle page change if needed
                          },
                          rowsPerPage: 5,
                        ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // List of Added Courses





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

class _MyTableDataSource extends DataTableSource {
  final List<Map<String, dynamic>> courseList;
  final Function(Map<String, dynamic> course)? addToCart;
  final Function(Map<String, dynamic> course)? removeFromCart;

  _MyTableDataSource({
    required this.courseList,
    this.addToCart,
    this.removeFromCart,
  });

  @override
  DataRow getRow(int index) {
    final course = courseList[index];
    return DataRow(
      cells: [
        DataCell(Text(course['CourseID'] ?? '')),
        DataCell(Text(course['Course_Name'] ?? '')),
        DataCell(Text(course['section'] ?? '')),
        DataCell(Text(course['course_type']?.toString() ?? '')),
        DataCell(Text(course['Course_Pre_reg']?.toString() ?? '')),
        DataCell(Text(course['depart_id']?.toString() ?? '')),

      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => courseList.length;

  @override
  int get selectedRowCount => 0;
}
