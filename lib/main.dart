// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talk_trek/firebase_options.dart';
import 'package:talk_trek/screens/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Get Storage.
  await GetStorage.init();
  final box = GetStorage();
  final username = box.read<String>('username');

  // Run app.
  runApp(TalkTrekApp(username));
}
