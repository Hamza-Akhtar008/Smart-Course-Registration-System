
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/header.dart';

class DashboardScreenHOD extends StatelessWidget {
  String parameter; // Add a parameter variable
  // Constructor to receive the parameter
  DashboardScreenHOD({required this.parameter});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header( Parameter: parameter),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(


                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
