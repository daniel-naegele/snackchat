import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/composition/components.dart';
import 'package:snack_dating/composition/oauth_logos.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _key = GlobalKey<FormState>();
  final analytics = FirebaseAnalytics();
  final auth = FirebaseAuth.instance;
  final messaging = FirebaseMessaging.instance;
  final firestore = FirebaseFirestore.instance;

  String? email, password;

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final width = data.size.width;
    bool shouldConstraint = width > 720;
    return Scaffold(
      body: Form(
        key: _key,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: shouldConstraint ? width / 2 : width,
              minWidth: 240,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      validator: (_) => validateEmailAddress(_!),
                      onSaved: (_) => email = _!.trim(),
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
                      validator: (_) => validatePassword(_!),
                      onSaved: (_) => password = _!.trim(),
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
                          color: Theme.of(context).primaryColor,
                          child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(16))),
                            onPressed: signIn,
                            child: Text(
                              'Sign In',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ),
                        Outline(
                          color: Colors.grey,
                          child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(16))),
                            onPressed: register,
                            child: Text(
                              'Register',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
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
                      child: TextButton(
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16))),
                        onPressed: signInAnon,
                        child: Text(
                          'Sign In Anonymously',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Outline(
                      color: Colors.white,
                      child: TextButton(
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16))),
                        onPressed: () =>
                            kIsWeb ? signInWithGoogleWeb() : signInWithGoogle(),
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
      ),
    );
  }

  signInAnon() async {
    showLoading();
    await auth.signInAnonymously();
    analytics.logSignUp(signUpMethod: "anonymous");
    await setUser(auth.currentUser!);
  }

  signIn() async {
    FormState? state = _key.currentState;
    if (state == null || !state.validate()) return;
    state.save();

    showLoading();
    try {
      await auth.signInWithEmailAndPassword(email: email!, password: password!);
      analytics.logLogin(loginMethod: 'email');
      setUser(auth.currentUser!);
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
    FormState? state = _key.currentState;
    if (state == null || !state.validate()) return;
    state.save();

    showLoading();
    try {
      await auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      analytics.logSignUp(signUpMethod: 'email');
      setUser(auth.currentUser!);
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

  signInWithGoogleWeb() async {
    showLoading();
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
    UserCredential credential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
    await auth.signInWithCredential(credential.credential!);
    analytics.logSignUp(signUpMethod: 'google');
    setUser(auth.currentUser!);
  }

  signInWithGoogle() async {
    showLoading();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await auth.signInWithCredential(credential);
    analytics.logSignUp(signUpMethod: 'google');
    setUser(auth.currentUser!);
  }

  popUntilRoot() =>
      Navigator.popUntil(context, (route) => route.settings.name == '/');

  setUser(User user) async {
    final box = Hive.box('snack_box');

    DocumentReference reference = firestore.collection('users').doc(user.uid);
    DocumentSnapshot docSnapshot = await reference.get();

    bool hasPreference = true;
    if (!box.containsKey('preference')) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

      hasPreference = data != null;
      await box.put('preference',
          data != null ? data['preference'] : 'no_valid_preference');
      box.put('blocked', data != null ? data['blocked'] : []);
    }

    if (!docSnapshot.exists) {
      await reference.set({'fcm': ''});
    }

    Navigator.pop(context);
    if (!hasPreference) {
      await Navigator.pushReplacementNamed(context, '/user/preferences');
      await box.put('uid', user.uid);
    } else {
      await box.put('uid', user.uid);
      popUntilRoot();
    }

    analytics.setUserId(user.uid);
    messaging
        .getToken(
            vapidKey:
                'BOpT7H4ZzDw9DAEP1iZMFg_Z1zVNW47Okvb3oPX-e0iAO5YdoQd1SjYoM2Tx-1fsaYbXkOLihvJdNIiRFaOjggA')
        .then((token) async {
      await reference.update({'fcm': token});
    }).onError((error, stackTrace) {});

    // Refetch chat partners
    CollectionReference collection = firestore.collection('chats');
    List chatPartners = box.get('chat_partners', defaultValue: []);
    QuerySnapshot snapshot =
        await collection.where('members', arrayContains: user.uid).get();
    List docs = snapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List members = data['members'];
      members.removeWhere((element) => element == user.uid);
      String id = members[0];
      if (!chatPartners.contains(id)) chatPartners.add(id);
    }
    box.put('chat_partners', chatPartners);
  }

  showFailureDialog(String title, String content) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
        ],
      ),
    );
  }

  showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
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

String? validateEmailAddress(String input) {
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (!RegExp(emailRegex).hasMatch(input.trim()) || input.trim().isEmpty) {
    return "Bitte gebe eine gültige E-Mail an.";
  } else {
    return null;
  }
}

String? validatePassword(String input) {
  if (input.trim().length <= 6) {
    return "Bitte gebe ein längeres Passwort an";
  } else {
    return null;
  }
}
