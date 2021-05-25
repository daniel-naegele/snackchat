import 'package:flutter/material.dart';
import 'package:snack_dating/composition/components.dart';

class EULA extends StatefulWidget {
  @override
  _EULAState createState() => _EULAState();
}

class _EULAState extends State<EULA> {
  int _accepted = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EULA')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                children: <Widget>[
                  Heading(text: 'SnackChat App End User License Agreement'),
                  Paragraph(
                      text:
                      'This End User License Agreement (“Agreement”) is between you and SnackChat and governs use of this app made available through the Apple App Store and Google Play Store. '
                          'By installing the SnackChat App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with '
                          'the terms and conditions of this Agreement, you are not entitled to use the SnackChat App.\n'),
                  Paragraph(
                      text:
                      'In order to ensure SnackChat provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content. '
                          'If you see inappropriate content, please use the "Report" feature found under each post.\n'),
                  Paragraph(
                      text:
                      '1. Parties This Agreement is between you and SnackChat only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries '
                          'are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. SnackChat, not Apple, is solely responsible for the '
                          'SnackChat App and its content.\n'),
                  Paragraph(
                      text:
                      '2. Privacy SnackChat may collect and use information about your usage of the SnackChat App, including certain types of information from and about your device. '
                          'SnackChat may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the SnackChat App.\n'),
                  Paragraph(
                      text:
                      '3. Limited License SnackChat grants you a limited, non-exclusive, non-transferable, revocable license to use theSnackChat App for your personal, non-commercial purposes. '
                          'You may only use theSnackChat App on Apple devices that you own or control and as permitted by the App Store Terms of Service.\n'),
                  Paragraph(
                      text:
                      '4. Age Restrictions By using the SnackChat App, you represent and warrant that (a) you are 17 years of age or older and you agree to be bound by this Agreement; '
                          '(b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the SnackChat App does'
                          ' not violate any applicable law or regulation. Your access to the SnackChat App may be terminated without warning if SnackChat believes, in its sole discretion, '
                          'that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you '
                          'provide your consent to your child\'s use of the SnackChat App, you agree to be bound by this Agreement in respect to your child\'s use of the SnackChat App.\n'),
                  Paragraph(
                      text:
                      '5. Objectionable Content Policy Content may not be submitted to SnackChat, who will moderate all content and ultimately decide whether or not to post a submission to '
                          'the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: '
                          '(i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; '
                          '(iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, '
                          'or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; '
                          'and (v) gambling, including without limitation, any online casino, sports books, bingo or poker.\n'),
                  Paragraph(
                      text:
                      '6. Warranty SnackChat disclaims all warranties about the SnackChat App to the fullest extent permitted by law. '
                          'To the extent any warranty exists under law that cannot be disclaimed, SnackChat, not Apple, shall be solely responsible for such warranty.\n'),
                  Paragraph(
                      text:
                      '7. Maintenance and Support SnackChat does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required '
                          'by applicable law, SnackChat, not Apple, shall be obligated to furnish any such maintenance or support.\n'),
                  Paragraph(
                      text:
                      '8. Product Claims SnackChat, not Apple, is responsible for addressing any claims by you relating to the SnackChat App or use of it, including, but not limited to: '
                          '(i) any product liability claim; (ii) any claim that the SnackChat App fails to conform to any applicable legal or regulatory requirement; '
                          'and (iii) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims.\n'),
                  Paragraph(
                      text:
                      '9. Third Party Intellectual Property Claims SnackChat shall not be obligated to indemnify or defend you with respect to any third party claim arising out or '
                          'relating to the SnackChat App. To the extent SnackChat is required to provide indemnification by applicable law, SnackChat, not Apple, '
                          'shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the SnackChat App or your use of it infringes '
                          'any third party intellectual property right.\n'),
                ],
              ),
            ),
            RadioListTile(
              value: 0,
              groupValue: _accepted,
              onChanged: (int? i) => changeAccepted(i!),
              title: Text('Decline'),
            ),
            RadioListTile(
              value: 1,
              groupValue: _accepted,
              onChanged: (int? i) => changeAccepted(i!),
              title: Text('Accept'),
            ),
            Outline(
              color: _accepted == 0 ? Colors.grey : Theme.of(context).primaryColor,
              child: FlatButton(
                onPressed: () {
                  if (_accepted != 1) return;
                  Navigator.pushReplacementNamed(context, '/user/login');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16,
                  ),
                  child: Text("Next", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
            Container(height: 24)
          ],
        ),
      ),
    );
  }

  changeAccepted(int value) {
    setState(() {
      _accepted = value;
    });
  }
}
