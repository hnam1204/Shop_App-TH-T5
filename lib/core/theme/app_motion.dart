import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;
}
