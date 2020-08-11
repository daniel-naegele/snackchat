import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:snack_dating/chat.dart';
import 'package:snack_dating/home.dart';
import 'package:snack_dating/login.dart';
import 'package:snack_dating/settings.dart';
import 'package:snack_dating/snack_preference.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('snack_box');
  runApp(SnackDatingApp());
}

class SnackDatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logAppOpen();

    return LitAuthInit(
      authProviders: AuthProviders(
        emailAndPassword: true,
        google: true,
        apple: true,
        anonymous: true,
        github: false,
        twitter: false,
      ),
      child: MaterialApp(
        title: 'Snack Dating',
        theme: ThemeData(
          primaryColor: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (context) => SnackDatingMain(),
          '/imprint': (context) => Imprint(),
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
      ),
    );
  }
}

class SnackDatingMain extends HookWidget {
  bool _wasLoggedIn;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    AsyncSnapshot<FirebaseUser> snapshot = useStream(auth.onAuthStateChanged);

    if (snapshot.hasData == true && _wasLoggedIn == false) {
      FirebaseUser user = snapshot.data;
      setUser(user);
      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    }

    _wasLoggedIn = snapshot.hasData;
    return _wasLoggedIn ? Home() : UserAuth();
  }

  setUser(FirebaseUser user) async {
    final box = Hive.box('snack_box');
    final firestore = Firestore.instance;
    await box.put('uid', user.uid);

    DocumentSnapshot docSnapshot = await firestore.collection('preferences')
        .document(user.uid).get();
    if(docSnapshot.exists) {
      await box.put('preference', docSnapshot.data['preference']);
    }
    
    final analytics = FirebaseAnalytics();
    analytics.setUserId(user.uid);
    analytics.setUserProperty(name: 'preference', value: box.get('preference'));
    if (user.email != '' && !user.isEmailVerified) user.sendEmailVerification();

    // Refetch chat partners
    CollectionReference collection = firestore.collection('chats');
    List chatPartners = box.get('chat_partners', defaultValue: []);
    if(chatPartners.length != 0) return; // not the best method to determine if a user has re logged in, but it will work
    QuerySnapshot snapshot = await collection
        .where('members', arrayContains: user.uid)
        .getDocuments();
    List docs = snapshot.documents;
    for (DocumentSnapshot doc in docs) {
      List members = doc.data['members'];
      members.removeWhere((element) => element == user.uid);
      String id = members[0];
      if(!chatPartners.contains(id)) chatPartners.add(id);
    }
    box.put('chat_partners', chatPartners);
  }
}
