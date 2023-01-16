part of 'console.dart';

const _n = "ui.debug.debug-console";

class _I {
  _I._();

  static final cat = _Cat();

  static String get title => "$_n.title".tr();
}

const _c = "$_n.cat";

class _Cat {
  String get item => "$_c.item".tr();
}
