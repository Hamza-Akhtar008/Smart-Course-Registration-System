import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../controllers/MenuAppController.dart';
import '../../../responsive.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../main/components/side_menu.dart';

class AddNewStudent extends StatefulWidget {
  @override
  _AddNewStudentState createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentCNICController = TextEditingController();
  final TextEditingController studentAddressController = TextEditingController();
  final TextEditingController departIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController studentContactController = TextEditingController();
  final TextEditingController studentPasswordController = TextEditingController();
  final TextEditingController selectBatchController = TextEditingController();

  String? selectedDepartment;
  String? selectedBatch;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<List<String>> departIds;
  late Future<List<String>> batchIds;

  @override
  void initState() {
    super.initState();
    departIds = fetchDepartIds();
    batchIds = fetchBatchIds();
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreen(parameter: "Add New Student "),
                      SizedBox(height: 20),
                      _buildAddBatchAdvisorForm(),
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

  Widget _buildAddBatchAdvisorForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidatedTextField(
            controller: studentIdController,
            labelText: 'Student ID',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Student ID';
              }
              return null;
            },
            prefixIcon: Icons.text_fields,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentCNICController,
            labelText: 'Student CNIC',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Student CNIC';
              }
              if (value.length > 13 || value.length<13) {
                return 'Please enter Valid CNIC address';
              }
              return null;
            },
            prefixIcon: Icons.badge,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentAddressController,
            labelText: 'Student Address',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Student Address';
              }
              return null;
            },
            prefixIcon: Icons.home,
          ),
          SizedBox(height: 16),
          FutureBuilder<List<String>>(
            future: departIds,
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                List<String> departIds = snapshot.data!;

                return _buildDropdownButton(
                  label: 'Department ID',
                  controller: departIdController,
                  defaultValue: selectedDepartment ?? 'Select Department',
                  prefixIcon: Icons.business,
                  items: departIds.map((id) {
                    return DropdownMenuItem(
                      value: id,
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Department $id',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
          FutureBuilder<List<String>>(
            future: batchIds,
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                List<String> batchIds = snapshot.data!;

                return _buildDropdownButton(
                  label: 'Batch ',
                  controller: selectBatchController,
                  defaultValue: 'Select Batch ',
                  prefixIcon: Icons.group,
                  items: batchIds.map((id) {
                    return DropdownMenuItem(
                      value: id,
                      child: Row(
                        children: [
                          Icon(Icons.group, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Batch $id',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBatch = value;
                      selectBatchController.text = value ?? '';
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentNameController,
            labelText: 'Student Name',
            validator: (value) {
    if (value!.isEmpty) {
    return 'Please enter Batch Advisor Name';
    }
    else if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Batch Advisor Name Cannot be numbers';
    }
              return null;
            },
            prefixIcon: Icons.person,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentEmailController,
            labelText: 'Student Email',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter student Email';
              } else if (!RegExp(
                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            prefixIcon: Icons.email,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentContactController,
            labelText: 'Student Contact',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Student Contact';
              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Please enter a valid phone number';
              }
              else if(value.length<11 || value.length>11)
                {
                  return 'Please enter 11 Digit phone number';
                }
              return null;
            },
            prefixIcon: Icons.phone,
          ),
          SizedBox(height: 16),
          _buildValidatedTextField(
            controller: studentPasswordController,
            labelText: 'Student Password',
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Student Password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
            prefixIcon: Icons.lock,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                sendDataToServer();
              }
            },
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Color(0xFF334155)),
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
    required TextEditingController controller,
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
          value: controller.text.isNotEmpty ? controller.text : null,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: defaultValue,
            hintStyle: TextStyle(color: Colors.black),
          ),
          validator: (value) {
            if (value == null ||
                value.isEmpty ||
                value == 'Select Department' ||
                value == 'Select Batch') {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
        suffixIcon: _buildValidationIcon(controller.text, validator),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: (value) {
        setState(() {});
      },
      validator: validator,
    );
  }

  Widget _buildValidationIcon(
      String text, String? Function(String?)? validator) {
    if (text.isEmpty) {
      return SizedBox.shrink();
    }
    return Icon(
      validator?.call(text) == null ? Icons.check : Icons.clear,
      color: validator?.call(text) == null ? Colors.green : Colors.red,
    );
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
  Future<void> sendDataToServer() async {
    final url = 'http://localhost:5000/managestudentrecords/add_new_student';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String? academics_id = prefs.getString('userid');

    final data = {
      'student_id': studentIdController.text,
      'student_name': studentNameController.text,
      'student_cnic': studentCNICController.text,
      'student_address': studentAddressController.text,
      'batch_id': selectedBatch ?? '',
      'depart_id': selectedDepartment ?? '',
      'student_email': studentEmailController.text,
      'student_contact': studentContactController.text,
      'student_password': studentPasswordController.text,
      'academics_id': academics_id,
    };

    try {
      final Map<String, String> headers = {
        'Authorization': '${token}',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        showLoginSuccessToast('Student added successfully');
        Navigator.pushNamed(context, '/add_new_student');
      } else {
        showLoginFailedToast(
            'Failed to add student. Status code: ${response.statusCode}');
        Navigator.pushNamed(context, '/add_new_student');
      }
    } catch (error) {
      showLoginFailedToast('$error');
      Navigator.pushNamed(context, '/add_new_student');
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

  Future<List<String>> fetchBatchIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('http://localhost:5000/managebatch/getallbatchid'),
      headers: head,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      List<String> batchIds = data.map((item) => item.toString()).toList();
      return batchIds;
    } else {
      throw Exception('Failed to load batch_ids');
    }
  }
}
