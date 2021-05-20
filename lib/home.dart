import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/chats.dart';
import 'package:snack_dating/matches.dart';
import 'package:snack_dating/screens/settings.dart' as settings;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final box = Hive.box('snack_box'); // I like that name :D
  int _index = 0;
  bool _complementary = false;
  Widget _body = Matches(false);

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission();
    final exec = () async {
      User user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.reload();
      CollectionReference collection =
          FirebaseFirestore.instance.collection('users');
      DocumentReference docRef = collection.doc(user.uid);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.data() == null ||
          !snapshot.data().containsKey('preference')) {
        Future.delayed(Duration(milliseconds: 1000)).then((value) {
          if (!isCurrent('/user/preferences'))
            Navigator.pushNamed(context, '/user/preferences');
        });
      } else {
        box.put('preference', snapshot.data()['preference']);
      }

      String localToken = await messaging.getToken();
      if (snapshot.data() != null && snapshot.data()['fcm'] != localToken)
        docRef.update({'fcm': localToken});
      messaging.onTokenRefresh.listen((token) => docRef.update({'fcm': token}));
    };
    exec();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snack-Dating'),
        centerTitle: true,
        actions: [
          _index != 0
              ? Container()
              : FilterList(rebuildWithMatches, _complementary),
        ],
      ),
      body: _body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: changeIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("Matches"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chats"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Einstellungen"),
          ),
        ],
      ),
    );
  }

  changeIndex(int index) {
    setState(() {
      _index = index;
      if (_index == 0) {
        _body = Matches(_complementary);
      } else if (_index == 1) {
        _body = Chats();
      } else if (_index == 2) {
        _body = settings.Settings();
      }
    });
  }

  rebuildWithMatches(bool complementary) {
    setState(() {
      _complementary = complementary;
      _body = Matches(complementary);
    });
  }
}
