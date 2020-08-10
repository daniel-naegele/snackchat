import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnackPreference extends StatefulWidget {
  @override
  _SnackPreferenceState createState() => _SnackPreferenceState();
}

// TODO intercept back button
class _SnackPreferenceState extends State<SnackPreference> {
  String preference;
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text('Was schmeckt dir?')),
          automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/snacks.jpg'),
                Container(height: 16),
                Text(
                  "Wähle deine Lieblingssnacks aus und gebe die Reihenfolge unten an",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => preference = val,
                  decoration: InputDecoration(hintText: 'Bsp.: "61453"'),
                  autovalidate: true,
                  validator: validator,
                ),
                Container(height: 16),
                RaisedButton(
                  color: Colors.amberAccent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    "Speichern",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    if(!_key.currentState.validate()) return;

                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();
                    if (user == null) return;
                    CollectionReference collection =
                        Firestore.instance.collection('preferences');
                    DocumentReference docRef = collection.document(user.uid);
                    await docRef.setData({"preference": preference});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String validator(String input) {
    RegExp regExp = RegExp('([1-6]{6})');
    if (!regExp.hasMatch(input)) return "Bitte gebe eine gültige Preferenz an";
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (char.allMatches(input).length > 1)
        return "Bitte gebe eine gültige Preferenz an";
    }
    return null;
  }
}
