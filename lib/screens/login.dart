import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/composition/oauth_logos.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _key = GlobalKey<FormState>();
  final analytics = FirebaseAnalytics();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: validateEmailAddress,
                    onSaved: (_) => email = _.trim(),
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      border: border,
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    validator: validatePassword,
                    onSaved: (_) => password = _.trim(),
                    autocorrect: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.vpn_key),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                        onPressed: signIn,
                        color: Colors.yellow,
                        child: Text('Sign In'),
                      ),
                      RaisedButton(
                        onPressed: register,
                        color: Colors.grey,
                        child: Text('Register'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'or',
                    style: Theme.of(context).textTheme.overline,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: const Divider(
                      thickness: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RaisedButton(
                    onPressed: signIn,
                    color: Colors.blue,
                    child: Text('Sign In Anonymously'),
                  ),
                  if (Platform.isAndroid)
                    RaisedButton(
                      onPressed: signInWithGoogle,
                      color: Colors.white,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OAuthIcon.google(),
                          SizedBox(width: 8),
                          Text('Sign In with Google'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signInAnon() async {
    Navigator.pushNamed(context, '/loading');
    await auth.signInAnonymously();
    analytics.logLogin(loginMethod: "anonymous");
    await setUser(auth.currentUser);
  }

  signIn() async {
    FormState state = _key.currentState;
    if (!state.validate()) return;
    state.save();

    Navigator.pushNamed(context, '/loading');
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      analytics.logLogin(loginMethod: 'email');
      setUser(auth.currentUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        showFailureDialog(
            'Benutzer deaktiviert', 'Der Benutzer wurde aus Sicherheitsgründen deaktiviert. Bitte wende dich an info@naegele.dev');
      } else if (e.code == 'invalid-email') {
        showFailureDialog(
            'Ungültige E-Mail', 'Die angegebene E-Mail ist ungültig.');
      } else if (e.code == 'user-not-found') {
        showFailureDialog('Ungültiger Benutzer',
            'Es konnte kein Benutzer mit dieser E-Mail gefunden werden.');
      }else if (e.code == 'wrong-password') {
        showFailureDialog('Ungültiges Passwort',
            'Das angegebene Passwort ist falsch.');
      }
    }
  }

  register() async {
    FormState state = _key.currentState;
    if (!state.validate()) return;
    state.save();

    Navigator.pushNamed(context, '/loading');
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      analytics.logSignUp(signUpMethod: 'email');
      setUser(auth.currentUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showFailureDialog(
            'Ungültige E-Mail', 'Diese E-Mail wird bereits benutzt.');
      } else if (e.code == 'invalid-email') {
        showFailureDialog(
            'Ungültige E-Mail', 'Die angegebene E-Mail ist ungültig.');
      } else if (e.code == 'weak-password') {
        showFailureDialog('Ungültiges Passwort',
            'Das angegeben Passwort ist zu schwach und leicht knackbar.');
      }
    }
  }

  signInWithGoogle() {}

  popUntilRoot() =>
      Navigator.popUntil(context, (route) => route.settings.name == '/');

  setUser(User user) async {
    final box = Hive.box('snack_box');
    await box.put('uid', user.uid);

    bool hasPreference = true;
    if (!box.containsKey('preference')) {
      DocumentSnapshot docSnapshot =
          await firestore.collection('users').doc(user.uid).get();
      Map data = docSnapshot.data();
      hasPreference = data != null;
      await box.put('preference',
          data != null ? data['preference'] : 'no_valid_preference');
      box.put('blocked', data != null ? data['blocked'] : []);
    }

    analytics.setUserId(user.uid);

    // Refetch chat partners
    CollectionReference collection = firestore.collection('chats');
    List chatPartners = box.get('chat_partners', defaultValue: []);
    QuerySnapshot snapshot =
        await collection.where('members', arrayContains: user.uid).get();
    List docs = snapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      List members = doc.data()['members'];
      members.removeWhere((element) => element == user.uid);
      String id = members[0];
      if (!chatPartners.contains(id)) chatPartners.add(id);
    }
    box.put('chat_partners', chatPartners);

    Navigator.pop(context);
    if (!hasPreference)
      Navigator.pushReplacementNamed(context, '/user/preferences');
    else
      popUntilRoot();
  }

  showFailureDialog(String title, String content) {
    Navigator.pop(context);
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
        ],
      ),
    );
  }
}

final border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(7),
);

String validateEmailAddress(String input) {
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input.trim())) {
    return "Bitte gebe eine gültige E-Mail an.";
  } else {
    return null;
  }
}

String validatePassword(String input) {
  if (input.trim().length >= 6) {
    return "Bitte gebe ein längeres Passwort an";
  } else {
    return null;
  }
}
