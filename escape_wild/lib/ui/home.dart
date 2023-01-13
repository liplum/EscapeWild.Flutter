import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/backpack.dart';
import 'package:escape_wild/ui/campfire.dart';
import 'package:flutter/material.dart';
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
}

class _HomePageState extends State<Homepage> {
  var curIndex = _P.action;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: buildBody(),
        bottomNavigationBar: buildBottom(),
      ),
      onWillPop: () async {
        final confirm = await context.showRequest(
          title: "Leave?",
          desc: "Your game state won't be saved",
          yes: I.ok,
          no: I.notNow,
          highlight: true,
          serious: true,
        );
        return confirm == true;
      },
    );
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
          activeIcon: const Icon(Icons.grid_view_rounded),
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
          activeIcon: const Icon(Icons.local_fire_department_rounded),
        ),
      ],
    );
  }

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
}
