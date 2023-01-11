import 'package:easy_localization/easy_localization.dart';

class I {
  I._();

  static final item = _Item();
  static final action = _Action();

  static String get ok => "ok".tr();

  static String get yes => "yes".tr();

  static String get no => "no".tr();

  static String get gotIt => "got-it".tr();

  static String get notNow => "not-now".tr();

  static String get cancel => "cancel".tr();

  static String get alright => "alright".tr();
}

class _Item {
  static const _n = "item";

  String massWithUnit(int mass) => "$_n.mass-with-unit".tr(args: [mass.toString()]);
}

class _Action {
  static const _n = "action";

  String gotItems(String items) => "$_n.got-items".tr(args: [items]);

  String get gotNothing => "$_n.got-nothing".tr();

  String toolBroken(String tool) => "$_n.tool-broken".tr(args: [tool]);
}
