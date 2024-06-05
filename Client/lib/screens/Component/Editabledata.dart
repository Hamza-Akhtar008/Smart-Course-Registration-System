import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class EditableDataTable extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final String deleteurl;
  final String editurl;
   String redirect;

  EditableDataTable({
    required this.headers,
    required this.data,
    required this.deleteurl,
    required this.redirect,
    required this.editurl,
  });

  @override
  _EditableDataTableState createState() => _EditableDataTableState();
}

class _EditableDataTableState extends State<EditableDataTable> {
  final Map<String, Map<int, TextEditingController>> editingControllers = {};
  bool isRowEditing = false;
  int editingRowIndex = -1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _initializeEditingControllers();
  }

  void _initializeEditingControllers() {
    for (String header in widget.headers) {
      editingControllers[header] = {};
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child:
            Column(
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
    child:
            PaginatedDataTable(
              columns: _buildDataColumns(),
              source: _MyDataTableSource(
                data: widget.data,
                editingControllers: editingControllers,
                isRowEditing: isRowEditing,
                editingRowIndex: editingRowIndex,
                onEdit: (int rowIndex) {
                  setState(() {
                    isRowEditing = true;
                    editingRowIndex = rowIndex;
                    _populateEditingControllers(rowIndex);
                  });
                },
                onSave: (int rowIndex) {
                  if (_formKey.currentState!.validate()) {
                    _saveEntry(rowIndex);
                    setState(() {
                      isRowEditing = false;
                      editingRowIndex = -1;
                    });
                  }
                },
                onDelete: (int rowIndex) {
                  _showDeleteConfirmationDialog(rowIndex);
                },
                headers: widget.headers,
                context: context,
              ),
              rowsPerPage: 5,
              showFirstLastButtons: true,
              availableRowsPerPage: const [5, 10, 15, 20],
            ),
            )
          ],
            
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    if (widget.headers == null || widget.headers.isEmpty) {
      return [];
    }

    return widget.headers.map((header) => DataColumn(label: Text(header))).toList();
  }


  void _populateEditingControllers(int rowIndex) {
    // Reset all controllers for all rows


    // Populate controllers for the specified row index
    if (isRowEditing) {
      editingControllers.forEach((key, controllerMap) {
        if (key.toString() != widget.headers[0].toString()) {
          controllerMap[rowIndex] ??= TextEditingController();
          controllerMap[rowIndex]!.text = widget.data[rowIndex][key].toString();
        }
      });
    }
  }

  void _showDeleteConfirmationDialog(int rowIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Do you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteEntry(rowIndex); // Implement your delete logic here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int rowIndex) async {
    // Get the ID from the data at the specified rowIndex
    print(rowIndex);

    final String entryId = widget.data[rowIndex][widget.headers[0]].toString();
    final data;
    if(widget.headers.contains('Course_Type'))
  {
    data = {

    '${widget.headers[0]}': entryId,
      'Course_Type':widget.data[rowIndex]['Course_Type'].toString(),
    };
  }
    else if (widget.headers.contains('offering'))
      {
        data = {

          'id': widget.data[rowIndex]['id'].toString(),

        };
      }
    else
      {
        data = {
          '${widget.headers[0]}': entryId,
        };
      }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    // Make a DELETE request to your server
    final response = await http.delete(
      Uri.parse(widget.deleteurl),
      headers: head,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // You might want to update your local data or perform any other necessary actions
      setState(() {
        // Remove the deleted item from the data list
        widget.data.removeAt(rowIndex);

        // Reset editing state
        isRowEditing = false;
        editingRowIndex = -1;
      });

      // Successful deletion
      showLoginSuccessToast('Entry deleted successfully');
    } else {
      // Handle the error, e.g., show an error message
      showLoginFailedToast('Error deleting entry: ${response.statusCode}');
    }
  }

  Future<void> _saveEntry(int rowIndex) async {
    final Map<String, dynamic> rowData ={};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    editingControllers.forEach((key, controllerMap) {
      if(key.toString()==widget.headers[0].toString()) {
        rowData[key]=widget.data[rowIndex][key];
        }
      else {
        rowData[key]=controllerMap[rowIndex]!.text;
      }});


    final response = await http.patch(
      Uri.parse(widget.editurl),
      headers: head,
      body: json.encode(rowData),
    );
    if (response.statusCode == 200) {
      // You might want to update your local data or perform any other necessary actions
      setState(() {

        // Reset editing state
        isRowEditing = false;
        editingRowIndex = -1;
      });

      // Successful deletion
      showLoginSuccessToast('Entry Edited successfully');


      Navigator.pushNamed(context, widget.redirect);
    } else {
      // Handle the error, e.g., show an error message
      showLoginFailedToast('Error Editing entry: ${response.statusCode}');
      Navigator.pushNamed(context,  widget.redirect);
    }

  }

}

class _MyDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Map<String, Map<int, TextEditingController>> editingControllers;
  final bool isRowEditing;
  final int editingRowIndex;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onSave;
  final ValueChanged<int> onDelete;
  final List<String> headers;
  BuildContext context;
  _MyDataTableSource({
    required this.data,
    required this.editingControllers,
    required this.isRowEditing,
    required this.editingRowIndex,
    required this.onEdit,
    required this.onSave,
    required this.onDelete,
    required this.headers,
    required this.context,
  });

  @override
  DataRow getRow(int index) {

    return DataRow(
      cells: _buildDataCells(index,context),
    );
  }
  List<DataCell> _buildDataCells(int index, BuildContext context) {
    final List<DataCell> cells = [];
    for (String key in headers) {

      if (key.toLowerCase().contains('address')) {
        // If header contains "address" (case insensitive)
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return isRowEditing && index == editingRowIndex
                  ? TextFormField(
                controller: editingControllers[key]![index] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Enter $key',
                ),
                validator: (value) {
                  if (isRowEditing && index == editingRowIndex) {
                    // Add validation only for fields in editing mode
                    if (value == null || value.isEmpty) {
                      return 'Address cannot be null';
                    }
                  }
                  return null;
                },
              )
                  : Text(data[index][key].toString());
            },
          ),
        ));
        continue;
      }

      if((key=='Course_Name' || key=='Course_Type') &&
          isRowEditing &&
          index == editingRowIndex)
      {
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return FutureBuilder<List<DropdownMenuItem<String>>>(
                future: _buildDropdownItemsForCoursetypeandName(
                    editingControllers[key]![index]!, index, key),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return isRowEditing && index == editingRowIndex
                        ? DropdownButtonFormField<String>(
                      value: _buildDropdownValueForCoursetypeandName(
                          editingControllers[key]![index]!.text, index, key),
                      items: snapshot.data,
                      onChanged: (newValue) {
                        editingControllers[key]![index]!.text = newValue!;
                      },
                      decoration: InputDecoration(
                        hintText: 'Select $key',
                      ),
                      validator: (value) {
                        if (isRowEditing) {
                          // Add validation only for fields in editing mode
                          if (value == null || value.isEmpty) {
                            return 'Please select a value';
                          }
                        }
                        return null;
                      },
                    ):Text(data[index][key].toString());
                  }
                },
              );
            },
          ),
        ));

        continue;
      }

      if (key.toLowerCase().contains('name')) {
        // If header contains "name" (case insensitive)
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return isRowEditing && index == editingRowIndex
                  ? TextFormField(
                controller: editingControllers[key]![index] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Enter $key',
                ),
                validator: (value) {
                  if (isRowEditing && index == editingRowIndex) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    } else if (RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Name Cant be numbers';
                    }
                  }
                  return null;
                },
              )
                  : Text(data[index][key].toString());
            },
          ),
        ));
        continue;
      }
      if (key.toLowerCase().contains('contact')) {
        // If header contains "contact" (case insensitive)
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return isRowEditing && index == editingRowIndex
                  ? TextFormField(
                controller:
                editingControllers[key]![index] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Enter $key',
                ),
                validator: (value) {
                  if (isRowEditing && index == editingRowIndex) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Only numbers allowed';
                    } else if (value.length != 11) {
                      return 'Contact must be 11 digits';
                    }
                  }
                  return null;
                },
              )
                  : Text(data[index][key].toString());
            },
          ),
        ));
        continue;
      }
      if (key.toLowerCase().contains('email')) {
        // If header contains "email" (case insensitive)
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return isRowEditing && index == editingRowIndex
                  ? TextFormField(
                controller:
                editingControllers[key]![index] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Enter $key',
                ),
                validator: (value) {
                  if (isRowEditing && index == editingRowIndex) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    } else if (!RegExp(
                        r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value)) {
                      return 'Invalid email address';
                    }
                  }
                  return null;
                },
              )
                  : Text(data[index][key].toString());
            },
          ),
        ));
        continue;
      }
      if (key == 'studyplan_details') {
        cells.add(DataCell(Text("View STUDYPLAN DETAILS"), onTap: () {
          _viewStudyPlanDetails(context, index);
        }));
        continue;
      }
      if (key.toString() == headers[0].toString()) {
        cells.add(DataCell(
          Text(data[index][key].toString()),
        ));
        continue;
      }
      if (key.toLowerCase().contains('description')) {
        // If header contains "description" (case insensitive)
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return isRowEditing && index == editingRowIndex
                  ? TextFormField(
                controller:
                editingControllers[key]![index] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Enter $key',
                ),
                validator: (value) {
                  if (isRowEditing && index == editingRowIndex) {
                    // Add validation only for fields in editing mode
                    if (value == null || value.isEmpty) {
                      return 'Description cannot be null';
                    }
                  }
                  return null;
                },
              )
                  : Text(data[index][key].toString());
            },
          ),
        ));
        continue;
      }



      final dynamic cellValue = data[index][key];

      if ((key == 'depart_id' || key == 'batch_id') &&
          isRowEditing &&
          index == editingRowIndex) {
        // If editing "depart_id" or "batch_id" and is the selected row, show a dropdown
        cells.add(DataCell(
          FormField(
            builder: (FormFieldState<String> field) {
              return FutureBuilder<List<DropdownMenuItem<String>>>(
                future: _buildDropdownItemsForDepartId(
                    editingControllers[key]![index]!, index, key),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return isRowEditing && index == editingRowIndex
                        ? DropdownButtonFormField<String>(
                      value: _buildDropdownValueForDepartId(
                          editingControllers[key]![index]!.text, index, key),
                      items: snapshot.data,
                      onChanged: (newValue) {
                        editingControllers[key]![index]!.text = newValue!;
                      },
                      decoration: InputDecoration(
                        hintText: 'Select $key',
                      ),
                      validator: (value) {
                        if (isRowEditing) {
                          // Add validation only for fields in editing mode
                          if (value == null || value.isEmpty) {
                            return 'Please select a value';
                          }
                        }
                        return null;
                      },
                    ):Text(data[index][key].toString());
                  }
                },
              );
            },
          ),
        ));
      } else {
        // Check if the cell value is null
        if (cellValue != null) {
          // For other columns, show either a TextFormField or Text
          cells.add(DataCell(
            FormField(
              builder: (FormFieldState<String> field) {
                return isRowEditing && index == editingRowIndex
                    ? TextFormField(
                  controller:
                  editingControllers[key]![index] ?? TextEditingController(),
                  decoration: InputDecoration(
                    hintText: 'Enter $key',
                  ),
                  validator: (value) {
                    if (isRowEditing && index == editingRowIndex) {
                      // Add validation only for fields in editing mode
                      if (value == null || value.isEmpty) {
                        return 'Cannot be empty';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Must be a number';
                      }
                    }
                    return null;
                  },
                )
                    : Text(data[index][key].toString());
              },
            ),
          ));

        }
      }
    }

    // Add "Edit" and "Delete" buttons to the header
    if(!headers.contains('offering'))
      {
        cells.add(DataCell(
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.green,
            onPressed: isRowEditing ? () => onSave(index) : () => onEdit(index),
          ),
        ));
      }

    cells.add(DataCell(
      IconButton(
        icon: Icon(Icons.delete),
        color: Colors.red,
        onPressed: () => onDelete(index),
      ),
    ));

    return cells;
  }
  String? _buildDropdownValueForCoursetypeandName(String? text, int index,String? key) {
    if(key=='Course_Type')
    {
      if (text != null) {
        final List<String> dropdownData =
        editingControllers['Course_Type']![index]!.text.split(','); // Split the text into a list
        if (dropdownData.contains(text)) {
          return text;
        }
      }
      return null;
    }
    else
    {
      if (text != null) {
        final List<String> dropdownData =
        editingControllers['Course_Name']![index]!.text.split(','); // Split the text into a list
        if (dropdownData.contains(text)) {
          return text;
        }
      }
      return null;
    }


  }
  String? _buildDropdownValueForDepartId(String? text, int index,String? key) {
    if(key=='depart_id')
      {
        if (text != null) {
          final List<String> dropdownData =
          editingControllers['depart_id']![index]!.text.split(','); // Split the text into a list
          if (dropdownData.contains(text)) {
            return text;
          }
        }
        return null;
      }
    else
      {
        if (text != null) {
          final List<String> dropdownData =
          editingControllers['batch_id']![index]!.text.split(','); // Split the text into a list
          if (dropdownData.contains(text)) {
            return text;
          }
        }
        return null;
      }


  }
  Future<void> _viewStudyPlanDetails(BuildContext context,int index) async {
    print("index : ${index}");
print(data[index][headers[0]]);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${headers[0]}', '${data[index][headers[0]]}');
    Navigator.pushNamed(
      context,
      '/view_study_plan_details',
      arguments:  data[index][headers[0]],
    );
  }
  Future<List<DropdownMenuItem<String>>> _buildDropdownItemsForDepartId(
      TextEditingController controller, int index,String? key) async {
    List<String> dropdownData;
    if(key=='batch_id')
      {
       dropdownData = await fetchbatchids();
      }
    else
      {
       dropdownData = await fetchDepartIds();
      }
   // Assuming you have the fetchDepartIds method

    Set<String> uniqueValues = {};
    List<DropdownMenuItem<String>> dropdownItems = [];

    for (var item in dropdownData) {
      if (!uniqueValues.contains(item.toString())) {
        uniqueValues.add(item.toString());
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item),
          ),
        );
      } else {
        print('Warning: Duplicate value found for ${item}');
        // Handle duplicates (skip or remove as appropriate for your case)
      }
    }

    // Update the value in the controller
    if(key=='depart_id')
      {
        editingControllers['depart_id']![index]!.text = controller.text;
      }
    else
      {
        editingControllers['batch_id']![index]!.text = controller.text;
      }


    return dropdownItems;
  }

  Future<List<DropdownMenuItem<String>>> _buildDropdownItemsForCoursetypeandName(
      TextEditingController controller, int index,String? key) async {
    List<String> dropdownData;
    if(key=='Course_Type')
    {
      dropdownData = await fetchcoursetypeIds();
    }
    else
    {
      dropdownData = await fetchcourseName();
    }
    // Assuming you have the fetchDepartIds method

    Set<String> uniqueValues = {};
    List<DropdownMenuItem<String>> dropdownItems = [];

    for (var item in dropdownData) {
      if (!uniqueValues.contains(item.toString())) {
        uniqueValues.add(item.toString());
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item),
          ),
        );
      } else {
        print('Warning: Duplicate value found for ${item}');
        // Handle duplicates (skip or remove as appropriate for your case)
      }
    }

    // Update the value in the controller
    if(key=='Course_Type')
    {
      editingControllers['Course_Type']![index]!.text = controller.text;
    }
    else
    {
      editingControllers['Course_Name']![index]!.text = controller.text;
    }


    return dropdownItems;
  }


  Future<List<String>> fetchcourseName() async {
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
      List<String> coursetype = data.map((item) => item.toString()).toList();
      return coursetype;
    } else {
      throw Exception('Failed to load batch_ids');
    }
  }
  Future<List<String>> fetchDepartIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    final response =
    await http.get(Uri.parse('http://localhost:5000/managedepart/getalldepartid'),headers: head);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming 'data' is the key containing the list of depart_ids
      final List<dynamic> data = responseData['data'];

      List<String> departIds = data.map((item) => item.toString()).toList();
      return departIds;
    } else {
      throw Exception('Failed to load depart_ids');
    }
  }
  Future<List<String>> fetchcoursetypeIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('http://localhost:5000/managecoursetype/getallcoursetypeid'),
      headers: head,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      List<String> coursetype = data.map((item) => item.toString()).toList();
      return coursetype;
    } else {
      throw Exception('Failed to load batch_ids');
    }
  }
  Future<List<String>> fetchbatchids() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Map<String, String> head = {
      'Authorization': '${token}',
      'Content-Type': 'application/json', // Add any other headers you need
    };
    final response =
    await http.get(Uri.parse('http://localhost:5000/managebatch/getallbatchid'),headers: head);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming 'data' is the key containing the list of depart_ids
      final List<dynamic> data = responseData['data'];

      List<String> departIds = data.map((item) => item.toString()).toList();
      return departIds;
    } else {
      throw Exception('Failed to load depart_ids');
    }
  }
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
