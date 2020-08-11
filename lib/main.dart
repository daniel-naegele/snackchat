import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:snack_dating/home.dart';
import 'package:snack_dating/login.dart';
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
          '/user/login': (context) => LogIn(),
          '/user/preferences': (context) => SnackPreference(),
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
      Hive.box('snack_box').put('uid', user.uid);
      if (user.email != '' && !user.isEmailVerified) user.sendEmailVerification();

      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    }
    _wasLoggedIn = snapshot.hasData;
    return _wasLoggedIn ? Home() : UserAuth();
  }
}
