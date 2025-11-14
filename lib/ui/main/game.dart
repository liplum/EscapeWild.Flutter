import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tabler_icons/tabler_icons.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              context.push("/settings");
            },
            icon: const Icon(TablerIcons.settings),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return [
      buildTitle(),
      [buildNewGameBtn(), buildContinueGameBtn()].column(maa: .center, caa: .stretch).constrained(maxW: 220),
    ].column(maa: .spaceEvenly, caa: .center).center();
  }

  Widget buildTitle() {
    return _I.title.text(style: context.textTheme.displayMedium);
  }

  Widget buildNewGameBtn() {
    return buildBtn(_I.newGame, () async {
      DB.deleteGameSave();
      await onNewGame();
      if (!mounted) return;
      context.go("/game");
    });
  }

  Future<void> onLoadGameSave(String gameSave) async {
    try {
      await loadGameSave(gameSave);
    } catch (e, _) {
      if (!mounted) return;
      await context.showTip(
        title: "Corrupted",
        desc: "Sorry for that. This game save is corrupted or outdated.",
        primary: I.alright,
      );
      return;
    }
    if (!mounted) return;
    context.go("/game");
  }

  Widget buildContinueGameBtn() {
    return DB.$gameSave.listenable() >>
        (ctx, v) {
          final lastSave = DB.getGameSave();
          return buildBtn(
            _I.$continue,
            lastSave == null
                ? null
                : () async {
                    await onLoadGameSave(lastSave);
                  },
          );
        };
  }

  Widget buildBtn(String text, [VoidCallback? onTap]) {
    return FilledButton.tonal(
      onPressed: onTap,
      child: text
          .autoSizeText(maxLines: 1, style: TextStyle(fontSize: context.textTheme.titleLarge?.fontSize))
          .padAll(5),
    ).padAll(5).constrained(minH: 60);
  }
}
