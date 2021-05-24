import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/db_schema/chat.dart';

class ChatTile extends StatelessWidget {

  final box = Hive.box('snack_box');
  final ChatMetadata chatMetadata;
  final String chatId;
  final String? lastChatMessage;

  ChatTile({Key? key, required this.chatMetadata, required this.chatId, this.lastChatMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chat_bubble),
      title: Text(_getOtherUser(chatMetadata.members)),
      subtitle: Text(lastChatMessage ?? ''),
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
