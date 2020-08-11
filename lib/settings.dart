import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        RaisedButton(
          color: Colors.red,
          child: Text(
            'Ausloggen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
        RaisedButton(
          color: Colors.red,
          child: Text(
            'Alle Nutzerdaten löschen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          onPressed: () {},
        ),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('FAQ', style: TextStyle(fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.contact_mail),
          title: Text('Impressum', style: TextStyle(fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Datenschutz', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}
