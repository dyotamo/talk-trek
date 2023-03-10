import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
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
      if (text.length <= 2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '$username é um nickname muito curto (o tamanho deve ser maior que 2).')));
        return;
      }

      if (username.toLowerCase() == utils.forbiddenNickname) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('$username não é um nickname permitido no aplicativo.')));
        return;
      }

      final box = GetStorage();
      box.write('username', username);
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
