import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class Chat extends HookWidget {
  final String chatId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final box = Hive.box('snack_box');
  final TextEditingController controller = TextEditingController();
  final analytics = FirebaseAnalytics();

  Chat(this.chatId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = box.get('uid');
    DocumentReference reference = firestore.collection('chats').doc(chatId);
    AsyncSnapshot snapshot = useStream(reference.snapshots(), initialData: null);
    if (!snapshot.hasData) return Scaffold();
    DocumentSnapshot doc = snapshot.data;
    List messages = doc.data()['messages'] ?? [];
    List members = doc.data()['members'];
    List preferences = doc.data()['preferences'];
    int foreignIndex = members.indexOf(uid) == 0 ? 1 : 0;
    String id = members[foreignIndex];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(id),
            if (preferences != null) Text(preferences[foreignIndex])
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.block), onPressed: () => blockUser(id, context)),
          IconButton(
              icon: Icon(Icons.flag), onPressed: () => reportUser(id, context))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                itemCount: messages.length + 1,
                reverse: true,
                itemBuilder: (context, i) {
                  if (i == messages.length)
                    return Disclaimer();
                  else
                    return ChatMessage(messages.reversed.toList()[i], uid);
                },
              ),
            ),
          ),
          Container(
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
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: TextField(
                        autocorrect: true,
                        controller: controller,
                        style: TextStyle(fontSize: 20),
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 4)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () => onSend(uid)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  onSend(String uid) async {
    String text = controller.text;
    if (text == null || text == "") return;
    DocumentReference reference = firestore.collection('chats').doc(chatId);
    List messages = [
      {
        'text': text,
        'timestamp': DateTime.now(),
        'author': uid,
      }
    ];
    await reference.update(<String, Object>{
      'messages': FieldValue.arrayUnion(messages),
      'last_message': DateTime.now(),
    });
    analytics.logEvent(name: "send_message", parameters: {"id": chatId});
    controller.clear();
  }

  blockUser(String user, BuildContext context) {
    showConfirmDialog(
      'Blockieren bestätigen',
      'Bist du dir sicher, dass du diesen Benutzer blockieren möchtest? Diese Aktion kann nicht rückgängig gemacht werden.',
      'Blockieren',
      context,
      () async {
        DocumentReference document =
            FirebaseFirestore.instance.collection('users').doc(box.get('uid'));
        List localBlocked = box.get('blocked', defaultValue: []);
        localBlocked.add(user);
        box.put('blocked', localBlocked);
        List blocks = [user];
        await document.update({'blocked': FieldValue.arrayUnion(blocks)});
        analytics.logEvent(name: "block_user", parameters: {"id": chatId});
        Navigator.pop(context);
        showSuccessDialog(context);
        await Future.delayed(Duration(seconds: 5));
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  reportUser(String user, BuildContext context) {
    showConfirmDialog(
      'Melden bestätigen',
      'Bist du dir sicher, dass du diesen Benutzer melden möchtest? Diese Aktion kann nicht rückgängig gemacht werden.',
      'Melden',
      context,
      () async {
        CollectionReference collection =
            FirebaseFirestore.instance.collection('reports');
        await collection.doc().set({
          'timestamp': DateTime.now(),
          'by': box.get('uid'),
          'reported': user,
        });
        analytics.logEvent(name: "report_user", parameters: {"id": chatId});
        Navigator.pop(context);
        showSuccessDialog(context);
        await Future.delayed(Duration(seconds: 5));
        Navigator.pop(context);
      },
    );
  }

  showConfirmDialog(String title, String body, String buttonText,
      BuildContext context, Function callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          RaisedButton(
            child: Text(buttonText),
            color: Colors.red,
            onPressed: callback,
          ),
          RaisedButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Container(width: 8)
        ],
      ),
    );
  }

  showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Aktion erfolgreich ausgeführt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
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
                      message['text'],
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 2),
                    Text(
                      toDateString(message['timestamp']),
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
                        message['text'],
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 2),
                      Text(
                        toDateString(message['timestamp']),
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
              'ACHTUNG: Dieser Chat ist nicht verschlüsselt. Obwohl nur Administratoren Zugriff auf die Daten haben, sollten Sie keine sensiblen Informationen auf dieser Plattform austauschen.',
              textAlign: TextAlign.center,
            ),
          ),
          color: Colors.yellow),
    );
  }
}

class Outline extends StatelessWidget {
  final Widget child;
  final Color color;

  Outline({this.child, this.color});

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

  Shadow({this.child});

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
  final format = DateFormat('dd.MM.yy hh:mm');
  return format.format(time.toDate());
}
