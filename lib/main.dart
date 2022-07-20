// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:todo_list/my_home_page.dart';
import 'package:todo_list/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

bool isLightTheme = true;
bool isTrue = true;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  readSavePreferences() async {
    // ignore: non_constant_identifier_names
    var value = await readPreferences();
    // ignore: unnecessary_null_comparison
    setState(() {
      isLightTheme = value;
    });
    print('-----------------------------------');
    print('$value Theme Read Successfully');
  }

  @override
  void initState() {
    super.initState();
    readSavePreferences();
  }

  @override
  Widget build(BuildContext context) {
    print('My app build is called');

    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: const NeumorphicThemeData(
        baseColor: Color(0xffDDDDDD),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 10,
        shadowLightColor: Color(0xff616161),
      ),
      home: const MyHomePage(),
    );
  }
}
