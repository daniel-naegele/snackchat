import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final box = Hive.box('snack_box'); // I like that name :D


  int _index = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((value) async {
      if (value == null) return;
      CollectionReference collection =
          Firestore.instance.collection('preferences');
      DocumentReference docRef = collection.document(value.uid);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.data == null) {
        Future.delayed(Duration(milliseconds: 1550)).then(
            (value) => Navigator.pushNamed(context, '/user/preferences'));
      } else {
        box.put('preference', snapshot.data['preference']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Snack-Dating'))),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: changeIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: Text("Matches")),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text("Chats")),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Einstellungen")),
        ],
      ),
    );
  }

  changeIndex(int index) {
    setState(() {
      _index = index;
    });
  }
}
