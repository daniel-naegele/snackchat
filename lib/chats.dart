import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Chats extends HookWidget {
  final box = Hive.box('snack_box');
  late Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  late final blocked;

  Chats() {
    stream = FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: box.get('uid'))
        .orderBy('last_message', descending: true)
        .snapshots();
    blocked = box.get('blocked') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot =
        useStream(stream);
    if (!snapshot.hasData) return Center(child: Text('Loading...'));
    QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot<Object?>;
    List<QueryDocumentSnapshot> documents = []..addAll(querySnapshot.docs);

    documents.removeWhere((element) {
      Map<String, dynamic> data = element.data() as Map<String, dynamic>;
      return blocked.contains(getOtherUser(data['members']));
    });

    if (documents.length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context)!.noChats,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) => _buildTile(context, index, documents),
    );
  }

  Widget _buildTile(
      BuildContext context, int i, List<DocumentSnapshot> documents) {
    Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
    List? messages = data['messages'];
    return ListTile(
      leading: Icon(Icons.chat_bubble),
      title: Text(getOtherUser(data['members'])),
      subtitle: Text(messages == null ? '' : messages.last['text']),
      onTap: () => Navigator.pushNamed(context, '/chats/${documents[i].id}'),
    );
  }

  String getOtherUser(List members) {
    final uid = box.get('uid');
    members.removeWhere((element) => element == uid);
    String id = members[0];
    return id;
  }
}
