import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/algolia_application.dart';

typedef void BoolCallback(bool value);

class Matches extends StatefulWidget {
  final bool complementary;
  late final preference;
  late final uid;
  late final chatPartners;
  late final CollectionReference<Map<String, Object?>> collection;
  late Future<List<Match>> matches;

  Matches(this.complementary) {
    final box = Hive.box('snack_box');
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

    collection = FirebaseFirestore.instance.collection('users');
    matches = getMatches();
  }

  @override
  _MatchesState createState() => _MatchesState();

  List<Match> filter(List<Match> input) {
    List<Match> matches = input;
    matches.removeWhere((element) => element.uid == uid);
    matches.removeWhere((element) => chatPartners.contains(element.uid));
    return matches;
  }

  Future<List<Match>> getMatches() async {
    final snapshot =
        await collection.where('preference', isEqualTo: preference).get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;

    List<Match> matches = filter(
      documents.map((e) => Match(e.id, e.data()['preference'])).toList(),
    );
    if (matches.isNotEmpty) {
      return matches;
    }

    Algolia algolia = AlgoliaApplication.algolia;
    final query = algolia.instance
        .index('preference')
        .query(preference)
        .setAnalytics(enabled: true);

    final snap = await query.getObjects();
    return filter(
      snap.hits.map((e) => Match(e.objectID, e.data['preference'])).toList(),
    );
  }
}

class _MatchesState extends State<Matches> {
  final firestore = FirebaseFirestore.instance;

  final box = Hive.box('snack_box');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<List<Match>> snapshot) {
        if (!snapshot.hasData) return Center(child: Text('Loading...'));
        List<Match> matches = snapshot.data!;
        final uid = box.get('uid');
        matches.removeWhere((element) => element.uid == uid);
        matches.removeWhere(
            (element) => widget.chatPartners.contains(element.uid));

        if (matches.length == 0) {
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
          itemCount: matches.length,
          itemBuilder: (context, index) => _buildTile(context, index, matches),
        );
      },
      future: widget.matches,
    );
  }

  Widget _buildTile(BuildContext context, int i, List<Match> matches) {
    final id = matches[i].uid;
    final preference = matches[i].preference;

    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(id),
      subtitle: Text(preference),
      onTap: () async {
        DocumentReference document =
            firestore.collection('chats').doc(); // Autogenerate the id
        await document.set({
          'members': [widget.uid, id],
          'preferences': [box.get('preference'), preference],
          'last_message': DateTime.now(),
        });
        FirebaseAnalytics()
            .logEvent(name: "create_chat", parameters: {"id": document.id});
        List chatPartners = box.get('chat_partners', defaultValue: []);
        chatPartners.add(id);
        box.put('chat_partners', chatPartners);
        Navigator.pushNamed(context, '/chats/${document.id}');
        setState(() {
          if (matches.length == 1) {
            widget.matches = widget.getMatches();
          }
        });
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

class Match {
  final String uid, preference;

  Match(this.uid, this.preference);
}
