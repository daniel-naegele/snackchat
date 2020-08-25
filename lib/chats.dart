import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

class Chats extends HookWidget {
  final box = Hive.box('snack_box');

  @override
  Widget build(BuildContext context) {
    final uid = box.get('uid');
    List blocked = box.get('blocked') ?? [];
    CollectionReference collection = Firestore.instance.collection('chats');
    AsyncSnapshot snapshot = useStream(collection
        .where('members', arrayContains: uid)
        .orderBy('last_message', descending: true)
        .snapshots());

    if (!snapshot.hasData) return Center(child: Text('Loading...'));
    QuerySnapshot querySnapshot = snapshot.data;
    List<DocumentSnapshot> documents = List()..addAll(querySnapshot.documents);

    documents.removeWhere((element) => blocked.contains(getOtherUser(element.data['members'])));

    if (documents.length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Du hast noch mit niemandem gechattet :c',
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
    DocumentSnapshot doc = documents[i];
    List messages = doc.data['messages'];
    return ListTile(
      leading: Icon(Icons.chat_bubble),
      title: Text(getOtherUser(doc['members'])),
      subtitle: Text(messages == null ? '' : messages.last['text']),
      onTap: () => Navigator.pushNamed(context, '/chats/${doc.documentID}'),
    );
  }

  String getOtherUser(List members) {
    final uid = box.get('uid');
    members.removeWhere((element) => element == uid);
    String id = members[0];
    return id;
  }
}
