import 'package:escape_wild/core/typing.dart';
import 'package:flutter/material.dart';

extension ColorX on Color {
  Color darken(double d) {
    return Color.from(alpha: a, red: r * (1 - d), green: g * (1 - d), blue: b * (1 - d));
    }

  Color lighten(Ratio ratio) {
    return mergeColors(Colors.white, ratio, this, 1 - ratio);
  }

  static Color mergeColors(Color a, double fa, Color b, double fb) {
    final $a = a.a * b.a;
    final $r = (fa * a.r + fb * b.r) / (fa + fb);
    final $g = (fa * a.g + fb * b.g) / (fa + fb);
    final $b = (fa * a.b + fb * b.b) / (fa + fb);
    return Color.from(alpha: $a, red: $r, green: $g, blue: $b);
  }
}
