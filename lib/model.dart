import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String username;
  final String message;
  final Timestamp datetime;

  Message(this.username, this.message, this.datetime);

  factory Message.fromFirestore(DocumentSnapshot document) {
    var data = document.data()! as Map<String, dynamic>;
    return Message(data['username'], data['message'], data['datetime']);
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'message': message,
        'datetime': datetime,
      };
}
