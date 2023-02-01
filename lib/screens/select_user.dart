import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slugify/slugify.dart';
import 'package:talk_trek/screens/chat.dart';
import 'package:talk_trek/utils.dart' as utils;

class SelectUserScreen extends StatelessWidget {
  final _textController = TextEditingController();

  SelectUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bem-vindo ao Talk Trek')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Introduza o seu nickname:'),
            Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _textController,
                        onSubmitted: (value) => _login(context),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () => _login(context),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ))
          ],
        ));
  }

  void _login(BuildContext context) async {
    var text = _textController.text;
    if (text.isNotEmpty) {
      var username = slugify(text);
      if (username.toLowerCase() == utils.forbiddenNickname) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('$username não é um nickname permitido no aplicativo.')));
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return ChatScreen(username);
          }),
          (route) => false,
        );
      }
    }
  }
}
