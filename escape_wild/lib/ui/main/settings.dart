import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return buildEntries();
  }

  Widget buildEntries() {
    final all = <Widget>[];
    final curLocale = context.locale;
    all.add(ListTile(
      title: "Language".text(),
      subtitle: "language.$curLocale".tr().text(),
    ));
    return ListView(
      physics: const RangeMaintainingScrollPhysics(),
      children: all,
    );
  }
}

class LanguageSelectorPage extends StatefulWidget {
  final List<Locale> candidates;

  const LanguageSelectorPage({super.key, required this.candidates});

  @override
  State<LanguageSelectorPage> createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
