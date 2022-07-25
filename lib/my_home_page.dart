// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/shared_preferences.dart';
import 'package:todo_list/sql_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  String _taskStatus = 'TODO';

  //All Todos Collections
  List<Map<String, dynamic>> _todosCollection = [];

  DateTime _selectedDate = DateTime.now();
  String _selectedDateToString =
      "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year.toString()}";

  validateData(int? id) async {
    if (formKey.currentState!.validate()) {
      print('-----------------');
      print('Form is validated');
      print('-----------------');
      if (id == null) {
        if (_taskDescriptionController.text.isEmpty) {
          _taskDescriptionController.text = '';
        }
        await _addItem();
        await Fluttertoast.showToast(
          msg: 'Task Create Successfully', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 1,
        );
      }

      if (id != null) {
        if (_taskDescriptionController.text.isEmpty) {
          _taskDescriptionController.text = '';
        }
        await _updateItem(id);
        await Fluttertoast.showToast(
          msg: 'Task Update Successfully', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 1,
        );
      }
      _taskTitleController.clear();
      _taskDescriptionController.clear();

      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await SQLHelper.getTasks();
    setState(() {
      _todosCollection = data;
      _isLoading = false;
      _taskStatus = 'TODO';
    });
  }

  // Insert a new task to the database
  Future<void> _addItem() async {
    await SQLHelper.createTask(
      title: _taskTitleController.text,
      description: _taskDescriptionController.text,
      taskDate: _selectedDateToString,
      taskStatus: _taskStatus,
    );
    _refreshData();
  }

  // Update an existing task
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateTask(
      id: id,
      title: _taskTitleController.text,
      description: _taskDescriptionController.text,
      taskDate: _selectedDateToString,
      taskStatus: _taskStatus,
    );

    _refreshData();
  }

  Future<void> _updateTaskStatus(
      {required int id,
      required String title,
      required String description,
      required String date,
      required String status}) async {
    await SQLHelper.updateTask(
      id: id,
      title: title,
      description: description,
      taskDate: date,
      taskStatus: status,
    );
    _refreshData();
  }

  // Delete task from database
  void _deleteItem(int id) async {
    await SQLHelper.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task Deleted Successfully'),
    ));
    _refreshData();
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: 90.0,
                  height: 90.0,
                  child: Image.asset('assets/todoListApp.png')),
              const SizedBox(width: 10.0),
              Text(
                'List',
                style: TextStyle(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  color: isLightTheme ? Colors.black : Colors.white,
                ),
//          GoogleFonts.oswald(color: Colors.cyan, fontSize: 25),
              ),
            ],
          ),
          backgroundColor: NeumorphicTheme.baseColor(context),
          elevation: isLightTheme ? 3 : 3,
          shadowColor:
              isLightTheme ? const Color(0xff616161) : const Color(0xff3E3E3E),
          actions: [
            IconButton(
              icon: Icon(
                  isLightTheme
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: isLightTheme ? Colors.black : Colors.white),
              splashRadius: 20.0,
              onPressed: () {
                setState(() {
                  isLightTheme = !isLightTheme;
                  savePreference(isLightTheme.toString());
                  isTrue = true;
                });
                print('theme is toggle successfully');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ));
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(40.0, 40.0),
            child: TabBar(
              indicatorColor: Colors.deepOrange,
              labelColor: isLightTheme ? Colors.black : Colors.white,
              indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 5.0, color: Colors.deepOrange),
                  insets: EdgeInsets.symmetric(horizontal: 20.0)),
              tabs: const [
                Tab(text: 'Todo Task'),
                Tab(text: 'Completed Task'),
              ],
            ),
          ),
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: TabBarView(
          children: [
            //Todos Task Section
            Scaffold(
              body: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.0, color: Color(0xffF3520C)),
                    )
                  : ListView.builder(
                      itemCount: _todosCollection.length,
                      itemBuilder: (context, index) {
                        int todoTask = 0;
                        if (_todosCollection[index]['taskStatus'] == 'TODO') {
                          todoTask++;
                        }
                        print('Total Todo Tasks  : $todoTask');
                        var fromTop =
                            (MediaQuery.of(context).size.height) / 2.5;

                        // print('Id : ${_todosCollection[index]['id']}');
                        return _todosCollection[index]['taskStatus'] == 'TODO'
                            ? AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  child: Neumorphic(
                                    style: const NeumorphicStyle(
                                      depth: 2,
                                      intensity: 0.97,
                                    ),
                                    child: SizedBox(
                                      height: 120,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
//                            const SizedBox(height: 2.0),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 4.0),
                                              child: Text(
                                                  _todosCollection[index]
                                                      ['taskTitle'],
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
//                            const SizedBox(height: 5.0),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25.0),
                                              child: Text(
                                                  _todosCollection[index]
                                                      ['taskDescription'],
                                                  style: const TextStyle(
                                                      fontSize: 15)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    _todosCollection[index]
                                                        ['taskDate'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isLightTheme
                                                            ? Colors.black
                                                            : Colors.white)),
                                                TextButton(
                                                  onPressed: () {
                                                    print(
                                                        _todosCollection[index]
                                                            ['id']);
                                                    print(
                                                        _todosCollection[index]
                                                            ['taskTitle']);
                                                    print(
                                                        _todosCollection[index]
                                                            ['taskStatus']);
                                                    if (_todosCollection[index]
                                                            ['taskStatus'] ==
                                                        'TODO') {
                                                      setState(() {
                                                        _taskStatus =
                                                            'COMPLETED';
                                                      });
                                                    } else if (_todosCollection[
                                                                index]
                                                            ['taskStatus'] ==
                                                        'COMPLETED') {
                                                      setState(() {
                                                        _taskStatus = 'TODO';
                                                      });
                                                    }
                                                    _updateTaskStatus(
                                                      id: _todosCollection[
                                                          index]['id'],
                                                      title: _todosCollection[
                                                          index]['taskTitle'],
                                                      description:
                                                          _todosCollection[
                                                                  index][
                                                              'taskDescription'],
                                                      status: _taskStatus,
                                                      date: _todosCollection[
                                                          index]['taskDate'],
                                                    );
                                                  },
                                                  child: Text(
                                                      _todosCollection[index]
                                                          ['taskStatus'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _todosCollection[
                                                                          index]
                                                                      [
                                                                      'taskStatus'] ==
                                                                  'TODO'
                                                              ? Colors
                                                                  .deepOrange
                                                              : Colors.green)),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: isLightTheme
                                                              ? Colors.black
                                                              : Colors.white),
                                                      onPressed: () =>
                                                          openDialog(
                                                              _todosCollection[
                                                                  index]['id']),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(Icons.delete,
                                                            color: isLightTheme
                                                                ? Colors.black
                                                                : Colors.white),
                                                        onPressed: () async {
                                                          openDeleteDialog(
                                                              _todosCollection[
                                                                  index]['id'],
                                                              _todosCollection[
                                                                      index][
                                                                  'taskTitle']);
                                                        }),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
            ),
            //Completed Task Section
            Scaffold(
              body: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.0, color: Color(0xffF3520C)),
                    )
                  : ListView.builder(
                      itemCount: _todosCollection.length,
                      itemBuilder: (context, index) {
                        int completedTask = 0;
                        if (_todosCollection[index]['taskStatus'] ==
                            'COMPLETED') {
                          completedTask++;
                        }
                        print('Total Completed Tasks  : $completedTask');
                        var fromTop =
                            (MediaQuery.of(context).size.height) / 2.5;
                        return _todosCollection[index]['taskStatus'] ==
                                'COMPLETED'
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  child: Neumorphic(
                                    style: const NeumorphicStyle(
                                      depth: 2,
                                      intensity: 0.97,
                                    ),
                                    child: SizedBox(
                                      height: 120,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
//                            const SizedBox(height: 2.0),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 4.0),
                                              child: Text(
                                                  _todosCollection[index]
                                                      ['taskTitle'],
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
//                            const SizedBox(height: 5.0),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25.0),
                                              child: Text(
                                                  _todosCollection[index]
                                                      ['taskDescription'],
                                                  style: const TextStyle(
                                                      fontSize: 15)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    _todosCollection[index]
                                                        ['taskDate'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isLightTheme
                                                            ? Colors.black
                                                            : Colors.white)),
                                                TextButton(
                                                  onPressed: () {
                                                    print(
                                                        _todosCollection[index]
                                                            ['id']);
                                                    print(
                                                        _todosCollection[index]
                                                            ['taskTitle']);
                                                    print(
                                                        _todosCollection[index]
                                                            ['taskStatus']);
                                                    if (_todosCollection[index]
                                                            ['taskStatus'] ==
                                                        'TODO') {
                                                      setState(() {
                                                        _taskStatus =
                                                            'COMPLETED';
                                                      });
                                                    } else if (_todosCollection[
                                                                index]
                                                            ['taskStatus'] ==
                                                        'COMPLETED') {
                                                      setState(() {
                                                        _taskStatus = 'TODO';
                                                      });
                                                    }
                                                    _updateTaskStatus(
                                                      id: _todosCollection[
                                                          index]['id'],
                                                      title: _todosCollection[
                                                          index]['taskTitle'],
                                                      description:
                                                          _todosCollection[
                                                                  index][
                                                              'taskDescription'],
                                                      status: _taskStatus,
                                                      date: _todosCollection[
                                                          index]['taskDate'],
                                                    );
                                                  },
                                                  child: Text(
                                                      _todosCollection[index]
                                                          ['taskStatus'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _todosCollection[
                                                                          index]
                                                                      [
                                                                      'taskStatus'] ==
                                                                  'TODO'
                                                              ? Colors
                                                                  .deepOrange
                                                              : Colors.green)),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: isLightTheme
                                                              ? Colors.black
                                                              : Colors.white),
                                                      onPressed: () =>
                                                          openDialog(
                                                              _todosCollection[
                                                                  index]['id']),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(Icons.delete,
                                                            color: isLightTheme
                                                                ? Colors.black
                                                                : Colors.white),
                                                        onPressed: () async {
                                                          openDeleteDialog(
                                                              _todosCollection[
                                                                  index]['id'],
                                                              _todosCollection[
                                                                      index][
                                                                  'taskTitle']);
                                                        }),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: NeumorphicFloatingActionButton(
          tooltip: 'Add New Task',
          child: Icon(
            Icons.add,
            size: 30,
            color: isLightTheme ? Colors.black : Colors.white,
          ),
          style: const NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 3,
            intensity: 0.97,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          onPressed: () async {
            openDialog(null);
          },
        ),
      ),
    );
  }

  openDialog(int? id) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            if (id != null) {
              // id == null -> create new item
              // id != null -> update an existing item
              final existingTask =
                  _todosCollection.firstWhere((element) => element['id'] == id);
              _taskTitleController.text = existingTask['taskTitle'];

              _taskDescriptionController.text = existingTask['taskDescription'];
              _selectedDateToString = existingTask['taskDate'];
              _taskStatus = existingTask['taskStatus'];
              print(_taskStatus);
            }
            return AlertDialog(
              backgroundColor: isLightTheme
                  ? const Color(0xffDDDDDD)
                  : const Color(0xFF3E3E3E),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: const Center(child: Text('Create New Task')),
              content: Neumorphic(
                style: const NeumorphicStyle(
                  depth: 0,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    width: width,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                    height: 300.0,
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            child: TextFormField(
                              style: TextStyle(
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Task Title',
                                isDense: true,
                                labelStyle: TextStyle(
                                  color: isLightTheme
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                hintText: 'Enter Title',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.transparent,
                                focusColor: Colors.white,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Colors.cyan, width: 2.0),
                                ),
                                prefixText: '  ',
                              ),
                              controller: _taskTitleController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter task title';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0,
                                right: 15.0,
                                left: 15.0,
                                bottom: 10.0),
                            child: TextFormField(
                              style: TextStyle(
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              maxLines: 2,
                              maxLength: 100,
                              decoration: InputDecoration(
                                labelText: 'Task Description',
                                isDense: true,
                                labelStyle: TextStyle(
                                  color: isLightTheme
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                hintText: 'Enter Description [Optional]',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.transparent,
                                focusColor: Colors.white,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Colors.cyan, width: 2.0),
                                ),
                                prefixText: '  ',
                              ),
                              controller: _taskDescriptionController,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0, bottom: 5.0),
                            child: Text(
                              'Select Task Date',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          buildDatePicker(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                //CANCEL Button
                NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    depth: 0.5,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                  ),
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    _taskTitleController.clear();
                    _taskDescriptionController.clear();
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                //CREATE Button
                NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    depth: 0.5,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                  ),
                  onPressed: () {
                    validateData(id);
                  },
                  child: Text(
                    id == null ? 'Create New' : 'Update',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          },
        ),
      );

  openDeleteDialog(int id, String title) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return AlertDialog(
              backgroundColor: isLightTheme
                  ? const Color(0xffDDDDDD)
                  : const Color(0xFF3E3E3E),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: const Center(child: Text('Delete Task')),
              content: Neumorphic(
                style: const NeumorphicStyle(
                  depth: 0,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    width: width,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                    height: 80.0,
                    child: Center(
                        child: Column(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.fade)),
                        ),
                        const Text('Do you want to delete the task'),
                        const Text('Deleted task cannot be recovered',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                                color: Colors.red)),
                      ],
                    )),
                  ),
                ),
              ),
              actions: [
                //CANCEL Button
                NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    depth: 0.5,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                //CREATE Button
                NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    depth: 0.5,
                    color: isLightTheme
                        ? const Color(0xffDDDDDD)
                        : const Color(0xFF3E3E3E),
                  ),
                  onPressed: () {
                    //Delete a task
                    _deleteItem(id);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      );
  Widget buildDatePicker() {
    return SizedBox(
      height: 55,
      child: CupertinoTheme(
        data: CupertinoThemeData(
            brightness: isLightTheme ? Brightness.light : Brightness.dark),
        child: CupertinoDatePicker(
          initialDateTime: DateTime.now(),
          mode: CupertinoDatePickerMode.date,
          maximumYear: 3050,
          minimumYear: DateTime.now().year,
          onDateTimeChanged: (date) {
            setState(() {
              _selectedDate = date;
              _selectedDateToString =
                  "${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year.toString()}";
              print('----------------------------------------------');
              print('_selectedDateToString : $_selectedDateToString');
            });
          },
        ),
      ),
    );
  }
}
