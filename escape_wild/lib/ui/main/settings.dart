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
        to: (_) => const MeasurementSelectorPage(
          quality2Selected: Measurement.get,
        ),
      ),
    );

    return all;
  }
}

class MeasurementSelectorPage extends StatefulWidget {
  final UnitConverter? Function(PhysicalQuantity quantity) quality2Selected;

  const MeasurementSelectorPage({
    super.key,
    required this.quality2Selected,
  });

  @override
  State<MeasurementSelectorPage> createState() => _MeasurementSelectorPageState();
}

class _MeasurementSelectorPageState extends State<MeasurementSelectorPage> {
  final Map<PhysicalQuantity, UnitConverter> curQuality2Selected = {};

  @override
  void initState() {
    super.initState();
    updateSelected();
  }

  @override
  void didUpdateWidget(covariant MeasurementSelectorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateSelected();
  }

  void updateSelected() {
    curQuality2Selected.clear();
    for (final q in PhysicalQuantity.all) {
      final cvt = widget.quality2Selected(q);
      if (cvt != null) {
        curQuality2Selected[q] = cvt;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = buildSections();
    return WillPopScope(
      onWillPop: () async {
        for (final p in curQuality2Selected.entries) {
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
              flexibleSpace: FlexibleSpaceBar(
                title: "Measurement".tr().text(),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: sections.length,
                (ctx, index) => sections[index],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSections() {
    final all = <Widget>[];
    // mass
    all.add(MeasurementSelection(
      quantity: PhysicalQuantity.mass,
      candidates: UnitConverter.name2Cvt$Mass.values.toList(),
      selected: Measurement.mass,
      example: 1000,
      onSelected: (cvt) {
        curQuality2Selected[PhysicalQuantity.mass] = cvt;
      },
    ));
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
