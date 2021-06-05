import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snack_dating/home.dart';
import 'package:snack_dating/screens/chat_page.dart' deferred as chat;
import 'package:snack_dating/screens/eula.dart' deferred as eula;
import 'package:snack_dating/screens/login.dart' deferred as login;
import 'package:snack_dating/screens/settings.dart' deferred as settings;
import 'package:snack_dating/screens/snack_preference.dart'
    deferred as snack_preference;
import 'package:snack_dating/screens/start_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Hive.initFlutter();
  await Hive.openBox('snack_box');
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setAutoInitEnabled(true);
  if (!kIsWeb) {
    await messaging.subscribeToTopic('all');
  }
  runApp(SnackDatingApp());
}

class SnackDatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logAppOpen();
    return MaterialApp(
      title: 'SnackChat',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('de', ''), // Spanish, no country code
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF88D2D1),
        accentColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => SnackDatingMain(),
        '/imprint': (context) => FutureBuilder(
              builder: (snap, con) => settings.Imprint(),
              future: settings.loadLibrary(),
            ),
        '/eula': (context) => FutureBuilder(
          builder: (snap, con) => eula.EULA(),
          future: eula.loadLibrary(),
        ),
        '/privacy': (context) => FutureBuilder(
          builder: (snap, con) => settings.Privacy(),
          future: settings.loadLibrary(),
        ),
        '/faq': (context) => FutureBuilder(
          builder: (snap, con) => settings.FAQ(),
          future: settings.loadLibrary(),
        ),
        '/user/login': (context) => FutureBuilder(
          builder: (snap, con) => login.LogIn(),
          future: login.loadLibrary(),
        ),
        '/user/preferences': (context) => FutureBuilder(
          builder: (snap, con) => snack_preference.SnackPreference(),
          future: snack_preference.loadLibrary(),
        ),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return FutureBuilder(
              future: chat.loadLibrary(),
              builder: (context, snapshot) {
                return chat.ChatPage(settings.name!.split('/')[2]);
              }
            );
          },
          settings: settings,
        );
      },
    );
  }
}

class SnackDatingMain extends StatelessWidget {
  final analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('snack_box');
    return StreamBuilder(
      builder: (context, AsyncSnapshot<BoxEvent> snapshot) {
        if (!snapshot.hasData) return UserAuth();
        if (snapshot.data!.deleted) return UserAuth();
        String? uid = snapshot.data!.value;
        if (uid == null || uid == '') return UserAuth();
        return Home();
      },
      stream: box.watch(key: 'uid'),
      initialData: BoxEvent('uid', box.get('uid'), false),
    );
  }
}
