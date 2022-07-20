// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
final storage = FlutterSecureStorage();

// Write value
savePreference(String themeValue) async {
  await storage.write(key: 'isLightTheme', value: themeValue);
  print('-----------------------------------');
  print('$themeValue Theme Save Successfully');
}

readPreferences() async {
  // Read value
  String? value = await storage.read(key: 'isLightTheme');
  if (value == 'true') {
    return true;
  }
  if (value == 'false') {
    return false;
  }
}
