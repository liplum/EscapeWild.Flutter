import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/foundation.dart';

Future<void> showToolBroken(ActionType action, ItemEntry tool) async {
  await AppCtx.showTip(
    title: action.l10nName(),
    desc: "action.tool-broken".tr(args: [tool.displayName()]),
    ok: "alright".tr(),
  );
}

Future<void> showGain(ActionType action, List<ItemEntry> gain) async {
  if (gain.isEmpty) {
    await AppCtx.showTip(
      title: action.l10nName(),
      desc: "action.got-nothing".tr(),
      ok: "alright".tr(),
    );
  } else {
    final result = gain.map((e) => e.meta.localizedName()).join(", ");
    await AppCtx.showTip(
      title: action.l10nName(),
      desc: "action.got-items".tr(args: [result]),
      ok: "ok".tr(),
    );
  }
}

bool randGain(double probability, List<ItemEntry> gain, ItemEntry Function() ctor, [int times = 1]) {
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
