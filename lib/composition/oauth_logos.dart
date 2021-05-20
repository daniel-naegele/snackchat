import 'package:flutter/material.dart';

const iconSize = Size(24, 24);

class OAuthIcon extends StatelessWidget {
  const OAuthIcon._({
    Key? key,
    required this.assetPath,
    this.size = iconSize,
  }) : super(key: key);

  final String assetPath;
  final Size size;

  static const googleIconPath = 'assets/google_logo.png';

  // Google logo [Image]
  factory OAuthIcon.google({Size size = iconSize}) {
    return OAuthIcon._(
      assetPath: googleIconPath,
      size: size,
    );
  }

  // Apple black logo [Image]
  factory OAuthIcon.appleBlack({Size size = iconSize}) {
    return OAuthIcon._(
      assetPath: 'assets/apple_logo_black.png',
      size: size,
    );
  }

  // Apple white [Image]
  factory OAuthIcon.appleWhite({Size size = iconSize}) {
    return OAuthIcon._(
      assetPath: 'assets/apple_logo_white.png',
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage(
        assetPath,
      ),
      height: size.height,
      width: size.width,
    );
  }
}
