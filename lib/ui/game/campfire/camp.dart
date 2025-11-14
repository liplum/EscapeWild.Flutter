import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';

import 'campfire.dart';
import '../shelter/shelter.dart';

part 'camp.i18n.dart';

class CampPage extends StatefulWidget {
  const CampPage({super.key});

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
    return LayoutBuilder(
      builder: (_, box) {
        final showTabLabel = box.maxHeight > 480.0;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: const Icon(TablerIcons.home), text: !showTabLabel ? null : _I.shelterTitle),
                Tab(icon: const Icon(TablerIcons.campfire), text: !showTabLabel ? null : _I.campfireTitle),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const RangeMaintainingScrollPhysics(),
            children: const [ShelterPage(), CampfirePage()],
          ),
        );
      },
    );
  }
}
