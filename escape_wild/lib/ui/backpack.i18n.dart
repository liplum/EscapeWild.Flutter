part of 'backpack.dart';

const _n = "ui.backpack";

class _I {
  _I._();

  static String massLoad(int cur, int max) => "$_n.mass-load".tr(namedArgs: {
        "cur": cur.toString(),
        "max": max.toString(),
      });

  static String get discard => "$_n.discard".tr();
}
