import 'package:flutter/material.dart';

class PostTitleCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling = size.width / 308;
    final double yScaling = size.height / 99;
    path.lineTo(6 * xScaling,30.2222 * yScaling);
    path.cubicTo(5.999895301 * xScaling,-8.803 * yScaling,232.578 * xScaling,19.11537 * yScaling,297.064 * xScaling,27.8514 * yScaling,);
    path.cubicTo(306.891 * xScaling,29.1827 * yScaling,314 * xScaling,37.5679 * yScaling,314 * xScaling,47.4847 * yScaling,);
    path.cubicTo(314 * xScaling,47.4847 * yScaling,314 * xScaling,88.2222 * yScaling,314 * xScaling,88.2222 * yScaling,);
    path.cubicTo(314 * xScaling,99.2679 * yScaling,305.046 * xScaling,108.2222 * yScaling,294 * xScaling,108.2222 * yScaling,);
    path.cubicTo(294 * xScaling,108.2222 * yScaling,26.0001 * xScaling,108.2222 * yScaling,26.0001 * xScaling,108.2222 * yScaling,);
    path.cubicTo(14.95434 * xScaling,108.2222 * yScaling,6.0000296364 * xScaling,99.2799 * yScaling,6.0000434787 * xScaling,88.2342 * yScaling,);
    path.cubicTo(6.0000608946 * xScaling,74.3368 * yScaling,6.000063965 * xScaling,54.0643 * yScaling,6 * xScaling,30.2222 * yScaling,);
    path.cubicTo(6 * xScaling,30.2222 * yScaling,6 * xScaling,30.2222 * yScaling,6 * xScaling,30.2222 * yScaling,);
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
