import 'dart:convert';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/MenuAppController.dart';
import '../../../responsive.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../main/components/side_menu.dart';

class StudyPlanApi {
  static const String apiUrl =
      'http://localhost:5000/managestudyplan/add_new_studyplan';

  static Future<void> addNewStudyPlan({
    required String studplanid,
    required String depart_id,
    required String batch_id,
    required String totalCreditHours,
    required List<SemesterDetail> studyPlanDetails,
  }) async {
    final List<Map<String, dynamic>> semesterDetailsList = [];

    // Iterate through each semester
    for (int i = 0; i < studyPlanDetails.length; i++) {
      final SemesterDetail semesterDetail = studyPlanDetails[i];
      final Map<String, dynamic> semesterData = {
        'semester_no': i + 1, // Assuming semester numbers start from 1
        'courses': semesterDetail.semestersDetails
            .map((courseDetail) => {
          'course_name': courseDetail.selectedCourseName,
          'credit_hours': courseDetail.creditHoursController.text,
        })
            .toList(),
      };

      semesterDetailsList.add(semesterData);
    }

    final Map<String, dynamic> requestData = {
      'studplanid': studplanid,
      'depart_id': depart_id,
      'batch_id': batch_id,
      'total_credit_hours': totalCreditHours,
      'study_plan_details': semesterDetailsList,
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> headers = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {

        showLoginSuccessToast('Study plan created successfully');
        Navigator.pushNamed(context as BuildContext, '/manage_study_plan');
      } else {
        // Handle other status codes or errors
        showLoginFailedToast(
            'Error creating study plan: ${response.statusCode}');
        Navigator.pushNamed(context as BuildContext, '/manage_study_plan');
      }
    } catch (error) {
      // Handle network errors
      showLoginFailedToast('Network error: $error');
    }
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

class AddNewStudyPlan extends StatefulWidget {
  @override
  _AddNewStudyPlanState createState() => _AddNewStudyPlanState();
}

class _AddNewStudyPlanState extends State<AddNewStudyPlan> {
  final TextEditingController studplanIdController = TextEditingController();
  final TextEditingController departIdController = TextEditingController();
  final TextEditingController selectBatchController = TextEditingController();
  String? selectedDepartment;
  String? selectedBatch;
  List<SemesterDetail> studyPlanDetails = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<String>> departIds;
  late Future<List<String>> batchIds;
  final TextEditingController totalCreditHoursController = TextEditingController();
  late List<String> courseNames ;
  @override
  void initState() {
    super.initState();
    departIds = fetchDepartIds();
    batchIds = fetchBatchIds();
    fetchCourseNames().then((values) {
      setState(() {
        courseNames = values;
      });
    });
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
      List<String> batchIds =
      data.map((item) => item.toString()).toList();
      return batchIds;
    } else {
      throw Exception('Failed to load batch_ids');
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreen(parameter: "Add New Student "),
                      SizedBox(height: 20),

                      _buildAddStudyPlanForm(studyPlanDetails),
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

  Widget _buildAddStudyPlanForm(List<SemesterDetail> studyPlanDetails) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidatedTextField(
            controller: studplanIdController,
            labelText: 'Study Plan ID',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Study Plan ID';

              }
              return null;
            },
            prefixIcon: Icons.text_fields,
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
          _buildValidatedTextField(
            controller: totalCreditHoursController,
            labelText: 'Total Credit Hours',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter total credit hours';
              }

              else if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Credit Hours Cannot Contain Alphabets';
              }

              if (!isNumeric(value)) {
                return 'Please enter a valid number';
              }

              final int creditHours = int.parse(value);
              if (creditHours <= 0) {
                return 'Total credit hours must be greater than 0';
              }

              return null;
            },
            prefixIcon: Icons.format_list_numbered,
          ),
          SizedBox(height: 16),
          _buildStudyPlanDetails(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                StudyPlanApi.addNewStudyPlan(
                  studplanid: studplanIdController.text,
                  depart_id: selectedDepartment!,
                  batch_id: selectedBatch!,
                  studyPlanDetails: studyPlanDetails,
                  totalCreditHours: totalCreditHoursController.text,
                );
              }
            },
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Color(0xFF334155)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Square-shaped button
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

  Widget _buildStudyPlanDetails() {

    return Column(
      children: [
        Text(
          'Study Plan Details',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        SizedBox(height: 8),
        ...studyPlanDetails.asMap().entries.map((entry) {
          return SemesterDetailsWidget(
            semester: entry.value,
            semesterIndex: entry.key,

            studyplandetails:studyPlanDetails,
            courseNames: courseNames,

          );
        }).toList(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              studyPlanDetails.add(SemesterDetail());
            });
          },
          child: Text('Add Semester'),
        ),
      ],
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

  bool isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
}

class SemesterDetailsWidget extends StatefulWidget {

  final SemesterDetail semester;
  final int semesterIndex;
  final List<SemesterDetail> studyplandetails;
  List<String>courseNames;
   SemesterDetailsWidget({
    Key? key,
    required this.courseNames,
    required this.semester,
    required this.semesterIndex,  required this.studyplandetails,
  }) : super(key: key);

  @override
  _SemesterDetailsWidgetState createState() => _SemesterDetailsWidgetState(studyplandetails,courseNames);
}
List<List<String>> courseNamesList = [];
List<String> SCNAMES = [];
Map<int, String> selectedCoursesMap = {}; // Map to track selected courses for each CourseDetailsWidget

class _SemesterDetailsWidgetState extends State<SemesterDetailsWidget> {
  late final SemesterDetail semester;
  final List<SemesterDetail> studyplandetails;
  List<String> courseNames;
  _SemesterDetailsWidgetState(this.studyplandetails, this.courseNames);

  @override
  void initState() {
    super.initState();
    semester = widget.semester;
    if (widget.semesterIndex == 0) {
      courseNamesList.add(courseNames);
    } else {
      courseNamesList.add(SCNAMES);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semester ${widget.semesterIndex + 1}',
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 8),
        ...widget.semester.semestersDetails.asMap().entries.map((entry) {
          int index = entry.key +
              widget.studyplandetails
                  .sublist(0, widget.semesterIndex)
                  .fold(0, (count, semester) => count + semester.semestersDetails.length);

          CourseDetail course = entry.value;
          String selectedCourse = selectedCoursesMap[index] ?? '';

          return CourseDetailsWidget(
            key: Key(index.toString()),
            course: course,
            courseNames: courseNamesList[index],

              selectedCourse:selectedCourse,
            onChanged: (selectedCourseNames) {
              if (index + 1 == courseNamesList.length) {
                courseNamesList.add(selectedCourseNames);
                SCNAMES = selectedCourseNames;
              } else {
                courseNamesList[index + 1] = selectedCourseNames;
                SCNAMES = selectedCourseNames;
              }

              // Update the selected course for this CourseDetailsWidget
              selectedCoursesMap[index] = selectedCourseNames.isNotEmpty
                  ? selectedCourseNames.first // Assuming you want to track only one selected course
                  : '';
            },
          );
        }).toList(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              courseNamesList.add(SCNAMES);
              widget.semester.semestersDetails.add(CourseDetail());
            });
          },
          child: Text('Add Course Detail'),
        ),
      ],
    );
  }
}


class CourseDetailsWidget extends StatelessWidget {
  final CourseDetail course;
  final List<String> courseNames;
  final ValueChanged<List<String>> onChanged; // Callback to notify parent about changes
String CourseNAME=' ';
  CourseDetailsWidget({
    Key? key,
    required this.course,
    required this.courseNames,
    required this.onChanged, required String selectedCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDropdownButtonCourseName(
            label: 'Course Name',
            controller: course.selectedCourseName,
            defaultValue: 'Select Course Name',
            prefixIcon: Icons.school,
            items: courseNames.map((name) {
              return DropdownMenuItem(
                value: name,
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.black),
                    SizedBox(width: 8),
                    Text(name, style: TextStyle(color: Colors.black)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              print(courseNames);
              course.selectedCourseNameController.text = value.toString();
              course.selectedCourseName = value.toString();
              CourseNAME=value.toString();
              onChanged(courseNames.where((name) => name != value.toString()).toList());
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildValidatedTextField(
            controller: course.creditHoursController,
            labelText: 'Credit Hours',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Credit Hours';
              }
              return null;
            },
            prefixIcon: Icons.format_list_numbered,
          ),
        ),
        SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            context.findAncestorStateOfType<_AddNewStudyPlanState>()?.setState(() {
              context.findAncestorStateOfType<_SemesterDetailsWidgetState>()?.setState(() {
                context.findAncestorStateOfType<_AddNewStudyPlanState>()?.studyPlanDetails
                    .elementAt(context.findAncestorStateOfType<_SemesterDetailsWidgetState>()!.widget.semesterIndex)
                    .semestersDetails.remove(course);
              });
            });
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
        // You can handle onChanged if needed
      },
      validator: validator,
    );
  }



  Widget _buildDropdownButtonCourseName({ // Updated function name
    required String label,
    required String controller,
    String defaultValue = '',
    IconData? prefixIcon,
  required List<DropdownMenuItem<String>> items,
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
          value: controller.isNotEmpty ? controller : null,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: defaultValue,
            hintStyle: TextStyle(color: Colors.black),
          ),
          validator: (value) {
            if (value == null || value.isEmpty ||
                value == 'Select Course Name') {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }
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

class SemesterDetail {
  List<CourseDetail> semestersDetails = [];
}

class CourseDetail {
  String selectedCourseName = ''; // Updated variable name
  TextEditingController selectedCourseNameController = TextEditingController();
  TextEditingController creditHoursController = TextEditingController(); // Updated variable name
}
Future<List<String>>fetchCourseNames() async {
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
    List<String> courseNames = data.map((item) => item.toString()).toList();
    return courseNames;
  } else {
    throw Exception('Failed to load batch_ids');
  }
}