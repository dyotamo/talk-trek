import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? id;
  final String username;
  final String message;
  final Timestamp datetime;

  Message(
      {this.id,
      required this.username,
      required this.message,
      required this.datetime});

  factory Message.fromFirestore(DocumentSnapshot document) {
    var data = document.data()! as Map<String, dynamic>;
    return Message(
        id: document.id,
        username: data['username'],
        message: data['message'],
        datetime: data['datetime']);
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'message': message,
        'datetime': datetime,
      };
}
