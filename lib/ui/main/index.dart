import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/design/adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons/tabler_icons.dart';

part 'index.i18n.dart';

class MainIndexPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainIndexPage({super.key, required this.navigationShell});

  @override
  State<MainIndexPage> createState() => _MainIndexPageState();
}

class _MainIndexPageState extends State<MainIndexPage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      navigationShell: widget.navigationShell,
      items: [
        AdaptiveNavigationItem(route: "/game", icon: TablerIcons.device_gamepad_2, label: _I.game),
        AdaptiveNavigationItem(route: "/mine", icon: TablerIcons.user, label: _I.mine),
      ],
    );
  }
}
