import 'package:flutter/material.dart';

class Login extends StatelessWidget {
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
                child: Text("Log In"),
                color: Colors.amberAccent,
              ),
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, '/user/signup'),
                child: Text("Sign Up"),
                color: Colors.amberAccent,
              )
            ],
          ),
          Container(height: 48),
        ],
      ),
    );
  }
}
