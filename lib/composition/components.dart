import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/db_schema/chat.dart';

class ChatTile extends HookWidget {

  final box = Hive.box('snack_box');
  final ChatMetadata chatMetadata;
  final String chatId;
  late final Future<QuerySnapshot<Map<String, dynamic>>> lastMessageFuture;

  ChatTile({Key? key, required this.chatMetadata, required this.chatId}) : super(key: key) {
    lastMessageFuture = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final snap = useFuture(lastMessageFuture);
    String? lastMessage;
    if (snap.data != null && snap.data!.size > 0) {
      lastMessage = snap.data!.docs[0].data()['text'];
    }
    return ListTile(
      leading: Icon(Icons.chat_bubble),
      title: Text(_getOtherUser(chatMetadata.members)),
      subtitle: Text(lastMessage ?? ''),
      onTap: () => Navigator.pushNamed(context, '/chats/$chatId}'),
    );
  }

  String _getOtherUser(List members) {
    final uid = box.get('uid');
    members.removeWhere((element) => element == uid);
    String id = members[0];
    return id;
  }
}

class Heading extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Heading(
      {Key? key,
      required this.text,
      this.style = const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class SubHeading extends StatelessWidget {
  final String text;
  final TextStyle style;

  const SubHeading(
      {Key? key,
      required this.text,
      this.style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Paragraph(
      {Key? key,
      required this.text,
      this.style = const TextStyle(fontSize: 16)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class Outline extends StatelessWidget {
  final Widget child;
  final Color? color;

  Outline({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Shadow(
        child: Container(
          decoration: new BoxDecoration(
            color:
                color == null ? Theme.of(context).dialogBackgroundColor : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class Shadow extends StatelessWidget {
  final Widget child;

  Shadow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: new BoxDecoration(boxShadow: [
        new BoxShadow(
          color: Colors.black.withOpacity(0.16),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ]),
    );
  }
}
