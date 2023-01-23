import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rettulf/rettulf.dart';

import 'game.dart';
import 'mine.dart';

part 'home.i18n.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _P {
  _P._();

  static const game = 0;
  static const mine = 1;
  static const content = 1;
}

class _HomepageState extends State<Homepage> {
  var curIndex = _P.game;

  @override
  void initState() {
    super.initState();
    // precache campfire
    precachePicture(ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, 'assets/img/campfire.svg'), null);
  }

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
