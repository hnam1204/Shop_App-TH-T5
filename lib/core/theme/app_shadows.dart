import 'package:flutter/material.dart';

abstract final class AppShadows {
  static List<BoxShadow> soft(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
