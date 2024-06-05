import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/controllers/MenuAppController.dart';
import 'package:smart_course_registration_system/responsive.dart';
import 'package:smart_course_registration_system/screens/dashboard/dashboard_screenhod.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menuHod.dart';
import 'package:smart_course_registration_system/screens/main/components/side_menuStudent.dart';

class Schedule_Meeting extends StatefulWidget {
  @override
  _Schedule_Meeting createState() => _Schedule_Meeting();
}

class _Schedule_Meeting extends State<Schedule_Meeting> {
  List<Map<String, dynamic>> applications = [];

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString('userid') ?? '';
    String token = prefs.getString('token') ?? '';
    String admintype = prefs.getString('usertype')!;

    final Map<String, String> headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };
    final data = {
      'user_id': userId,

      'user_type':admintype,
    };
    final response = await http.post(
      Uri.parse('http://localhost:5000/meeting/get_requested_meeting'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        Map<String, dynamic> responseData2 = json.decode(response.body);
        if (responseData2.containsKey('requestedMeetings')) {
          List<Map<String, dynamic>> registrationApps = List<Map<String, dynamic>>.from(responseData2['requestedMeetings']);
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
      drawer: SideMenuHOD(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) SideMenuHOD(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardScreenHOD(parameter: "View Meeings"),
                      (applications.isNotEmpty)
                          ? ApplicationTable(data: applications)
                          : Text('No Meeings Request Found',style:TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold) ,),
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
          if(application['meeting_date']==null)
            {
              return true;
            }
          else
            {
              return false;
            }

        } else {
          if(application['meeting_date']==null)
          {
            return false;
          }
          else
          {
            return true;
          }
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
              label: Text('Date Time Allocated'),
              selected: selectedStatus == 'approved',
              onSelected: (selected) {
                if (selected) {
                  filterByStatus('isApproved');
                } else {
                  filterByStatus('none');
                }
              },
            ),
            FilterChip(
              label: Text('Date Time Not Allocated'),
              selected: selectedStatus == 'none',
              onSelected: (selected) {
                if (selected) {
                  filterByStatus('none');
                } else {
                  filterByStatus('isApproved');
                }
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
              DataColumn(label: Text('Meeting ID')),
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Meeting Date')),
              DataColumn(label: Text('Meeting Time')),
              DataColumn(label: Text('View Meeing')),
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
    DateTime? submissionDate = DateTime.tryParse((application['meeting_date']==null)?"00:00":application['meeting_date']);
    String formattedSubmissionDate=" ";
    if(submissionDate==null)
      {
        formattedSubmissionDate='Date not Allocated';
      }
    else
      {
        formattedSubmissionDate = submissionDate != null
            ? DateFormat('yyyy-MM-dd').format(submissionDate)
            : 'Date not Allocated';
      }


    return DataRow(cells: [
      DataCell(Center(child: Text('${application['meeting_id']}'))),
      DataCell(Center(child: Text('${application['student_id']}'))),
      DataCell(Center(child: Text('${application['depart_id']}'))),
      DataCell(Center(
          child: Text(
              (formattedSubmissionDate)))),
      DataCell(Center(
          child: Text(
              '${(application['meeting_time']==null) ? "Not Allocated " : application['meeting_time']}'))),
      DataCell(
        Center(
          child: IconButton(
            icon: Icon(Icons.open_in_browser),
            color: Colors.blueGrey,
            onPressed: () =>
                _sendData(application['meeting_id'].toString(), application['student_id'].toString(), _context),
          ),
        ),
      )
    ]);
  }

  void _sendData(String studentId, String applicationId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('meeting_id', studentId.toString());
    prefs.setString('student_id', applicationId.toString());

    Navigator.pushNamed(context, '/allocte_meeting');
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
