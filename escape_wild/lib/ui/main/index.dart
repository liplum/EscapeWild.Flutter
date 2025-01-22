import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/design/adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'index.i18n.dart';

class MainIndexPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainIndexPage({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainIndexPage> createState() => _MainIndexPageState();
}

class _MainIndexPageState extends State<MainIndexPage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      navigationShell: widget.navigationShell,
      items: [
        (
          route: "/game",
          icon: Icons.sports_esports_outlined,
          activeIcon: Icons.sports_esports_rounded,
          label: _I.game,
        ),
        (
          route: "/mine",
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: _I.mine,
        ),
      ],
    );
  }
}
