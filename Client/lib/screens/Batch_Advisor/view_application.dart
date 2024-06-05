import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/controllers/MenuAppController.dart';
import 'package:smart_course_registration_system/responsive.dart';
import 'package:smart_course_registration_system/screens/dashboard/dashboard_screenhod.dart';
import '../main/components/side_menu_advisor.dart';

class ViewApplicationAdvisor extends StatefulWidget {
  @override
  _ViewApplicationState createState() => _ViewApplicationState();
}

class _ViewApplicationState extends State<ViewApplicationAdvisor> {
  List<Map<String, dynamic>> applications = [];

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('http://localhost:5000/registrationappication/get_all_registration_application'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> responseData2 = json.decode(response.body);

        if (responseData2.containsKey('registrationapp')) {
          List<Map<String, dynamic>> registrationApps = List<Map<String, dynamic>>.from(responseData2['registrationapp']);

          applications = registrationApps;
        } else {
          print('No registration applications found.');
        }
      });
    } else {
      throw Exception('Failed to load applications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenuAdvisor(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) SideMenuAdvisor(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreenHOD(parameter: "View Application"),
                      (applications.isNotEmpty)
                          ? ApplicationTable(data: applications)
                          : Text('No Registration Application Found',style:TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold) ,),
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
class ApplicationTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  ApplicationTable({required this.data});

  @override
  _ApplicationTableState createState() => _ApplicationTableState();
}
class _ApplicationTableState extends State<ApplicationTable> {
  List<Map<String, dynamic>> filteredData = [];
  String selectedStatus = 'none';

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredData = widget.data;
      filterByStatus('none');
    });
  }

  void filterData(String query) {
    setState(() {
      filteredData = widget.data
          .where((application) => application.values.any(
              (value) => value.toString().toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
    print(filteredData);
  }

  void filterByStatus(String status) {
    setState(() {
      selectedStatus = status;
      filteredData = widget.data.where((application) {
        if (status == 'none') {
          return application['isRecommended']==false;
        } else {
          return application[status] == true;
        }
      }).toList();
    });
    print(filteredData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.black),
              prefixIcon: Icon(Icons.search, color: Colors.black),
            ),
            style: TextStyle(color: Colors.black),
            onChanged: filterData,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            FilterChip(
              label: Text('Recommended'),
              selected: selectedStatus == 'isRecommended',
              onSelected: (selected) {
                if (selected) {
                  filterByStatus('isRecommended');
                } else {
                  filterByStatus('none');
                }
              },
            ),
            FilterChip(
              label: Text('None'),
              selected: selectedStatus == 'none',
              onSelected: (selected) {
                filterByStatus('none');
              },
            ),
          ],
        ),
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
          ),
          child: PaginatedDataTable(
            columns: [
              DataColumn(label: Text('Application ID')),
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Recommended')),
              DataColumn(label: Text('Batch Advisor Comment')),
              DataColumn(label: Text('View Application Button')),
            ],
            source: _ApplicationDataSource(filteredData, context),
            header: Text('Application Records'),
            rowsPerPage: 5,
          ),
        ),
      ],
    );
  }
}

class _ApplicationDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final BuildContext _context;

  _ApplicationDataSource(this._data, this._context);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final application = _data[index];

    return DataRow(cells: [
      DataCell(Center(child: Text('${application['application_id']}'))),
      DataCell(Center(child: Text('${application['student_id']}'))),
      DataCell(Center(child: Text('${application['isRecommended']}'))),
      DataCell(Center(
          child: Text(
              '${(application['batchAdvisorComment'].isEmpty) ? "NO Comment Available" : application['batchAdvisorComment']}'))),
      DataCell(
        Center(
          child: IconButton(
            icon: Icon(Icons.open_in_browser),
            color: Colors.blueGrey,
            onPressed: () =>
                _sendData(application['student_id'], application['application_id'], _context),
          ),
        ),
      )
    ]);
  }

  void _sendData(String studentId, int applicationId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('student_id', studentId);
    prefs.setInt('application_id', applicationId);

    Navigator.pushNamed(context, '/approve_reject_application');
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
