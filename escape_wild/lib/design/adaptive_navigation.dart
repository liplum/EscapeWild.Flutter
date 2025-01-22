import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';

typedef AdaptiveNavigationItem = ({String route, IconData icon, IconData activeIcon, String label});

extension _AdaptiveNavigationItemEX on AdaptiveNavigationItem {
  NavigationDestination toBarItem() {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(activeIcon),
      label: label,
    );
  }

  NavigationRailDestination toRailDest() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(activeIcon),
      label: Text(label),
    );
  }
}

class AdaptiveNavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Color? navigationBarColor;
  final Color? scaffoldBackgroundColor;
  final List<AdaptiveNavigationItem> items;
  final Widget Function(BuildContext context, Widget child)? bottomBarBuilder;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.navigationShell,
    required this.items,
    this.scaffoldBackgroundColor,
    this.navigationBarColor,
    this.bottomBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      final bottomBarBuilder = this.bottomBarBuilder;
      final bottomBar = buildNavigationBar(context, items);
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: navigationShell,
        bottomNavigationBar: bottomBarBuilder != null ? bottomBarBuilder(context, bottomBar) : bottomBar,
      );
    } else {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: [
          buildNavigationRail(context, items),
          navigationShell.expanded(),
        ].row(),
      );
    }
  }

  Widget buildNavigationBar(BuildContext context, List<AdaptiveNavigationItem> items) {
    return NavigationBar(
      backgroundColor: navigationBarColor,
      selectedIndex: getSelectedIndex(context, items),
      onDestinationSelected: (index) => onItemTapped(index, items),
      destinations: items.map((e) => e.toBarItem()).toList(),
    );
  }

  Widget buildNavigationRail(BuildContext context, List<AdaptiveNavigationItem> items) {
    return NavigationRail(
      backgroundColor: navigationBarColor,
      groupAlignment: 0,
      labelType: NavigationRailLabelType.all,
      selectedIndex: getSelectedIndex(context, items),
      onDestinationSelected: (index) => onItemTapped(index, items),
      destinations: items.map((e) => e.toRailDest()).toList(),
    );
  }

  int getSelectedIndex(BuildContext context, List<AdaptiveNavigationItem> items) {
    final location = GoRouterState.of(context).uri.toString();
    return max(0, items.indexWhere((item) => location.endsWith(item.route)));
  }

  void onItemTapped(int index, List<AdaptiveNavigationItem> items) {
    final item = items[index];
    final branchIndex = navigationShell.route.routes.indexWhere((r) {
      if (r is GoRoute) {
        return r.path.endsWith(item.route);
      }
      return false;
    });
    navigationShell.goBranch(
      branchIndex >= 0 ? branchIndex : index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
