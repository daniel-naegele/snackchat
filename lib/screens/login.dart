import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/composition/components.dart';
import 'package:snack_dating/composition/oauth_logos.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _key = GlobalKey<FormState>();
  final analytics = FirebaseAnalytics();
  final auth = FirebaseAuth.instance;
  final messaging = FirebaseMessaging();
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
                    validator: (_) => validateEmailAddress(_),
                    onSaved: (_) => email = _.trim(),
                    autocorrect: false,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      border: border,
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    validator: (_) => validatePassword(_),
                    onSaved: (_) => password = _.trim(),
                    autocorrect: false,
                    obscureText: true,
                    autofillHints: [AutofillHints.password],
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
                      Outline(
                        color: Colors.yellow,
                        child: FlatButton(
                          onPressed: signIn,
                          child:
                              Text('Sign In', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      Outline(
                        color: Colors.grey,
                        child: FlatButton(
                          onPressed: register,
                          child: Text('Register',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
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
                  Outline(
                    color: Colors.blue,
                    child: FlatButton(
                      onPressed: signInAnon,
                      child: Text('Sign In Anonymously',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  Outline(
                    color: Colors.white,
                    child: FlatButton(
                      onPressed: signInWithGoogle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OAuthIcon.google(),
                          SizedBox(width: 8),
                          Text('Sign In with Google',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
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
    showLoading();
    await auth.signInAnonymously();
    analytics.logSignUp(signUpMethod: "anonymous");
    await setUser(auth.currentUser);
  }

  signIn() async {
    FormState state = _key.currentState;
    if (!state.validate()) return;
    state.save();

    showLoading();
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      analytics.logLogin(loginMethod: 'email');
      setUser(auth.currentUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        showFailureDialog('Benutzer deaktiviert',
            'Der Benutzer wurde aus Sicherheitsgründen deaktiviert. Bitte wende dich an info@naegele.dev');
      } else if (e.code == 'invalid-email') {
        showFailureDialog(
            'Ungültige E-Mail', 'Die angegebene E-Mail ist ungültig.');
      } else if (e.code == 'user-not-found') {
        showFailureDialog('Ungültiger Benutzer',
            'Es konnte kein Benutzer mit dieser E-Mail gefunden werden.');
      } else if (e.code == 'wrong-password') {
        showFailureDialog(
            'Ungültiges Passwort', 'Das angegebene Passwort ist falsch.');
      }
    }
  }

  register() async {
    FormState state = _key.currentState;
    if (!state.validate()) return;
    state.save();

    showLoading();
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

  signInWithGoogle() async {
    showLoading();
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await auth.signInWithCredential(credential);
    analytics.logSignUp(signUpMethod: 'google');
    setUser(auth.currentUser);
  }

  popUntilRoot() =>
      Navigator.popUntil(context, (route) => route.settings.name == '/');

  setUser(User user) async {
    final box = Hive.box('snack_box');
    await box.put('uid', user.uid);

    DocumentReference reference = firestore.collection('users').doc(user.uid);
    DocumentSnapshot docSnapshot = await reference.get();

    bool hasPreference = true;
    if (!box.containsKey('preference')) {
      Map data = docSnapshot.data();
      hasPreference = data != null;
      await box.put('preference',
          data != null ? data['preference'] : 'no_valid_preference');
      box.put('blocked', data != null ? data['blocked'] : []);
    }

    analytics.setUserId(user.uid);
    String token = await messaging.getToken();
    if (!docSnapshot.exists) {
      await reference.set({'fcm': token});
    } else {
      await reference.update({'fcm': token});
    }

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

  showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow),
          backgroundColor: Colors.transparent,
        ),
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
  if (!RegExp(emailRegex).hasMatch(input.trim()) || input.trim().isEmpty) {
    return "Bitte gebe eine gültige E-Mail an.";
  } else {
    return null;
  }
}

String validatePassword(String input) {
  if (input.trim().length <= 6) {
    return "Bitte gebe ein längeres Passwort an";
  } else {
    return null;
  }
}
