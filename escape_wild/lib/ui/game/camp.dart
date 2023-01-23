import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/generated/icons.dart';
import 'package:escape_wild/ui/game/campfire.dart';
import 'package:flutter/material.dart';

import 'shelter.dart';

part 'camp.i18n.dart';

class CampPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CampPage({super.key});

  @override
  State<CampPage> createState() => _CampPageState();
}

class _CampPageState extends State<CampPage> with TickerProviderStateMixin {
  late TabController _tabController;
  static var lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: lastIndex, length: 2, vsync: this);
    _tabController.addListener(onTabSwitch);
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabSwitch);
    super.dispose();
  }

  void onTabSwitch() {
    lastIndex = _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      final showTabLabel = box.maxHeight > 480.0;
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(IconsX.camping_outlined),
                text: !showTabLabel ? null : _I.shelterTitle,
              ),
              Tab(
                icon: const Icon(Icons.local_fire_department_outlined),
                text: !showTabLabel ? null : _I.campfireTitle,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const RangeMaintainingScrollPhysics(),
          children: const [
            ShelterPage(),
            CampfirePage(),
          ],
        ),
      );
    });
  }
}
