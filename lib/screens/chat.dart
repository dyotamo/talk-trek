import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talk_trek/model.dart';
import 'package:talk_trek/screens/select_user.dart';
import 'package:talk_trek/utils.dart' as utils;
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String _username;

  const ChatScreen(this._username, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messagesStream = FirebaseFirestore.instance
      .collection('messages')
      .orderBy('datetime')
      .limit(utils.maxMessages)
      .snapshots();

  final _db = FirebaseFirestore.instance;

  final _textController = TextEditingController();

  final _messagesListController = ScrollController();
  bool _showScrollDownIcon = false;

  @override
  void initState() {
    super.initState();
    _messagesListController.addListener(() {
      setState(() {
        _showScrollDownIcon = _messagesListController.offset <
            _messagesListController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens')),
      drawer: TalkDrawer(widget._username),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Algum erro occorreu ao se obter as mensagens.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Carregando mensagens...'),
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }

          // Add PT_BR locale.
          timeago.setLocaleMessages('pt_br', timeago.PtBrMessages());

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _messagesListController,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                        var message = Message.fromFirestore(document);
                        return _talkListTile(message);
                      })
                      .toList()
                      .cast(),
                ),
              ),
              if (_showScrollDownIcon)
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: _getDownList,
                ),
              Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'Escreva uma mensagem aqui...',
                          ),
                          onSubmitted: (value) => _addMessage(context),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _addMessage(context),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _talkListTile(Message message) {
    var userColor = utils.getColor(message.username);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (!_isSender(message))
            Row(children: [
              Text(
                _isSender(message) ? 'eu' : message.username,
                style: TextStyle(color: userColor, fontWeight: FontWeight.bold),
              ),
              Text(
                  ' (${timeago.format(message.datetime.toDate(), locale: "pt_br")})',
                  style: const TextStyle(fontSize: 12))
            ]),
          BubbleSpecialOne(
            text: message.message,
            color: _isSender(message)
                ? const Color(0xFF1B97F3)
                : const Color(0xFFE8E8EE),
            tail: false,
            textStyle: TextStyle(
              color: _isSender(message) ? Colors.white : Colors.black,
            ),
            isSender: _isSender(message),
            sent: _isSender(message),
          ),
        ],
      ),
    );
  }

  void _addMessage(BuildContext context) {
    var message = _textController.text;
    if (message.isNotEmpty) {
      // Send the message to Firebase.
      _db
          .collection('messages')
          .doc()
          .set(Message(
            username: widget._username,
            message: message,
            datetime: Timestamp.now(),
          ).toFirestore())
          .onError((e, _) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Algum erro ocorreu ao enviar a mensagem.'))));
      _textController.clear();
    }
  }

  void _getDownList() {
    _messagesListController.animateTo(
      _messagesListController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  bool _isSender(Message message) => widget._username == message.username;
}

class TalkDrawer extends StatelessWidget {
  final String _username;

  const TalkDrawer(this._username, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Olá, $_username!',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Trocar nickname'),
            onTap: () async {
              final box = GetStorage();
              await box.remove('username');
              // ignore: use_build_context_synchronously
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SelectUserScreen()),
                (route) => false,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Sobre'),
            onTap: () => showDialog(
                context: context,
                builder: (context) => AboutDialog(
                      applicationName: 'Talk Trek',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          'Mister Mxyzptlk SA. - ${DateTime.now().year}',
                    )),
          )
        ],
      ),
    );
  }
}
