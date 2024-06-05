import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/MenuAppController.dart';
import '../../../responsive.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../main/components/side_menu.dart';
class AddNewCourse extends StatefulWidget {
  @override
  _AddNewCourseState createState() => _AddNewCourseState();
}
class _AddNewCourseState extends State<AddNewCourse> {
  final TextEditingController courseIdController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController courseDescriptionController = TextEditingController();
  String? selectedCourseType;
String? selectedCoursePreReg;
  Future<void> _addNewCourse() async {
    final url = Uri.parse('http://localhost:5000/managecourse/addNewCourse');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    // Create a map with your course data
    final Map<String, dynamic> courseData = {
      'CourseID': courseIdController.text,
      'Course_Name': courseNameController.text,
      'Course_Type': selectedCourseType,
      'Course_Pre_reg':selectedCoursePreReg,
      'Course_Description': courseDescriptionController.text,
    };

    // Make a POST request to add a new course
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(courseData),
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Course added successfully
      showLoginSuccessToast('Course added successfully');
      // You might want to navigate to another screen or show a success message
    } else {
      // Failed to add the course
      final Map<String, dynamic> responseData = json.decode(response.body);



      showLoginFailedToast('${responseData['message']}');
      // You might want to show an error message
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

  void showLoginSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green, // Green color for success
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
                      DashboardScreen(parameter: "Add New Course "),
                      SizedBox(height: 20),
                      _buildAddCourseForm(),
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
  Widget _buildAddCourseForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidatedTextField(
            controller: courseIdController,
            labelText: 'Course ID',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Course ID';
              }
              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: courseNameController,
            labelText: 'Course Name',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Course Name';
              }
              else if (RegExp(r'[0-9]').hasMatch(value)) {
                return 'Course Name Cannot be numbers';
              }
              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
     FutureBuilder<List<String>>(
            future: fetchcoursetypeIds(),
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                List<String> courseTypes = snapshot.data!;
                return _buildDropdownButton(
                  label: 'Course Type',
                  controller: selectedCourseType,
                  defaultValue: 'Select Course Type',
                  prefixIcon: Icons.school,
                  items: courseTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(Icons.school, color: Colors.black),
                          SizedBox(width: 8),
                          Text(type, style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                 selectedCourseType = value ?? '';
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
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
                List<String> coursePreRegOptions = snapshot.data!;
                return _buildDropdownButton(
                  label: 'Course Pre-Reg',
                  controller: selectedCoursePreReg,
                  defaultValue: 'Select Course Pre-Reg',
                  prefixIcon: Icons.school, // Change the icon as needed
                  items: coursePreRegOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          Icon(Icons.school, color: Colors.black),
                          SizedBox(width: 8),
                          Text(option, style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCoursePreReg = value ?? '';
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
          _buildTextArea(
            controller: courseDescriptionController,
            labelText: 'Course Description',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Course Description';
              }
              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addNewCourse();
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
    IconData? prefixIcon,
    List<DropdownMenuItem<String>> items = const [],
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null)
              Icon(prefixIcon, color: Colors.black),
            Text(label, style: TextStyle(color: Colors.black)),
          ],
        ),
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
  Widget _buildTextArea({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
        suffixIcon: _buildValidationIcon(controller.text, validator),
      ),
      keyboardType: TextInputType.multiline,
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

  Future<List<String>> fetchcoursetypeIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('http://localhost:5000/managecoursetype/getallcoursetypeid'),
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
}