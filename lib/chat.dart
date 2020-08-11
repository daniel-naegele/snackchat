import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

class Chat extends HookWidget {
  final String chatId;
  final Firestore firestore = Firestore.instance;
  final box = Hive.box('snack_box');
  final TextEditingController controller = TextEditingController();

  Chat(this.chatId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = box.get('uid');
    DocumentReference reference =
        firestore.collection('chats').document(chatId);
    AsyncSnapshot snapshot = useStream(reference.snapshots());
    if (!snapshot.hasData) return Scaffold();
    DocumentSnapshot doc = snapshot.data;
    List messages = doc.data['messages'] ?? [];
    List members = doc.data['members'];
    members.removeWhere((element) => element == uid);
    String id = members[0];
    return Scaffold(
      appBar: AppBar(title: Text(id)),
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (i > 0) return ChatMessage(messages.reversed.toList()[i - 1], uid);
          return Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: Color.fromRGBO(220, 220, 220, 1),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: TextField(
                        autocorrect: true,
                        controller: controller,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () => onSend(uid, messages)),
                )
              ],
            ),
          );
        },
        itemCount: messages.length + 1,
        reverse: true,
      ),
    );
  }

  onSend(String uid, List messages) async {
    String text = controller.text;
    DocumentReference reference =
        firestore.collection('chats').document(chatId);
    messages.add({
      'text': text,
      'timestamp': DateTime.now(),
      'author': uid,
    });
    await reference.updateData(<String, Object>{'messages': messages});
    controller.clear();
  }
}

class ChatMessage extends StatelessWidget {
  final Map message;
  final String uid; // own uid

  const ChatMessage(this.message, this.uid, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool foreign = uid != message['author'];
    return foreign
        ? ForeignChatMessage(message: message)
        : OwnChatMessage(message: message);
  }
}

class OwnChatMessage extends StatelessWidget {
  final Map message;

  const OwnChatMessage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromWidth(360)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                message['text'],
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForeignChatMessage extends StatelessWidget {
  final Map message;

  const ForeignChatMessage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: LimitedBox(
        maxWidth: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.loose(Size.fromWidth(360)),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      message['text'],
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
