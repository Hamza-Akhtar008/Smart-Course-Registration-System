import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/screens/Component/Editabledata.dart';
import '../../../controllers/MenuAppController.dart';
import '../../../responsive.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../main/components/side_menu.dart';

class AddNewCourseOffering extends StatefulWidget {
  @override
  _AddNewCourseOfferingState createState() => _AddNewCourseOfferingState();
}

class _AddNewCourseOfferingState extends State<AddNewCourseOffering> {
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  String? selectedDepartment;
  String? selectedCourseName;
  int? semester;
  List<Map<String, dynamic>> batches = [];
  final List<Map<String, dynamic>> mergedData = [];
  @override
  void initState() {
    super.initState();
    // Call the method to fetch data when the widget is first created
    fetchData();
  }
  Future<void> fetchData() async {
    final url = 'http://localhost:5000/offercourse/getallcourseofferings';
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
        final List<dynamic> batchData = responseData['data'];
        final List<dynamic> coursename = responseData['course_name'];
        setState(() {
          batches = List<Map<String, dynamic>>.from(batchData);

            for (int i = 0; i < batches.length; i++) {
              final Map<String, dynamic> mergedItem = {
                "Course_Name": coursename[i],
               "section": batches[i]["Semester"] + batches[i]["section"],
                "depart_id": batches[i]["depart_id"],
                "CourseID": batches[i]["CourseID"],
                "offering": batches[i]["offering"],


              };

              mergedData.add(mergedItem);

        }
            batches=mergedData;

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

  Future<void> _addNewCourseOffering() async {
    final url = Uri.parse('http://localhost:5000/offercourse/add_new_courseofferings');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> courseOfferingData = {
      'CourseID': selectedCourseName,
      'section': sectionController.text,
      'Semester': semesterController.text,
      'depart_id':selectedDepartment
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(courseOfferingData),
    );

    if (response.statusCode == 200) {
      showLoginSuccessToast('Course offering added successfully');
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      showLoginFailedToast('${responseData['message']}');
    }
  }

  void showLoginFailedToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void showLoginSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreen(parameter: "Offer-Course"),
                      SizedBox(height: 20),
                      _buildAddCourseOfferingForm(),
                      SizedBox(height: 50),
                      Text(

                        "LIST OF OFFERED COURSES",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 50),
                      EditableDataTable(
                        headers: ['CourseID','Course_Name','section','depart_id','offering','UnOffer'],
                        data: batches,
                        deleteurl: 'http://localhost:5000/offercourse/delete_courseofferings',
                        editurl: 'http://localhost:5000/offercourse/edit_coursetype',
                        redirect: '/manage_degree',
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

  Widget _buildAddCourseOfferingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<String>>(
            future: fetchcourseName(),
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                List<String> courseNames = snapshot.data!;
                return _buildDropdownButton(
                  label: 'Course Name',
                  controller: selectedCourseName,
                  defaultValue: 'Select Course Name',
                  items: courseNames.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourseName = value ?? '';
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
          FutureBuilder<List<String>>(
            future: fetchDepartIds(), // Add a function to fetch department names
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                List<String> departments = snapshot.data!;
                return _buildDropdownButton(
                  label: 'Department',
                  controller: selectedDepartment,
                  defaultValue: 'Select Department',
                  items: departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value ?? '';
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: sectionController,
            labelText: 'Section',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Section';
              }

              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: semesterController,
            labelText: 'Semester',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Semester';
              }
              // Add any additional validation for Semester (e.g., only numbers, not less than 1)
              // You can use regular expressions or other validation methods.
              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addNewCourseOffering();
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF334155)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.yellowAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required String label,
    required String? controller,
    String defaultValue = '',
    List<DropdownMenuItem<String>> items = const [],
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black)),
        DropdownButtonFormField<String>(
          value: controller != null && controller.isNotEmpty ? controller : null,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: defaultValue,
            hintStyle: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
        suffixIcon: _buildValidationIcon(controller.text, validator),
      ),
      onChanged: (value) {
        setState(() {});
      },
      validator: validator,
    );
  }

  Widget _buildValidationIcon(String text, String? Function(String?)? validator) {
    if (text.isEmpty) {
      return SizedBox.shrink();
    }
    return Icon(
      validator?.call(text) == null ? Icons.check : Icons.clear,
      color: validator?.call(text) == null ? Colors.green : Colors.red,
    );
  }

  Future<List<String>> fetchcourseName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('http://localhost:5000/managecourse/getAllCoursesids'),
      headers: head,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      List<String> coursetype = data.map((item) => item.toString()).toList();
      return coursetype;
    } else {
      throw Exception('Failed to load batch_ids');
    }
  }

  Future<List<String>> fetchDepartIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('http://localhost:5000/managedepart/getalldepartid'),
      headers: head,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      List<String> departIds =
      data.map((item) => item.toString()).toList();
      return departIds;
    } else {
      throw Exception('Failed to load depart_ids');
    }
  }
}

