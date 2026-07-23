import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const price = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
}
