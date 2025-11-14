import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/foundation.dart';

Future<void> showToolBroken(UserAction action, ItemStack tool) async {
  await $context.showTip(
    title: action.l10nName(),
    desc: "action.tool-broken".tr(args: [tool.displayName()]),
    primary: "alright".tr(),
  );
}

Future<void> showGain(UserAction action, List<ItemStack> gain) async {
  if (gain.isEmpty) {
    await $context.showTip(title: action.l10nName(), desc: "action.got-nothing".tr(), primary: "alright".tr());
  } else {
    final result = gain.map((e) => e.meta.l10nName()).join(", ");
    await $context.showTip(
      title: action.l10nName(),
      desc: "action.got-items".tr(args: [result]),
      primary: "ok".tr(),
    );
  }
}

bool randGain(double probability, List<ItemStack> gain, ItemStack Function() ctor, [int times = 1]) {
  var any = false;
  for (var i = 0; i < times; i++) {
    if (Rand.one() < probability) {
      final addition = ctor();
      gain.addItemOrMerge(addition);
      any = true;
    } else {
      break;
    }
  }
  return any;
}
