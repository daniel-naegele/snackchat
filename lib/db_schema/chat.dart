class ChatMetadata {
  final DateTime lastMessage;
  final List<String> members;

  ChatMetadata({
    required this.lastMessage,
    required this.members,
  });

  ChatMetadata.fromJson(Map<String, Object?> json)
      : this(
    lastMessage: json['fcm']! as DateTime,
    members: json['preference']! as List<String>,
  );

  Map<String, Object?> toJson() {
    return {
      'last_message': lastMessage,
      'members': members,
    };
  }
}


class ChatMessage {
  final DateTime timestamp;
  final String author;
  final String text;

  ChatMessage({
    required this.timestamp,
    required this.author,
    required this.text
  });

  ChatMessage.fromJson(Map<String, Object?> json)
      : this(
    timestamp: json['timestamp']! as DateTime,
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