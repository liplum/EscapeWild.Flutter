import 'package:escape_wild/generated/icons.dart';
import 'package:escape_wild/ui/game/campfire.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(onTabSwitch);
    _tabController.animateTo(lastIndex);
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(IconsX.camping_outlined),
              text: "Shelter",
            ),
            Tab(
              icon: Icon(Icons.local_fire_department_outlined),
              text: "Campfire",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Text("It's cloudy here"),
          ),
          const CampfirePage(),
        ],
      ),
    );
  }
}
