part of 'backpack.dart';

const _n = "ui.backpack";

class _I {
  _I._();

  static String massLoad(int cur, int max) => "$_n.mass-load".tr(namedArgs: {
        "cur": cur.toString(),
        "max": max.toString(),
      });

  static String get discardRequest => "$_n.discard-request".tr();
  static String get cannotUse => "$_n.cannot-use".tr();

  static String discardConfirm(String discarded) => "$_n.discard-confirm".tr(args: [discarded]);

  static String get emptyTip => "$_n.empty-tip".tr();
}
