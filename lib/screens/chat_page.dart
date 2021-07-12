import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:snack_dating/composition/chat_messages.dart';
import 'package:snack_dating/db_schema/chat.dart';

class ChatPage extends HookWidget {
  final String chatId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final box = Hive.box('snack_box');
  final analytics = FirebaseAnalytics();
  late final Future<DocumentSnapshot<ChatMetadata>> chatInfoFuture;

  ChatPage(this.chatId, {Key? key}) : super(key: key) {
    chatInfoFuture = firestore
        .collection('chats')
        .doc(chatId)
        .withConverter(
          fromFirestore: (snap, _) => ChatMetadata.fromJson(snap.data()!),
          toFirestore: (ChatMetadata data, _) => data.toJson(),
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final uid = box.get('uid');
    final snapshot = useFuture(chatInfoFuture, initialData: null);
    if (!snapshot.hasData) return Scaffold();

    ChatMetadata data = snapshot.data!.data()!;
    int foreignIndex = data.members.indexOf(uid) == 0 ? 1 : 0;
    String id = data.members[foreignIndex];
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Text(id),
              Text(data.preferences[foreignIndex]),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.block), onPressed: () => blockUser(id, context)),
          IconButton(
              icon: Icon(Icons.flag), onPressed: () => reportUser(id, context))
        ],
      ),
      body: ChatMessageList(chatId: chatId, uid: uid),
    );
  }

  blockUser(String user, BuildContext context) {
    showConfirmDialog(
      AppLocalizations.of(context)!.blockConfirmation,
      AppLocalizations.of(context)!.blockWarningMessage,
      AppLocalizations.of(context)!.block,
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
      AppLocalizations.of(context)!.reportConfirmation,
      AppLocalizations.of(context)!.reportWarningMessage,
      AppLocalizations.of(context)!.report,
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
          ElevatedButton(
            child: Text(buttonText),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
            onPressed: () => callback(),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.cancel),
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
            AppLocalizations.of(context)!.actionSuccessfullyExecuted,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}
