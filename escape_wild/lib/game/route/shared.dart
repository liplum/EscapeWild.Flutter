import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/foundation.dart';

Future<void> showGain(ActionType action, List<ItemEntry> gain) async {
  if (gain.isEmpty) {
    await AppCtx.showTip(
      title: action.localizedName(),
      desc: "action.got-nothing".tr(),
      ok: "alright".tr(),
    );
  } else {
    final result = gain.map((e) => e.meta.localizedName()).join(", ");
    await AppCtx.showTip(
      title: action.localizedName(),
      desc: "action.got-items".tr(args: [result]),
      ok: "ok".tr(),
    );
  }
}

void randGain(double probability, List<ItemEntry> gain, ItemEntry Function() ctor, [int times = 1]) {
  for (var i = 0; i < times; i++) {
    if (Rand.one() < probability) {
      final addition = ctor();
      gain.addItemOrMerge(addition);
    } else {
      break;
    }
  }
}
