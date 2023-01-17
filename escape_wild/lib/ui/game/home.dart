import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/game/backpack.dart';
import 'package:escape_wild/ui/game/campfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rettulf/rettulf.dart';
import 'action.dart';
import 'craft.dart';

part 'home.i18n.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _P {
  _P._();

  static const action = 0;
  static const backpack = 1;
  static const craft = 2;
  static const campfire = 3;
  static const pageCount = 4;
}

class _HomePageState extends State<Homepage> {
  var curIndex = _P.action;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: onKeyEvent,
        child: Scaffold(
          body: buildBody(),
          bottomNavigationBar: buildBottom(),
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    final selection = await context.show123(
      title: "Leave?",
      make: (_) => "Your unsaved game will be lost".text(),
      primary: "Save&Leave",
      secondary: "Leave",
      tertiary: "Cancel",
      highlight: 2,
      isDefault: 1,
    );
    if (selection == 1) {
      // save and leave
      final json = player.toJson();
      DB.setGameSave(json);
      return true;
    } else if (selection == 2) {
      // directly leave
      return true;
    } else {
      return false;
    }
  }

  Widget buildBottom() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      currentIndex: curIndex,
      onTap: (newIndex) {
        if (newIndex != curIndex) {
          setState(() {
            curIndex = newIndex;
          });
        }
      },
      items: [
        BottomNavigationBarItem(
          label: _I.action,
          icon: const Icon(Icons.grid_view_outlined),
          activeIcon: const Icon(Icons.grid_view_sharp),
        ),
        BottomNavigationBarItem(
          label: _I.backpack,
          icon: const Icon(Icons.backpack_outlined),
          activeIcon: const Icon(Icons.backpack),
        ),
        BottomNavigationBarItem(
          label: _I.craft,
          icon: const Icon(Icons.build_outlined),
          activeIcon: const Icon(Icons.build),
        ),
        BottomNavigationBarItem(
          label: _I.campfire,
          icon: const Icon(Icons.local_fire_department_outlined),
          activeIcon: const Icon(Icons.local_fire_department),
        ),
      ],
    );
  }

  final focusNode = FocusNode();

  Widget buildBody() {
    if (curIndex == _P.action) {
      return const ActionPage();
    } else if (curIndex == _P.backpack) {
      return const BackpackPage();
    } else if (curIndex == _P.craft) {
      return const CraftPage();
    } else {
      return const CampfirePage();
    }
  }

  void onKeyEvent(KeyEvent k) {
    if (k is KeyDownEvent) {
      if (k.character == "z") {
        setState(() {
          curIndex = (curIndex - 1) % _P.pageCount;
        });
      } else if (k.character == "x") {
        setState(() {
          curIndex = (curIndex + 1) % _P.pageCount;
        });
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
