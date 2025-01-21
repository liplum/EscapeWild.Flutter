import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/stage_manager.dart';
import 'package:escape_wild/ui/debug/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';

part 'ingame_menu.i18n.dart';

extension IngameMenuBuildContextX on BuildContext {
  Future<void> showIngameMenuDialog() async {
    await showDialog(
      context: this,
      builder: (ctx) => $Dialog$(
        builder: (ctx) => const _IngameMenu(),
        primary: $Action$(text:  "OK"),
      ),
    );
  }
}

class _IngameMenu extends StatefulWidget {
  const _IngameMenu({super.key});

  @override
  State<_IngameMenu> createState() => _IngameMenuState();
}

class _IngameMenuState extends State<_IngameMenu> {
  @override
  Widget build(BuildContext context) {
    return [
      buildSaveGameBtn(),
      // TODO: Unlock the debug mode for online demo.
      if (kDebugMode || true) buildShowDebugConsoleBtn(),
    ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.stretch);
  }

  Widget buildSaveGameBtn() {
    return btn(_I.save, () async {
      final json = player.toJson();
      DB.setGameSave(json);
      await context.showTip(
        title: I.done,
        desc: "Your game is saved.",
        primary: I.ok,
      );
      context.navigator.pop();
    });
  }

  Widget buildShowDebugConsoleBtn() {
    return btn(_I.debugConsole, () async {
      StageManager.showDebugConsole(context);
      await Future.delayed(const Duration(milliseconds: 300));
      context.navigator.pop();
    });
  }

  Widget btn(String text, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: text.text(
        style: TextStyle(fontSize: context.textTheme.titleLarge?.fontSize),
      ),
    );
  }
}
