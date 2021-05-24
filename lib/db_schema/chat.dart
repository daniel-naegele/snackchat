import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMetadata {
  final Timestamp lastMessage;
  final List<String> members;
  final List<String> preferences;
  String? id;

  ChatMetadata({
    required this.lastMessage,
    required this.members,
    required this.preferences
  });

  ChatMetadata.fromJson(Map<String, Object?> json)
      : this(
    lastMessage: json['last_message']! as Timestamp,
    members: (json['members']! as List<dynamic>).cast<String>(),
    preferences: (json['preferences']! as List<dynamic>).cast<String>(),
  );

  Map<String, Object?> toJson() {
    return {
      'last_message': lastMessage,
      'members': members,
      'preferences': preferences

    };
  }
}


class ChatMessage {
  final Timestamp timestamp;
  final String author;
  final String text;

  ChatMessage({
    required this.timestamp,
    required this.author,
    required this.text
  });

  ChatMessage.fromJson(Map<String, Object?> json)
      : this(
    timestamp: json['timestamp']! as Timestamp,
    text: json['text']! as String,
    author: json['author']! as String
  );

  Map<String, Object?> toJson() {
    return {
      'text': text,
      'timestamp': timestamp,
      'author': author
    };
  }
}