// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_trek/firebase_options.dart';
import 'package:talk_trek/screens/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Shared Preferences.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  runApp(TalkTrekApp(username));
}
