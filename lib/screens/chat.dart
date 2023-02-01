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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
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

  ListTile _talkListTile(Message message) {
    var userColor = utils.getColor(message.username);
    return ListTile(
      onLongPress: () {},
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: userColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            message.username[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Row(children: [
        Text(
          widget._username == message.username ? 'eu' : message.username,
          style: TextStyle(color: userColor, fontWeight: FontWeight.bold),
        ),
        Text(
            " (${timeago.format(
              message.datetime.toDate(),
              locale: 'pt_br',
            )})",
            style: const TextStyle(fontSize: 12))
      ]),
      subtitle: Text(message.message),
    );
  }

  void _addMessage(BuildContext context) {
    var message = _textController.text;
    if (message.isNotEmpty) {
      // Send the message to Firebase.
      _db
          .collection('messages')
          .doc()
          .set(
              Message(widget._username, message, Timestamp.now()).toFirestore())
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _username,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
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
                          'Copyright ${DateTime.now().year} - Mister Mxyzptlk SA.',
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 24.0),
                          child: Text('Converse com amigos (y)'),
                        ),
                      ],
                    )),
          )
        ],
      ),
    );
  }
}
