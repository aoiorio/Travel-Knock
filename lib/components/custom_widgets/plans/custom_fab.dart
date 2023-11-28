import 'package:flutter/material.dart';

// FABのLocationを自分で設定する
class CustomizeFloatingLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX;
  double offsetY;
  CustomizeFloatingLocation(this.location, this.offsetX, this.offsetY);
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}

// FABのアニメーションを無に帰す
class AnimationNoScaling extends FloatingActionButtonAnimator {
  double? _x;
  double? _y;
  @override
  Offset getOffset({Offset? begin, Offset? end, double? progress}) {
    _x = begin!.dx + (end!.dx - begin.dx) * progress!;
    _y = begin.dy + (end.dy - begin.dy) * progress;
    return Offset(_x!, _y!);
  }

  @override
  Animation<double> getRotationAnimation({Animation<double>? parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent!);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double>? parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent!);
  }
}