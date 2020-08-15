import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

typedef void BoolCallback(bool value);

class Matches extends HookWidget {
  final bool complementary;
  final firestore = Firestore.instance;
  final box = Hive.box('snack_box');

  Matches(this.complementary, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = box.get('uid');
    List chatPartners = box.get('chat_partners', defaultValue: []);
    String preference = box.get('preference');
    if (complementary) {
      preference = preference.split('').reversed.join();
    }

    CollectionReference collection = firestore.collection('preferences');

    AsyncSnapshot snapshot = useStream(
        collection.where('preference', isEqualTo: preference).snapshots());

    if (!snapshot.hasData) return Center(child: Text('Loading...'));
    QuerySnapshot querySnapshot = snapshot.data;
    List<DocumentSnapshot> documents = List()..addAll(querySnapshot.documents);
    documents.removeWhere((doc) => doc.documentID == uid);
    documents.removeWhere((doc) => chatPartners.contains(doc.documentID));

    if (documents.length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Keine Partner mit diesen Präferenzen wurden gefunden :c',
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

  Widget _buildTile(BuildContext context, int i, List<DocumentSnapshot> documents) {
    final uid = box.get('uid');
    DocumentSnapshot doc = documents[i];
    String id = doc.documentID;
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(id),
      subtitle: Text(doc.data['preference']),
      onTap: () async {
        DocumentReference document = firestore.collection('chats').document(); // Autogenerate the id
        await document.setData({
          'members': [uid, id],
          'last_message': DateTime.now(),
        });
        List chatPartners = box.get('chat_partners', defaultValue: []);
        chatPartners.add(id);
        box.put('chat_partners', chatPartners);
        Navigator.pushNamed(context, '/chats/${document.documentID}');
      },
    );
  }
}

class FilterList extends StatelessWidget {
  final BoolCallback callback;
  final bool complementary;

  const FilterList(this.callback, this.complementary, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(child: Text('Nach Gleichem suchen'), value: false),
            PopupMenuItem(
                child: Text('Nach Komplementärem suchen'), value: true)
          ];
        },
        icon: Icon(Icons.filter_list),
        initialValue: complementary,
        onSelected: (val) => callback(val),
      ),
    );
  }
}
