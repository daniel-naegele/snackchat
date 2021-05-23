import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

import '../composition/components.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('snack_box');
    final uid = box.get('uid');
    final preference = box.get('preference');
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            child: Text(
              'Ausloggen',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onPressed: () => logOut(context),
          ),
        ),
        ListTile(
          title: Text('Nutzer ID: $uid', style: TextStyle(fontSize: 22)),
        ),
        ListTile(
          title: Text('Snack-Präferenz: $preference',
              style: TextStyle(fontSize: 22)),
        ),
//        RaisedButton(
//          color: Colors.red,
//          child: Text(
//            'Alle Nutzerdaten löschen',
//            style: TextStyle(color: Colors.white, fontSize: 24),
//          ),
//          onPressed: () {},
//        ),
        SizedBox(height: 32),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('FAQ', style: TextStyle(fontSize: 24)),
          onTap: () {
            FirebaseAnalytics().logEvent(name: "open_faq");
            Navigator.pushNamed(context, '/faq');
          },
        ),
        ListTile(
          leading: Icon(Icons.contact_mail),
          title: Text('Impressum', style: TextStyle(fontSize: 24)),
          onTap: () {
            FirebaseAnalytics().logEvent(name: "open_imprint");
            Navigator.pushNamed(context, '/imprint');
          },
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Datenschutz', style: TextStyle(fontSize: 24)),
          onTap: () {
            FirebaseAnalytics().logEvent(name: "open_privacy");
            Navigator.pushNamed(context, '/privacy');
          },
        ),
      ],
    );
  }

  logOut(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String content = 'Willst du dich wirklich ausloggen?';
    if (user.isAnonymous) {
      content +=
          '\nACHTUNG: Du hast dich anonym eingeloggt, du wirst dich danach nie wieder einloggen können!';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Ausloggen bestätigen'),
        content: Text(content),
        actions: [
          ElevatedButton(
            child: Text('Ausloggen'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () async {
              final box = Hive.box('snack_box');
              FirebaseAnalytics().logEvent(name: "logout");
              DocumentReference reference =
                  FirebaseFirestore.instance.doc('/users/' + box.get('uid'));
              bool stillExists = (await reference.get()).exists;
              if (user.isAnonymous) {
                await reference.delete();
              } else {
                if (stillExists)
                  await reference.update({'fcm': FieldValue.delete()});
              }
              await box.clear();
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Container(width: 8)
        ],
      ),
    );
  }
}

class FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
        children: <Widget>[
          Heading(text: 'FAQ'),
          SubHeading(text: 'Warum ist die App so hässlich?'),
          Paragraph(
              text:
                  'Die App wurde in knapp 10 Stunden entwickelt, da bleibt leider wenig Zeit für sowas. Es wird wahrscheinlich ein Update deswegen noch erscheinen.'),
          SubHeading(text: 'Was ist das Ziel des Ganzen?'),
          Paragraph(
              text:
                  'Eigentlich eine Art Omegle oder ChatRoulette, aber basierend auf Snackspräferenzen. Das hier ist in erster Linie ein Spaßprojekt, aber weiß, was hier noch draus wird.'),
          SubHeading(text: 'Welche Daten werden gesammelt?'),
          Paragraph(
              text:
                  'Wir speichern nur die Snack-Präferenzen und die Informationen, die wir von den Authentifizierungsprovidern (z. B. Google oder Apple) bekommen. '
                  'Was sie dann in den Chats mit fremden Personen freigeben, ist dann noch mal eine andere Sache'),
          SubHeading(text: 'Wo ist der Source Code?'),
          Paragraph(text: 'https://github.com/Butzlabben/snack_dating'),
        ],
      ),
    );
  }
}

class Imprint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Impressum')),
      body: ListView(
        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
        children: <Widget>[
          Heading(text: 'Impressum'),
          SubHeading(text: 'Angaben gemäß §5 TMG'),
          Paragraph(
              text: 'Daniel Nägele\n'
                  'Diepoldweg 13\n'
                  '70329 Stuttgart'),
          SizedBox(height: 24),
          SubHeading(text: 'Kontakt'),
          Paragraph(
            text: 'Email: info@naegele.dev \nTelefon: +4915734299398',
          ),
        ],
      ),
    );
  }
}

class Privacy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datenschutz')),
      body: ListView(
        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
        children: <Widget>[
          Heading(text: 'Privacy Policy'),
          Paragraph(
            text:
                'Daniel Nägele built the SnackChat app as an Open Source app. This SERVICE is provided by at no cost and is intended for use as is.'
                'This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.'
                'If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing '
                'and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.'
                'The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at SnackChat unless otherwise defined in this Privacy Policy.',
          ),
          SubHeading(text: 'Information Collection and Use'),
          Paragraph(
            text:
                'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to E-Mail. '
                'The information that I request will be retained on your device and is not collected by me in any way.'
                'The app does use third party services that may collect information used to identify you.\n'
                'Link to privacy policy of third party service providers used by the app\n'
                '- Google Play Services\n'
                '- Google Analytics for Firebase',
          ),
          SubHeading(text: 'Log Data'),
          Paragraph(
            text:
                'I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) '
                'on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, '
                'the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics. ',
          ),
          SubHeading(
            text: 'Cookies',
          ),
          Paragraph(
            text:
                'Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. '
                'These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.\n'
                'This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect '
                'information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. '
                'If you choose to refuse our cookies, you may not be able to use some portions of this Service. ',
          ),
          SubHeading(text: 'Service Providers'),
          Paragraph(
            text:
                'I may employ third-party companies and individuals due to the following reasons:\n'
                '- To facilitate our Service;\n'
                '- To provide the Service on our behalf;\n'
                '- To perform Service-related services; or\n'
                '- To assist us in analyzing how our Service is used.\n\n'
                'I want to inform users of this Service that these third parties have access to your Personal Information. '
                'The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose. ',
          ),
          SubHeading(text: 'Security'),
          Paragraph(
            text:
                'I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. '
                'But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security. ',
          ),
          SubHeading(text: 'Links to Other Sites'),
          Paragraph(
            text:
                'This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. '
                'Therefore, I strongly advise you to review the Privacy Policy of these websites. '
                'I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services. ',
          ),
          SubHeading(text: 'Children’s Privacy'),
          Paragraph(
            text:
                'These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13. '
                'In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. '
                'If you are a parent or guardian and you are aware that your child has provided us with personal information, '
                'please contact me so that I will be able to do necessary actions. ',
          ),
          SubHeading(text: 'Changes to This Privacy Policy'),
          Paragraph(
            text:
                'I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. '
                'I will notify you of any changes by posting the new Privacy Policy on this page. \n'
                'This policy is effective as of 2020-08-11',
          ),
          SubHeading(text: 'Contact Us'),
          Paragraph(
              text:
                  'If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at info@naegele.dev. '),
        ],
      ),
    );
  }
}
