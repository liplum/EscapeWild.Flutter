import 'package:escape_wild/ui/main/settings.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                context.navigator.push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return const Placeholder();
  }
}
