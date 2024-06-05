import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/MenuAppController.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screenStudent.dart';
import '../main/components/side_menuStudent.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:http/http.dart' as http;

class UploadTranscript extends StatefulWidget {
  @override
  _UploadTranscriptState createState() => _UploadTranscriptState();
}

class SemesterDetails {
  final String semester;
  final int courses;

  SemesterDetails({required this.semester, required this.courses});
}

class _UploadTranscriptState extends State<UploadTranscript> {
  File? pdfFile;
  bool uploading = false;
  String message = '';
  String filepath = "";
  List<int> bytes = [];
  bool isLoading = true;
  List<SemesterDetails> semesterDetailsList = [];

  @override
  void initState() {
    super.initState();
    getTranscript();
  }

  void selectPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      if (kIsWeb) {
        filepath = result.files.first.name;
        bytes = result.files.first.bytes!;
        pdfFile = File.fromRawPath(Uint8List.fromList(bytes));
      } else {
        pdfFile = File(result.files.single.path!);
      }

      setState(() {
        message = '';
      });
    }
  }

  double calculateSGPA(String grade) {
    switch (grade) {
      case 'A+':
        return 4.00;
      case 'A':
        return 4.00;
      case 'A-':
        return 3.67;
      case 'B+':
        return 3.33;
      case 'B':
        return 3.00;
      case 'B-':
        return 2.67;
      case 'C+':
        return 2.33;
      case 'C':
        return 2.00;
      case 'C-':
        return 1.67;
      case 'D+':
        return 1.33;
      case 'D':
        return 1.00;
      default:
        return 0.00;
    }
  }



  List<double> calculateSemesterGPA(List<Map<String, String>> semesterCourses, double totalcredithours, double totalgradepoints) {
    double totalGradePoints = 0.0;
    int totalCreditHours = 0;
    totalcredithours=0;
    for (var course in semesterCourses) {
      String grade = course['grade'] ?? '';
      int creditHours = int.tryParse(course['creditHours'] ?? '0') ?? 0;
      if (creditHours > 3) {
        creditHours = 3;
        course['creditHours']='3';
      }
      totalcredithours+=creditHours;
      totalGradePoints += calculateSGPA(grade) * creditHours;
      if(totalGradePoints!=0.00) {
        totalCreditHours += creditHours;
        totalgradepoints += creditHours;
      }
    }

    return [totalCreditHours > 0 ? totalGradePoints / totalCreditHours : 0.0,totalgradepoints,totalcredithours];
  }
  Future<void> uploadTranscripts() async {
    if (pdfFile == null) {
      setState(() {
        message = 'No transcript selected to upload.';
      });
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userid') ?? '';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/upload'),
      );
      print(userId);
      request.fields['student_id'] = userId;

      if (kIsWeb) {
        request.fields['type'] = "web";

        String base64String = base64Encode(bytes);
        request.fields['base64String'] = base64String;
        request.files.add(http.MultipartFile.fromString(
          'file',
          base64String,
          filename: 'transcript.pdf',
        ));
      } else {
        request.fields['type'] = "app";
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          pdfFile!.path,
          filename: 'transcript.pdf',
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);

        setState(() {
          message = jsonData['message'];
        });
      } else {
        setState(() {
          message = 'Response Body: ${response.stream.bytesToString()}';
        });
      }
    } catch (error) {
      setState(() {
        message = 'Error during file upload: $error';
        print(message);
      });
    } finally {
      setState(() {
        uploading = false;
      });
    }
  }

  List<Map<String, dynamic>> Transcriptdetailinfo = [];

  List<Map<String, String>> TranscriptInfo = [
    // ... your transcript info data
  ];

  void getTranscript() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      Uri.parse(
          'http://localhost:5000/gettranscriptstudyplan/getStudyPlansandTranscript'),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true &&
          responseData.containsKey('studyplan_details') &&
          responseData.containsKey('transcriptinfo')) {
        String transcriptInfoString = responseData['transcriptinfo'];
        List<Map<String, String>> transcriptInfo =
        List<Map<String, dynamic>>.from(jsonDecode(transcriptInfoString))
            .map((Map<String, dynamic> entry) => entry.map(
              (key, value) => MapEntry(key, value.toString()),
        ))
            .toList();

        String transcriptdetail = responseData['transcriptdetail'];
        List<Map<String, dynamic>> transcriptdetailInfo =
        List<Map<String, dynamic>>.from(jsonDecode(transcriptdetail));

        setState(() {
          TranscriptInfo = transcriptInfo;
          Transcriptdetailinfo = transcriptdetailInfo;
          semesterDetailsList = Transcriptdetailinfo.map((semester) {
            return SemesterDetails(
              semester: semester['semester'],
              courses: semester['courses'],
            );
          }).toList();
        });
        isLoading = false;
      } else {
        throw Exception('Invalid response structure');

      }
    } else {
      throw Exception('Failed to load transcript');

    }
  }

  Widget _buildSelectedPDFName() {
    return pdfFile != null
        ? Text(
      'Selected PDF: $filepath',
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    )
        : Container();
  }

  Widget _buildSemesterTable() {
    if (isLoading) {
      // If data is still loading, display a loading indicator
      return CircularProgressIndicator();
    }

    double totalcredithours=0;
    double totalgradepoints=0;
    int start = 0;
    double cgpa=0;
    return Column(
      children: semesterDetailsList.map((semesterDetails) {
        // Get the courses for the current semester
        List<Map<String, String>> semesterCourses = TranscriptInfo
            .sublist(start, start + semesterDetails.courses);
        start += semesterDetails.courses;
        List<double> data  = calculateSemesterGPA(semesterCourses,totalcredithours,totalgradepoints);
        totalcredithours=data[2];
        totalgradepoints=data[1];
        double eachgpa=0.00;
        if(data[0]!=0.00)
          {
            cgpa += data[0]*data[2];
            print("Total CreditHours : ${data[2]}");
            print("CGPA : ${cgpa}" );
            print("Total Grade Point : ${data[1]}");
             eachgpa = cgpa/data[1];
          }
        else
          {
            eachgpa = cgpa/data[1];
          }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white70, // Choose your desired background color
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.black, // Choose your desired border color
                  width: 2.0,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SGPA: ${data[0].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'CGPA: ${eachgpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            PaginatedSemesterTableWidget(
              courses: semesterCourses,
              semseter: semesterDetails.semester,
            ),

          ],
        );
      }).toList(),
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
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenuStudent(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardScreenStudent(
                        parameter: "Upload Transcript"),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildSelectedPDFName(),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MaterialButton(
                                color: Colors.blue,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.file_upload,
                                        color: Colors.white),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Pick Your Transcript',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: selectPdfFile,
                              ),
                              MaterialButton(
                                color: Colors.green,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.upload_file,
                                        color: Colors.white),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Upload Transcripts',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: uploadTranscripts,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          _buildSemesterTable(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaginatedSemesterTableWidget extends StatelessWidget {
  final List<Map<String, String>> courses;
  String semseter;
  PaginatedSemesterTableWidget(
      {required this.courses, required this.semseter});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ Theme(
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
      header: Text('${semseter}'),
      rowsPerPage: courses.length,
      columns: [
        DataColumn(label: Text('Course ID')),
        DataColumn(label: Text('Course Name')),
        DataColumn(label: Text('Grade')),
        DataColumn(label: Text('Section')),
        DataColumn(label: Text('credit hours')),
      ],
      source: _SemesterDataSource(courses),
    ),
    ),
    ],
    );
  }
}

class _SemesterDataSource extends DataTableSource {
  final List<Map<String, String>> _courses;

  _SemesterDataSource(this._courses);

  @override
  DataRow getRow(int index) {
    final course = _courses[index];
    return DataRow(cells: [
      DataCell(Text(course['courseId'] ?? '')),
      DataCell(Text(course['Course_Name'] ?? '')),
      DataCell(Text(course['grade'] ?? '')),
      DataCell(Text(course['section'] ?? '')),
      DataCell(Text(course['creditHours']  ??  'null')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _courses.length;

  @override
  int get selectedRowCount => 0;
}
