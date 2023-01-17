import 'package:escape_wild/ambiguous.dart';
import 'package:flutter/material.dart';

extension ColorX on Color {
  Color darken(double d) {
    return Color.fromARGB(
      alpha,
      (red * (1 - d)).toInt(),
      (green * (1 - d)).toInt(),
      (blue * (1 - d)).toInt(),
    );
  }

  Color lighten(Ratio ratio) {
    return mergeColors(Colors.white, ratio, this, 1 - ratio);
  }

  static Color mergeColors(Color a, double fa, Color b, double fb) {
    final $a = a.opacity * b.opacity;
    final $r = (fa * a.red + fb * b.red) / (fa + fb);
    final $g = (fa * a.green + fb * b.green) / (fa + fb);
    final $b = (fa * a.blue + fb * b.blue) / (fa + fb);
    return Color.fromARGB(($a * 255).toInt(), $r.toInt(), $g.toInt(), $b.toInt());
  }
}
