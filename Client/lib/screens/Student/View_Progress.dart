import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screenStudent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/components/side_menuStudent.dart';
class View_Progress extends StatefulWidget {
  @override
  _View_Progress createState() => _View_Progress();
}

class _View_Progress extends State<View_Progress> {
  List<Map<String, dynamic>> batchAdvisors = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenuStudent(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenuStudent(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: Column(
                children: [
                  DashboardScreenStudent(parameter: "View Progress"),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
