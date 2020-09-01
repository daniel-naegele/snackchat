import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'file:///C:/Users/Daniel/IdeaProjects/PersonalProjects/snack_dating/lib/screens/chat.dart';
import 'file:///C:/Users/Daniel/IdeaProjects/PersonalProjects/snack_dating/lib/screens/eula.dart';
import 'package:snack_dating/home.dart';
import 'file:///C:/Users/Daniel/IdeaProjects/PersonalProjects/snack_dating/lib/screens/login.dart';
import 'file:///C:/Users/Daniel/IdeaProjects/PersonalProjects/snack_dating/lib/screens/settings.dart';
import 'file:///C:/Users/Daniel/IdeaProjects/PersonalProjects/snack_dating/lib/screens/snack_preference.dart';
import 'package:snack_dating/screens/start_screen.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  await Hive.initFlutter();
  await Hive.openBox('snack_box');
  await Firebase.initializeApp();
  runApp(SnackDatingApp());
}

class SnackDatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logAppOpen();
    return MaterialApp(
      title: 'Snack Dating',
      theme: ThemeData(
        primaryColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => SnackDatingMain(),
        '/imprint': (context) => Imprint(),
        '/eula': (context) => EULA(),
        '/privacy': (context) => Privacy(),
        '/faq': (context) => FAQ(),
        '/user/login': (context) => LogIn(),
        '/user/preferences': (context) => SnackPreference(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
            builder: (context) {
              return Chat(settings.name.split('/')[2]);
            },
            settings: settings);
      },
    );
  }
}

class SnackDatingMain extends HookWidget {
  bool _wasLoggedIn;
  final analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    AsyncSnapshot<User> snapshot = useStream(auth.authStateChanges());

    if (snapshot.hasData != _wasLoggedIn) {
      User user = snapshot.data;
      if (user != null) {
        analytics.logEvent(name: "login");
        setUser(user);
      }

      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    }

    _wasLoggedIn = snapshot.hasData;
    return _wasLoggedIn ? Home() : UserAuth();
  }

  setUser(User user) async {
    final box = Hive.box('snack_box');
    final firestore = FirebaseFirestore.instance;
    await box.put('uid', user.uid);

    if (!box.containsKey('preference')) {
      DocumentSnapshot docSnapshot =
          await firestore.collection('users').doc(user.uid).get();
      Map data = docSnapshot.data();
      docSnapshot.metadata;
      await box.put('preference',
          data != null ? data['preference'] : 'no_valid_preference');
      box.put('blocked', data != null ? data['blocked'] : []);
    }

    analytics.setUserId(user.uid);

    // Refetch chat partners
    CollectionReference collection = firestore.collection('chats');
    List chatPartners = box.get('chat_partners', defaultValue: []);
    if (chatPartners.length != 0)
      return; // not the best method to determine if a user has re logged in, but it will work
    QuerySnapshot snapshot = await collection
        .where('members', arrayContains: user.uid)
        .get();
    List docs = snapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      List members = doc.data()['members'];
      members.removeWhere((element) => element == user.uid);
      String id = members[0];
      if (!chatPartners.contains(id)) chatPartners.add(id);
    }
    box.put('chat_partners', chatPartners);
  }
}
