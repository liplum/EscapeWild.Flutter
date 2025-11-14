import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:tabler_icons/tabler_icons.dart';

part 'settings.i18n.dart';

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
    return Scaffold(body: buildBody());
  }

  Widget buildBody() {
    final entries = buildVirtualEntries();
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          expandedHeight: 100.0,
          flexibleSpace: FlexibleSpaceBar(title: "Settings".text()),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(childCount: entries.length, (ctx, index) {
            return entries[index](ctx);
          }),
        ),
      ],
    );
  }

  List<WidgetBuilder> buildVirtualEntries() {
    final all = <WidgetBuilder>[];
    final curLocale = context.locale;
    void onPop() => setState(() {});
    all.add(
      (_) => NavigationListTile(
        onPop: onPop,
        leading: const Icon(TablerIcons.language, size: iconSize),
        title: _I.languageTitle.text(),
        subtitle: "language.$curLocale".tr().text(),
        to: (_) => LanguageSelectorPage(candidates: R.supportedLocales, selected: curLocale),
      ),
    );
    final q2cvt = Measurement.toMap();
    all.add(
      (_) => NavigationListTile(
        onPop: onPop,
        leading: const Icon(TablerIcons.ruler_measure, size: iconSize),
        title: _I.measurementTitle.text(),
        subtitle: q2cvt.values.map((cvt) => "(${cvt.l10nUnit()})").join(", ").text(),
        to: (_) => MeasurementSelectorPage(quality2Selected: q2cvt),
      ),
    );

    return all;
  }
}

class MeasurementSelectorPage extends StatefulWidget {
  final Map<PhysicalQuantity, UnitConverter> quality2Selected;

  const MeasurementSelectorPage({super.key, required this.quality2Selected});

  @override
  State<MeasurementSelectorPage> createState() => _MeasurementSelectorPageState();
}

class _MeasurementSelectorPageState extends State<MeasurementSelectorPage> {
  late final cur = Map.from(widget.quality2Selected);

  @override
  Widget build(BuildContext context) {
    final sections = buildSections();
    return WillPopScope(
      onWillPop: () async {
        for (final p in cur.entries) {
          Measurement.set(p.key, p.value);
        }
        Measurement.reload();
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
              flexibleSpace: FlexibleSpaceBar(title: "Measurement".tr().text()),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(childCount: sections.length, (ctx, index) => sections[index]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSections() {
    final all = <Widget>[];
    // mass
    all.add(
      MeasurementSelection(
        quantity: .mass,
        candidates: UnitConverter.name2Cvt$Mass.values.toList(),
        selected: Measurement.mass,
        example: 1000,
        onSelected: (cvt) {
          cur[PhysicalQuantity.mass] = cvt;
        },
      ),
    );
    return all;
  }
}

class MeasurementSelection extends StatefulWidget {
  final PhysicalQuantity quantity;
  final List<UnitConverter> candidates;
  final UnitConverter selected;
  final int? example;
  final ValueChanged<UnitConverter> onSelected;

  const MeasurementSelection({
    super.key,
    required this.quantity,
    required this.candidates,
    required this.selected,
    required this.onSelected,
    this.example,
  });

  @override
  State<MeasurementSelection> createState() => _MeasurementSelectionState();
}

class _MeasurementSelectionState extends State<MeasurementSelection> {
  late var curSelected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: widget.quantity.l10nName().text(),
      initiallyExpanded: true,
      children: widget.candidates.map((cvt) => buildOption(cvt)).toList(),
    );
  }

  Widget buildOption(UnitConverter cvt) {
    final example = widget.example;
    return ListTile(
      title: cvt.l10nName().text(),
      onTap: cvt == curSelected
          ? null
          : () {
              setState(() {
                curSelected = cvt;
              });
              widget.onSelected(cvt);
            },
      subtitle: example == null ? null : cvt.convertWithUnit(example).text(),
      trailing: cvt != curSelected ? null : const Icon(TablerIcons.check, color: Colors.green),
    );
  }
}

class LanguageSelectorPage extends StatefulWidget {
  final List<Locale> candidates;
  final Locale selected;

  const LanguageSelectorPage({super.key, required this.candidates, required this.selected});

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
              flexibleSpace: FlexibleSpaceBar(title: "language.$curSelected".tr().text()),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(childCount: widget.candidates.length, (ctx, index) {
                final locale = widget.candidates[index];
                return buildOption(locale);
              }),
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
      trailing: locale != curSelected ? null : const Icon(TablerIcons.check, color: Colors.green),
    );
  }
}
