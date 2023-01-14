import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final List<WidgetBuilder> entries = buildVirtualEntries();
  static const iconSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          expandedHeight: 100.0,
          flexibleSpace: FlexibleSpaceBar(
            title: "Settings".text(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: entries.length,
            (ctx, index) {
              return entries[index](ctx);
            },
          ),
        ),
      ],
    );
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

  List<WidgetBuilder> buildVirtualEntries() {
    final all = <WidgetBuilder>[];
    final curLocale = context.locale;
    all.add(
      (_) => NavigationListTile(
        leading: const Icon(
          Icons.public_rounded,
          size: iconSize,
        ),
        title: "Language".text(),
        subtitle: "language.$curLocale".tr().text(),
        to: (_) => LanguageSelectorPage(
          candidates: R.supportedLocales,
          selected: curLocale,
        ),
      ),
    );
    all.add(
      (_) => NavigationListTile(
        leading: const Icon(
          Icons.straighten_rounded,
          size: iconSize,
        ),
        title: "Measurement".text(),
        //subtitle: "language.$curLocale".tr().text(),
        to: (_) => MeasurementSelectorPage(
          quality2Candidates: UnitConverter.measurement2Converters,
          quality2Selected: {},
        ),
      ),
    );

    return all;
  }
}

class MeasurementSelectorPage extends StatefulWidget {
  final Map<String, List<UnitConverter>> quality2Candidates;
  final Map<String, UnitConverter> quality2Selected;

  const MeasurementSelectorPage({
    super.key,
    required this.quality2Candidates,
    required this.quality2Selected,
  });

  @override
  State<MeasurementSelectorPage> createState() => _MeasurementSelectorPageState();
}

class _MeasurementSelectorPageState extends State<MeasurementSelectorPage> {
  late var curQuality2Selected = widget.quality2Selected;

  @override
  Widget build(BuildContext context) {
    final quality2Candidates = widget.quality2Candidates.entries.toList();
    return WillPopScope(
      onWillPop: () async {
        //await context.setLocale(curSelected);
        return true;
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const RangeMaintainingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                title: "Measurement".tr().text(),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: quality2Candidates.length,
                (ctx, index) {
                  final p = quality2Candidates[index];
                  return MeasurementSelection(
                    candidates: p.value,
                    selected: Measurement.mass,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeasurementSelection extends StatefulWidget {
  final List<UnitConverter> candidates;
  final UnitConverter selected;

  const MeasurementSelection({
    super.key,
    required this.candidates,
    required this.selected,
  });

  @override
  State<MeasurementSelection> createState() => _MeasurementSelectionState();
}

class _MeasurementSelectionState extends State<MeasurementSelection> {
  late var curSelected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: "AAA".text(),
      initiallyExpanded: true,
      children: widget.candidates.map((cvt) => buildOption(cvt)).toList(),
    );
  }

  Widget buildOption(UnitConverter cvt) {
    return ListTile(
      title: cvt.l10nName().text(),
      onTap: cvt == curSelected
          ? null
          : () {
              setState(() {
                curSelected = cvt;
              });
            },
      subtitle: cvt.convertWithUnit(1000).text(),
      trailing: cvt != curSelected
          ? null
          : const Icon(
              Icons.check,
              color: Colors.green,
            ),
    );
  }
}

class LanguageSelectorPage extends StatefulWidget {
  final List<Locale> candidates;
  final Locale selected;

  const LanguageSelectorPage({
    super.key,
    required this.candidates,
    required this.selected,
  });

  @override
  State<LanguageSelectorPage> createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  late var curSelected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await context.setLocale(curSelected);
        return true;
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const RangeMaintainingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                title: "language.$curSelected".tr().text(),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: widget.candidates.length,
                (ctx, index) {
                  final locale = widget.candidates[index];
                  return buildOption(locale);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(Locale locale) {
    return ListTile(
      title: "language.$locale".tr().text(),
      onTap: locale == curSelected
          ? null
          : () {
              setState(() {
                curSelected = locale;
              });
            },
      trailing: locale != curSelected
          ? null
          : const Icon(
              Icons.check,
              color: Colors.green,
            ),
    );
  }
}
