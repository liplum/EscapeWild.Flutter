import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/design/adaptive_navigation.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/game/serialization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';

part 'index.i18n.dart';

class GameIndexPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const GameIndexPage({
    super.key,
    required this.navigationShell,
  });

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
      child: player >>
              (_) => [
            buildMain(),
            buildEnvColorCover(),
          ].stack(),
    );
  }

  Widget buildMain() {
    return AdaptiveNavigationScaffold(
      navigationShell: widget.navigationShell,
      items: [
        (
          route: "/action",
          icon: Icons.grid_view_outlined,
          activeIcon: Icons.grid_view_sharp,
          label: _I.action,
        ),
        (
          route: "/backpack",
          icon: Icons.backpack_outlined,
          activeIcon: Icons.backpack,
          label: _I.backpack,
        ),
        (
          route: "/craft",
          icon: Icons.build_outlined,
          activeIcon: Icons.build,
          label: _I.craft,
        ),
      ],
    );
  }

  Widget buildEnvColorCover() {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (ctx, box) => buildEnvColorBox().sized(
          w: box.maxWidth,
          h: box.maxHeight,
        ),
      ),
    );
  }

  Widget buildEnvColorBox() {
    return AnimatedContainer(
      color: player.envColor,
      duration: const Duration(milliseconds: 100),
    );
  }
}
