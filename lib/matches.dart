import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

typedef void BoolCallback(bool value);

class Matches extends HookWidget {
  final bool complementary;
  final firestore = FirebaseFirestore.instance;
  final box = Hive.box('snack_box');
  late final preference;
  late final uid;
  late final chatPartners;
  late final CollectionReference<Map<String, Object?>> collection;

  Matches(this.complementary) {
    uid = box.get('uid');
    chatPartners = box.get('chat_partners', defaultValue: []);

    String? pref = box.get('preference');

    if (pref == null || pref == '') {
      pref = "no_valid_preference";
    }

    if (complementary) {
      pref = pref.split('').reversed.join();
    }

    preference = pref;

    collection = firestore.collection('users');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: Text('Loading...'));
        QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
        List<QueryDocumentSnapshot> documents = []..addAll(querySnapshot.docs);
        documents.removeWhere((doc) => doc.id == uid);
        documents.removeWhere((doc) => chatPartners.contains(doc.id));

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
      },
      stream: collection.where('preference', isEqualTo: preference).snapshots(),
    );
  }

  Widget _buildTile(
      BuildContext context, int i, List<DocumentSnapshot> documents) {
    final uid = box.get('uid');
    DocumentSnapshot doc = documents[i];
    String id = doc.id;

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String preference = data['preference'];
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(id),
      subtitle: Text(preference),
      onTap: () async {
        DocumentReference document =
            firestore.collection('chats').doc(); // Autogenerate the id
        await document.set({
          'members': [uid, id],
          'preferences': [box.get('preference'), preference],
          'last_message': DateTime.now(),
        });
        FirebaseAnalytics()
            .logEvent(name: "create_chat", parameters: {"id": document.id});
        List chatPartners = box.get('chat_partners', defaultValue: []);
        chatPartners.add(id);
        box.put('chat_partners', chatPartners);
        Navigator.pushNamed(context, '/chats/${document.id}');
      },
    );
  }
}

class FilterList extends StatelessWidget {
  final BoolCallback callback;
  final bool complementary;

  const FilterList(this.callback, this.complementary, {Key? key})
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
        onSelected: (bool val) => callback(val),
      ),
    );
  }
}
