import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snack_dating/lit_firebase_auth/presentation/widgets/oauth_logos.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _key = GlobalKey<FormState>();

  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
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
            RaisedButton(
              onPressed: signIn,
              color: Colors.blue,
              child: Text('Sign In Anonymously'),
            ),
            if (Platform.isAndroid)
              RaisedButton(
                onPressed: signIn,
                color: Colors.blue,
                child: Row(
                  children: [
                    OAuthIcon.google(),
                    Text('Sign In with Google'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  signInAnon() {}

  signIn() {}

  register() {}
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
