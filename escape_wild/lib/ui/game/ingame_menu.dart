import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:rettulf/build_context/show.dart';

import '../main/game.dart';

extension IngameMenuBuildContextX on BuildContext {
  Future<void> showIngameMenuDialog() async {
    await this.showDialog(
      builder: (ctx) => $Dialog(
        icon: const Icon(Icons.exit_to_app,size: 36,),
        make: (ctx) => const _IngameMenu(),
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
     // buildSaveGameAndExitBtn(),
    ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.stretch);
  }

  Widget buildSaveGameBtn() {
    return CupertinoButton(
      onPressed: onSaveGame,
      child: "Save".text(
        style: TextStyle(fontSize: 20),
      ),
    ).inCard();
  }

  Future<void> onSaveGame() async {
    final json = player.toJson();
    DB.setGameSave(json);
    await context.showTip(
      title: I.done,
      desc: "Your game is saved.",
      ok: I.ok,
    );
    context.navigator.pop();
  }

  Widget buildSaveGameAndExitBtn() {
    return CupertinoButton(
      onPressed: onSaveGameAndExit,
      child: "Save & Exit".text(
        style: TextStyle(fontSize: 20),
      ),
    ).inCard();
  }

  Future<void> onSaveGameAndExit() async {
    final confirm = await context.showTip(
      title: "Leave?",
      desc: "Confirm to save and leave?",
      ok: I.ok,
    );
    if (confirm == true) {
      final json = player.toJson();
      DB.setGameSave(json);
      while (context.navigator.canPop()) {
        context.navigator.pop();
      }
      context.navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => const GamePage(),
      ));
    }
  }
}
