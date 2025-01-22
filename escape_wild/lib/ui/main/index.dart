import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'mine.dart';

part 'index.i18n.dart';

class MainIndexPage extends StatefulWidget {
  const MainIndexPage({super.key});

  @override
  State<MainIndexPage> createState() => _MainIndexPageState();
}

class _P {
  _P._();

  static const game = 0;
  static const mine = 1;
  static const content = 1;
}

class _MainIndexPageState extends State<MainIndexPage> {
  var curIndex = _P.game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: buildBottom(),
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
          label: _I.game,
          icon: const Icon(Icons.sports_esports_outlined),
          activeIcon: const Icon(Icons.sports_esports_rounded),
        ),
        BottomNavigationBarItem(
          label: _I.mine,
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
        ),
      ],
    );
  }

  Widget buildBody() {
    if (curIndex == _P.game) {
      return const GamePage();
    } else /* if (curIndex == _P.mine) */ {
      return const MinePage();
    }
  }
}
