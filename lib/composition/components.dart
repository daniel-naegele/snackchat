import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Heading(
      {Key? key,
      required this.text,
      this.style = const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class SubHeading extends StatelessWidget {
  final String text;
  final TextStyle style;

  const SubHeading(
      {Key? key,
      required this.text,
      this.style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Paragraph(
      {Key? key, required this.text, this.style = const TextStyle(fontSize: 16)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class Outline extends StatelessWidget {
  final Widget child;
  final Color color;

  Outline({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Shadow(
        child: Container(
          decoration: new BoxDecoration(
            color:
            color == null ? Theme.of(context).dialogBackgroundColor : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class Shadow extends StatelessWidget {
  final Widget child;

  Shadow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: new BoxDecoration(boxShadow: [
        new BoxShadow(
          color: Colors.black.withOpacity(0.16),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ]),
    );
  }
}