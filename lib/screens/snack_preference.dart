import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SnackPreference extends StatefulWidget {
  @override
  _SnackPreferenceState createState() => _SnackPreferenceState();
}

class _SnackPreferenceState extends State<SnackPreference> {
  String? preference;
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(AppLocalizations.of(context)!.yourSnackPreference)),
          automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 1024,
                    maxHeight: 460,
                  ),
                  child: Image.asset('assets/snacks.jpg'),
                ),
                Container(height: 16),
                Text(
                  AppLocalizations.of(context)!.selectFavoriteSnack,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => preference = val,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.snackHint),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (String? pref) => validator(pref!),
                ),
                Container(height: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    if (!_key.currentState!.validate()) return;

                    final box = Hive.box('snack_box');
                    box.put('preference', preference);
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    CollectionReference collection =
                        FirebaseFirestore.instance.collection('users');
                    DocumentReference docRef = collection.doc(user.uid);
                    await docRef.update({"preference": preference});
                    FirebaseAnalytics analytics = FirebaseAnalytics();
                    analytics.setUserProperty(
                        name: 'preference', value: preference);
                    analytics.logEvent(name: "set_preference");
                    Navigator.popUntil(
                        context, (route) => route.settings.name == '/');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validator(String input) {
    RegExp regExp = RegExp('([1-6]{6})');
    if (!regExp.hasMatch(input))
      return AppLocalizations.of(context)!.invalidPreference;
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (char.allMatches(input).length > 1)
        return AppLocalizations.of(context)!.invalidPreference;
    }
    return null;
  }
}
