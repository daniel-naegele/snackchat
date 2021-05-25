import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snack_dating/composition/components.dart';

class UserAuth extends StatelessWidget {

  UserAuth() {
    doShit();
  }

  doShit() async {
    final snapshot = await FirebaseFirestore.instance.collection("chats1").doc('Re6Q84PiB28Nr3t8VfKR').get();
    print(snapshot.data());
  }

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
                color: Theme.of(context).primaryColor,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/eula'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Text("Log In", style: TextStyle(fontSize: 32, color: Colors.black)),
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

class SnackPhoto extends StatelessWidget {
  final String name;

  const SnackPhoto(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        name,
        fit: BoxFit.cover,
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
  late Timer _timer;

  List<SnackPhoto> photos = [
    const SnackPhoto('assets/snack0.jpg'),
    const SnackPhoto('assets/snack1.jpg'),
    const SnackPhoto('assets/snack2.jpg'),
    const SnackPhoto('assets/snack3.jpg')
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
