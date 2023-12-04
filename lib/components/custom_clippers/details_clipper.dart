import 'package:flutter/material.dart';

class DetailsClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling = size.height / 366; // size.height / 366
    final double yScaling = size.height / 367;
    path.lineTo(4.82945 * xScaling, 39.0893 * yScaling);
    path.cubicTo(
      5.22504 * xScaling,
      12.8295 * yScaling,
      18.5207 * xScaling,
      0 * yScaling,
      34.7853 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      34.7853 * xScaling,
      0 * yScaling,
      368.556 * xScaling,
      0 * yScaling,
      368.556 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      385.124 * xScaling,
      0 * yScaling,
      398.556 * xScaling,
      13.4315 * yScaling,
      398.556 * xScaling,
      30 * yScaling,
    );
    path.cubicTo(
      398.556 * xScaling,
      30 * yScaling,
      398.556 * xScaling,
      354 * yScaling,
      398.556 * xScaling,
      354 * yScaling,
    );
    path.cubicTo(
      398.556 * xScaling,
      354 * yScaling,
      18.0556 * xScaling,
      201.5 * yScaling,
      5.55556 * xScaling,
      341 * yScaling,
    );
    path.cubicTo(
      -5.05657 * xScaling,
      459.431 * yScaling,
      2.35013 * xScaling,
      130.997 * yScaling,
      4.82945 * xScaling,
      29.0893 * yScaling,
    );
    path.cubicTo(
      4.82945 * xScaling,
      29.0893 * yScaling,
      4.82945 * xScaling,
      29.0893 * yScaling,
      4.82945 * xScaling,
      29.0893 * yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
