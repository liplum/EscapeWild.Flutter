import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/game/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';

part 'game.i18n.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return [
      buildTitle(),
      [
        buildNewGameBtn(),
        buildContinueGameBtn(),
      ].column(maa: MainAxisAlignment.center, caa: CrossAxisAlignment.stretch).constrained(maxW: 220),
    ].column(maa: MainAxisAlignment.spaceEvenly, caa: CrossAxisAlignment.center).center();
  }

  Widget buildTitle() {
    return _I.title.text(
      style: context.textTheme.displayMedium,
    );
  }

  Widget buildNewGameBtn() {
    return ElevatedButton(
      onPressed: () async {
        DB.deleteGameSave();
        await onNewGame();
        while (context.navigator.canPop()) {
          context.navigator.pop();
        }
        context.navigator.push(MaterialPageRoute(
          builder: (_) => const Homepage(),
        ));
      },
      child: _I.newGame
          .text(
            style: TextStyle(fontSize: 28),
          )
          .padAll(5),
    ).padAll(5);
  }

  Future<void> onLoadGameSave(String gameSave) async {
    try {
      await loadGameSave(gameSave);
    } catch (e, _) {
      await context.showTip(
        title: "Corrupted",
        desc: "Sorry for that. This game save is corrupted or outdated.",
        ok: I.alright,
      );
      return;
    }
    while (context.navigator.canPop()) {
      context.navigator.pop();
    }
    context.navigator.push(MaterialPageRoute(
      builder: (_) => const Homepage(),
    ));
  }

  Widget buildContinueGameBtn() {
    return DB.$gameSave.listenable() <<
        (ctx, v, _) {
          final lastSave = DB.getGameSave();
          return ElevatedButton(
            onPressed: lastSave == null
                ? null
                : () async {
                    await onLoadGameSave(lastSave);
                  },
            child: _I.$continue
                .text(
                  style: TextStyle(fontSize: 28),
                )
                .padAll(5),
          ).padAll(5);
        };
  }
}
