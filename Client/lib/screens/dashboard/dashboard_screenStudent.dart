import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/header.dart';

class DashboardScreenStudent extends StatefulWidget {
  final String parameter;

  // Constructor to receive the parameter
  DashboardScreenStudent({required this.parameter});

  @override
  _DashboardScreenStudentState createState() => _DashboardScreenStudentState();
}

class _DashboardScreenStudentState extends State<DashboardScreenStudent> {


  @override


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(Parameter: widget.parameter),
            SizedBox(height: defaultPadding),
            // Display student information


          ],
        ),
      ),
    );
  }
}
