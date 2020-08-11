import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:snack_dating/components.dart';

class UserAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: BgPhotos()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64, left: 32, right: 32),
              child: Outline(
                color: Colors.amberAccent,
                child: FlatButton(
                  onPressed: () => Navigator.pushNamed(context, '/user/login'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                    child: Text("Log In", style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BgPhotos extends StatefulWidget {
  @override
  _BgPhotosState createState() => _BgPhotosState();
}

class _BgPhotosState extends State<BgPhotos> {
  final PageController _controller = PageController();
  Timer _timer;

  List photos = [
    SnackPhoto('assets/snack0.jpg'),
    SnackPhoto('assets/snack1.jpg'),
    SnackPhoto('assets/snack2.jpg'),
    SnackPhoto('assets/snack3.jpg')
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _controller.nextPage(
        duration: Duration(seconds: 1),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemBuilder: (context, index) {
        int i = index % photos.length;
        return photos[i];
      },
      controller: _controller,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,

    );
  }
}

class SnackPhoto extends StatelessWidget {
  final String name;

  const SnackPhoto(this.name, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 0,
          sigmaY: 0,
        ),
        child: Image.asset(
          name,
          fit: BoxFit.cover,
        ),
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
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
              ),
              anonymousButton: ButtonConfig.raised(
                  themedata: ButtonThemeData(),
                  child: Text("Sign in anonymously",
                      style: TextStyle(fontSize: 17))),
              googleButton: GoogleButtonConfig.light(),
              appleButton: AppleButtonConfig.dark(),
            ),
          ),
        ),
      ),
    );
  }
}
