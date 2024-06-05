import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/screens/dashboard/dashboard_screenStudent.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menuStudent.dart';
import 'package:smart_course_registration_system/controllers/MenuAppController.dart';
import 'package:smart_course_registration_system/responsive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class RegistrationStatusScreen extends StatefulWidget {
  @override
  _RegistrationStatusScreenState createState() => _RegistrationStatusScreenState();
}
class _RegistrationStatusScreenState extends State<RegistrationStatusScreen> {
  int currentStep = 0; // Set the current step based on your application status
  Map<String, dynamic>? registrationData;
 List<bool> status=[];
  @override
  void initState() {
    super.initState();
    getRegistrationApplication();
  }



  Future<void> getRegistrationApplication() async {
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

    try {
      final http.Response response = await http.post(
        Uri.parse('http://localhost:5000/registrationappication/get_registrationApplication'),
        headers: headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          registrationData = responseData;

          if(registrationData?['createdAt']!=null)
            {
              status.add(true);
            }
          else
            {
              status.add(false);

            }

          status.add(registrationData!['registrationapp']?['isRecommended']);
          status.add(registrationData!['registrationapp']?['isApproved']);
          status.add(registrationData!['registrationapp']?['isProcessed']);

          print(responseData);
        });
      } else {
        print('Failed to get registration application. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting registration application: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
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
                      DashboardScreenStudent(parameter: "Registration Application Status"),
                      SizedBox(height: 20),
                      RegistrationDetails(registrationData: registrationData),
                      SizedBox(height: 20),
                      ApplicationStatusStepper(currentStep: currentStep,stepStatus: status),
                      SizedBox(height: 20),
                      WithdrawButton(),
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

class RegistrationDetails extends StatelessWidget {
  final Map<String, dynamic>? registrationData;

  RegistrationDetails({required this.registrationData});

  @override
  Widget build(BuildContext context) {
    if (registrationData == null || registrationData!.isEmpty) {
      return Text('No Application Submitted', style: TextStyle(color: Colors.black));
    }

    bool isRecommended = registrationData!['registrationapp']?['isRecommended'] ?? false;
    bool isApproved = registrationData!['registrationapp']?['isApproved'] ?? false;
    bool isProcessed = registrationData!['registrationapp']?['isProcessed'] ?? false;

    String submissionDateString = registrationData!['registrationapp']?['createdAt'] ?? 'Not available';
    DateTime? submissionDate = DateTime.tryParse(submissionDateString);
    String formattedSubmissionDate = submissionDate != null
        ? DateFormat('MMMM d, y - HH:mm').format(submissionDate)
        : 'Not available';
    String recommendationDate = registrationData!['registrationapp']?['batchAdvisorComment'] ?? 'Not available';
    String approvalDate = registrationData!['registrationapp']?['hodComments'] ?? 'Not available';
    String processingStartDate = registrationData!['registrationapp']?['processingStartDate'] ?? 'Not available';
    String processingCompletionDate = registrationData!['registrationapp']?['processingCompletionDate'] ?? 'Not available';
    var status =true;
if(submissionDateString=='Not available')
  {
    status=false;
  }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registration Status Details', style: TextStyle(color: Colors.black)),
        StatusDetails(label: 'Submission Date', value: formattedSubmissionDate, icon: Icons.access_time, status: status),
        StatusDetails(label: 'Recommended by Advisor', value: recommendationDate, icon: Icons.access_time, status: isRecommended),
        StatusDetails(label: 'Approval Date', value: approvalDate, icon: Icons.access_time, status: isApproved),
        StatusDetails(label: 'Processing Start Date', value: processingStartDate, icon: Icons.access_time, status: isProcessed),
        StatusDetails(label: 'Processing Completion Date', value: processingCompletionDate, icon: Icons.access_time, status: isProcessed),
      ],
    );
  }
}
class StatusDetails extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool status;

  StatusDetails({required this.label, required this.value, required this.icon, required this.status});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: status ? Colors.green : Colors.red),
        SizedBox(width: 8,height: 20,),
        Text('$label: $value', style: TextStyle(color: Colors.black)),
      ],
    );
  }
}
class ApplicationStatusStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps = ['Submitted', 'Recommended', 'Approved', 'Processed'];
  final List<bool> stepStatus; // Replace with your actual step status values
  ApplicationStatusStepper({required this.currentStep, required this.stepStatus});
  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStep,
      steps: steps.asMap().entries.map((entry) {
        int index = entry.key;
        String step = entry.value;
        bool isActive = index < stepStatus.length ? stepStatus[index] : false;

        return Step(
          title: Text(step, style: TextStyle(color: isActive ? Colors.green : Colors.black)),
          content: Container(
            child: Center(),
          ),
          state: isActive ? StepState.complete : StepState.indexed,
        );
      }).toList(),
    );
  }
}
class WithdrawButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Show a dialog box when the button is pressed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Withdraw Registration'),
              content: Text('Are you sure you want to withdraw your registration application?'),
              actions: [
                TextButton(
                  onPressed: () {
                    deleteRegistrationApplication();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/check_status');
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    // Close the dialog when "No" is pressed
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/check_status');
                  },
                  child: Text('No'),

                ),
              ],
            );
          },
        );
      },
      child: Text('Withdraw Registration'),
    );
  }

  Future<void> deleteRegistrationApplication() async {
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

    try {
      final http.Response response = await http.delete(
        Uri.parse('http://localhost:5000/registrationappication/delete_registrationApplication'),
        headers: headers,
        body: json.encode(requestData),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

          showErrorToast(responseData['message']);

      } else {
        showErrorToast(responseData['message']);
      }
    } catch (error) {
      showErrorToast('Error getting registration application: $error');
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
