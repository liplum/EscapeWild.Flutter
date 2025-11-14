import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/design/adaptive_navigation.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/game/serialization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:tabler_icons/tabler_icons.dart';

part 'index.i18n.dart';

class GameIndexPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const GameIndexPage({super.key, required this.navigationShell});

  @override
  State<GameIndexPage> createState() => _HomePageState();
}

class _HomePageState extends State<GameIndexPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final selection = await context.showDialogRequest(
          title: "Leave?",
          desc: "Your unsaved game will be lost",
          primary: "Save&Leave",
          secondary: "Leave",
        );
        if (!context.mounted) return;
        if (selection == true) {
          // save and leave
          final json = player.toJson(Cvt);
          DB.setGameSave(json);
          context.pop();
        } else if (selection == false) {
          // directly leave
          context.pop();
        }
      },
      child: player >> (_) => [buildMain(), buildEnvColorCover()].stack(),
    );
  }

  Widget buildMain() {
    return AdaptiveNavigationScaffold(
      navigationShell: widget.navigationShell,
      items: [
        AdaptiveNavigationItem(route: "/action", icon: TablerIcons.layout_2, label: _I.action),
        AdaptiveNavigationItem(route: "/backpack", icon: TablerIcons.backpack, label: _I.backpack),
        AdaptiveNavigationItem(route: "/craft", icon: TablerIcons.tool, label: _I.craft),
      ],
    );
  }

  Widget buildEnvColorCover() {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (ctx, box) => buildEnvColorBox().sized(w: box.maxWidth, h: box.maxHeight),
      ),
    );
  }

  Widget buildEnvColorBox() {
    return AnimatedContainer(color: player.envColor, duration: const Duration(milliseconds: 100));
  }
}
