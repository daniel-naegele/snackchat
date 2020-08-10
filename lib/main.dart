import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snack_dating/home.dart';
import 'package:snack_dating/login.dart';

void main() {
  runApp(SnackDatingApp());
}

class SnackDatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logAppOpen();

    return MaterialApp(
      title: 'Snack Dating',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => SnackDatingMain(),

      },
    );
  }
}

class SnackDatingMain extends HookWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    AsyncSnapshot<FirebaseUser> snapshot = useStream(auth.onAuthStateChanged);
    return snapshot.hasData ? Home() : Login();
  }
}
