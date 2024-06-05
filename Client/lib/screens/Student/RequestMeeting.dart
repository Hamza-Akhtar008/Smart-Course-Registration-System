import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_course_registration_system/controllers/MenuAppController.dart';
import 'package:smart_course_registration_system/responsive.dart';
import 'package:smart_course_registration_system/screens/dashboard/dashboard_screenStudent.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menuStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestMeeting extends StatefulWidget {
  @override
  MainRequestMeeting createState() => MainRequestMeeting();
}

class MainRequestMeeting extends State<RequestMeeting> {
  String? selectedCategory = 'Batch Advisor'; // Initial value
  String? selectedPerson = '';
  List<String> categories = ['Batch Advisor', 'HoD'];
  List<String> advisors = [];
  List<String> hodList = [];
  final TextEditingController selectBatchController = TextEditingController();
  final TextEditingController selectNameController = TextEditingController();
  List<Map<String, dynamic>> requestedMeetings = [];
  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the widget is initialized
    _loadRequestedMeetings();
  }
  _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    final String student_id = prefs.getString('userid') ?? '';
    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'student_id': student_id,
    };

    final http.Response response = await http.post(
      Uri.parse('http://localhost:5000/meeting/get_hod_batchadvisor'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        List<Map<String, dynamic>> hodListData = List<Map<String, dynamic>>.from(data['hodList']);
        List<Map<String, dynamic>> advisorsData = List<Map<String, dynamic>>.from(data['advisors']);

        setState(() {
          hodList = hodListData.map((map) => map['Hod_name'].toString()).toList();
          advisors = advisorsData.map((map) => map['advisor_name'].toString()).toList();

        });
      } else {
        // Handle error
        print('Failed to load data: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load data: ${response.statusCode}');
    }
  }
  _addNewMeeting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    final String student_id = prefs.getString('userid') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'student_id': student_id,
      'recipient_type': selectedCategory,
      'recipient_name': selectedPerson,

    };

    final http.Response response = await http.post(
      Uri.parse('http://localhost:5000/meeting/add_new_meeting'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 201) {
      // Meeting added successfully
      showErrorToast('Meeting added successfully!');
      Navigator.pushNamed(context, '/request_meeting');
    } else {
      // Handle error
      showErrorToast('Failed to add meeting: ${response.statusCode}');
      Navigator.pushNamed(context, '/request_meeting');
    }
  }
  _loadRequestedMeetings() async {
    // Fetch the list of requested meetings from the server
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    final String student_id = prefs.getString('userid') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'student_id': student_id,
    };

    final http.Response response = await http.post(
      Uri.parse('http://localhost:5000/meeting/get_requested_meetings'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        List<Map<String, dynamic>> meetingsData = List<Map<String, dynamic>>.from(data['requestedMeetings']);

        setState(() {

          requestedMeetings = meetingsData.map((map) {
            return {
              'meeting_id':map['meeting_id'],
              'recipient_type': map['recipient_type'],
              'recipient_name': map['recipient_name'],
              'meeting_date': map['meeting_date'],
              'meeting_time': map['meeting_time'],
            };
          }).toList();

        });
      } else {
        // Handle error
        print('Failed to load requested meetings: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load requested meetings: ${response.statusCode}');
    }
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
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenuStudent(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) SideMenuStudent(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreenStudent(parameter: "Dashboard"),
                      SizedBox(height: 20),
                      _buildDropdownButton(
                        label: 'Select Recipient Type ',
                        controller: selectBatchController,
                        defaultValue: 'Select Recipient Type ',
                        prefixIcon: Icons.group,
                        items: categories.map((id) {
                          return DropdownMenuItem(
                            value: id,
                            child: Row(
                              children: [
                                Icon(Icons.group, color: Colors.black),
                                SizedBox(width: 8),
                                Text('$id', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectBatchController.text = value ?? '';
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _buildDropdownButton(
                        label: 'Select Name ',
                        controller: selectNameController,
                        defaultValue: 'Select Name ',
                        prefixIcon: Icons.group,
                        items: (selectedCategory == 'Batch Advisor')
                            ? advisors.map((id) {
                          return DropdownMenuItem(
                            value: id,
                            child: Row(
                              children: [
                                Icon(Icons.group, color: Colors.black),
                                SizedBox(width: 8),
                                Text('$id', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        }).toList()
                            : hodList.map((id) {
                          return DropdownMenuItem(
                            value: id,
                            child: Row(
                              children: [
                                Icon(Icons.group, color: Colors.black),
                                SizedBox(width: 8),
                                Text('$id', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPerson = value;
                            selectNameController.text = value ?? '';
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Add a button here
                      ElevatedButton(
                        onPressed: () {
                          _addNewMeeting();
                        },
                        child: Text('Request Meeting'),

                      ),
                      SizedBox(height: 20),
                      // Display the requested meetings using RequestedMeetingsList widget...
                      RequestedMeetingsList(meetings: requestedMeetings),
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
            if (prefixIcon != null) Icon(prefixIcon, color: Colors.black),
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


}
class RequestedMeetingsList extends StatelessWidget {
  final List<Map<String, dynamic>> meetings;

  const RequestedMeetingsList({Key? key, required this.meetings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Requested Meetings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10),
          if (meetings.isNotEmpty)
            Column(
              children: [
                for (Map<String, dynamic> meeting in meetings)
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: ListTile(
                      title: Text(
                        'Recipient Name: ${meeting['recipient_name']}',
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipient Type: ${meeting['recipient_type']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Date: ${meeting['meeting_date'] ?? 'Not provided'}, Time: ${meeting['meeting_time'] ?? 'Not provided'}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Convert meeting_id to String here
                          _withdrawMeetingRequest(context, meeting['meeting_id'].toString());
                        },
                        child: Text('Withdraw'),
                      ),
                    ),
                  ),
              ],
            ),
          if (meetings.isEmpty)
            Text(
              'No requested meetings',
              style: TextStyle(color: Colors.black),
            ),
        ],
      ),
    );
  }

  Future<void> _withdrawMeetingRequest(BuildContext context, String meeting) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {
      'meeting_id': meeting,
    };

    final http.Response response = await http.delete(
      Uri.parse('http://localhost:5000/meeting/delete_request'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        showErrorToast("Meeting WithDrawn");
        Navigator.pushNamed(context, '/request_meeting');
      } else {

        showErrorToast('Meeting not WithDrawn');
        Navigator.pushNamed(context, '/request_meeting');
      }
    } else {
      // Handle error
      print('Failed to load data: ${response.statusCode}');
    }
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
}
