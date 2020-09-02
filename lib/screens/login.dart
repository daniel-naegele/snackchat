import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snack_dating/composition/oauth_logos.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _key = GlobalKey<FormState>();
  final analytics = FirebaseAnalytics();
  final auth = FirebaseAuth.instance;

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
                    onSaved: (_) => email = _,
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
                    onSaved: (_) => password = _,
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
                    style: Theme
                        .of(context)
                        .textTheme
                        .overline,
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
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/user/preferences');
  }

  signIn() {}

  register() {}

  signInWithGoogle() {
  }

  popUntilRoot() =>
      Navigator.popUntil(context, (route) => route.settings.name == '/');

}

final border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(7),
);

String validateEmailAddress(String input) {
  const emailRegex =
  r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    return "Bitte gebe eine gültige E-Mail an.";
  } else {
    return null;
  }
}

String validatePassword(String input) {
  if (input.length >= 8) {
    return "Bitte gebe ein längeres Passwort an";
  } else {
    return null;
  }
}
