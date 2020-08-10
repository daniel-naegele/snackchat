import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

class UserAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, '/user/login'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Log In", style: TextStyle(fontSize: 32)),
                ),
                color: Colors.amberAccent,
              ),
            ],
          ),
          Container(height: 64),
        ],
      ),
    );
  }
}

class LogIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: LitAuth(
            config: AuthConfig(
              title: Text(
                'Willkommen bei Snack-Dating',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
              anonymousButton: ButtonConfig.raised(themedata: ButtonThemeData(), child: Text("Sign in anonymously", style: TextStyle(fontSize: 17))),
              googleButton: GoogleButtonConfig.light(),
              appleButton: AppleButtonConfig.dark(),

            ),
          ),
        ),
      ),
    );
  }
}
