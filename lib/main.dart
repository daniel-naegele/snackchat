import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snack_dating/home.dart';
import 'package:snack_dating/screens/chat_page.dart';
import 'package:snack_dating/screens/eula.dart';
import 'package:snack_dating/screens/login.dart';
import 'package:snack_dating/screens/settings.dart';
import 'package:snack_dating/screens/snack_preference.dart';
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
        const Locale('de', ''), // German, no country code
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF88D2D1),
        accentColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      routes: {
        '/': (context) => SnackDatingMain(),
        '/imprint': (context) => Imprint(),
        '/eula': (context) => EULA(),
        '/privacy': (context) => Privacy(),
        '/faq': (context) => FAQ(),
        '/user/login': (context) => LogIn(),
        '/user/preferences': (context) => SnackPreference(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return ChatPage(settings.name!.split('/')[2]);
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
