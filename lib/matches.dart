import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

typedef void BoolCallback(bool value);

class Matches extends StatelessWidget {
  final bool complementary;

  const Matches(this.complementary, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('snack_box');
    final uid = box.get('uid');
    String preference = box.get('preference');
    if (complementary) {
      preference = preference.substring(3) + preference.substring(0, 3);
    }
    CollectionReference collection =
        Firestore.instance.collection('preferences');
    return StreamBuilder(
      stream: collection.where('preference', isEqualTo: preference).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: Text('Loading...'));
        QuerySnapshot querySnapshot = snapshot.data;
        List<DocumentSnapshot> documents = List()..addAll(querySnapshot.documents);
        documents.removeWhere((doc) => doc.documentID == uid);
        // TODO remove chat partners
        if (documents.length == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Kein Partner mit diesen Präferenzen wurden gefunden :c',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) =>
              _buildTile(context, index, documents),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, int i, List<DocumentSnapshot> documents) {
    DocumentSnapshot doc = documents[i];
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(doc.documentID),
      subtitle: Text(doc.data['preference']),
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
