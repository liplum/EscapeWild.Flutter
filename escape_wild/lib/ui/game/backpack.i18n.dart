part of 'backpack.dart';

const _n = "ui.backpack";

class _I {
  _I._();

  static String get title => "$_n.title".tr();

  static String massLoad(int cur, int max) => "$_n.mass-load".tr(namedArgs: {
        "cur": I.massOf(cur),
        "max": I.massOf(max),
      });

  static String get discardRequest => "$_n.discard-request".tr();

  static String discardConfirm(String discarded) => "$_n.discard-confirm".tr(args: [discarded]);

  static String get emptyTip => "$_n.empty-tip".tr();
}
