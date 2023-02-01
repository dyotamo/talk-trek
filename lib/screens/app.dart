import 'package:flutter/material.dart';
import 'package:talk_trek/screens/chat.dart';
import 'package:talk_trek/screens/select_user.dart';

class TalkTrekApp extends StatelessWidget {
  final String? username;

  const TalkTrekApp(this.username, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      title: 'Talk Trek',
      home: username == null ? SelectUserScreen() : ChatScreen(username!),
    );
  }
}
