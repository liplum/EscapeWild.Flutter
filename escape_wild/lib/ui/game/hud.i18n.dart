part of 'hud.dart';

const _attr = "ui.hud";

class _I {
  _I._();

  static String get health => "$_attr.health".tr();

  static String get food => "$_attr.food".tr();

  static String get water => "$_attr.water".tr();

  static String get energy => "$_attr.energy".tr();

  static String attr(Attr a) => "$_attr.${a.name}".tr();
}
