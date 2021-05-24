import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:snack_dating/db_schema/chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatMessageList extends HookWidget {
  final String chatId;
  final String uid;
  late final Stream<QuerySnapshot<ChatMessage>> messageStream;

  ChatMessageList({Key? key, required this.chatId, required this.uid})
      : super(key: key) {
    messageStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .withConverter(
          fromFirestore: (snapshot, _) =>
              ChatMessage.fromJson(snapshot.data()!),
          toFirestore: (ChatMessage message, _) => message.toJson(),
        )
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSnapshot = useStream(messageStream);
    if (!asyncSnapshot.hasData) return Container();
    final snapshot = asyncSnapshot.data;
    final messages = snapshot!.docs.map((e) => e.data()).toList();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView.builder(
          itemCount: messages.length + 1,
          itemBuilder: (context, i) {
            if (i == 0)
              return Disclaimer();
            else
              return ChatMessageWidget(messages[i + 1], uid);
          },
        ),
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final String uid; // own uid

  const ChatMessageWidget(this.message, this.uid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool foreign = uid != message.author;
    return foreign
        ? ForeignChatMessage(message: message)
        : OwnChatMessage(message: message);
  }
}

class OwnChatMessage extends StatelessWidget {
  final ChatMessage message;

  const OwnChatMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Outline(
            color: Colors.blueAccent,
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size.fromWidth(360)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      message.text,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 2),
                    Text(
                      toDateString(message.timestamp),
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForeignChatMessage extends StatelessWidget {
  final ChatMessage message;

  const ForeignChatMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: LimitedBox(
        maxWidth: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Outline(
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(Size.fromWidth(360)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message.text,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 2),
                      Text(
                        toDateString(message.timestamp),
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Outline(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.chatEncryptionWarning,
              textAlign: TextAlign.center,
            ),
          ),
          color: Colors.yellow),
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
          color: Colors.black.withOpacity(0.14),
          blurRadius: 19,
          offset: Offset(0, 5),
        ),
      ]),
    );
  }
}

String toDateString(Timestamp time) {
  // TODO internationalize me
  final format = DateFormat('dd.MM.yy hh:mm');
  return format.format(time.toDate());
}
