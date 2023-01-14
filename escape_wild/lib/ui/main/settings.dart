import 'package:easy_localization/easy_localization.dart';
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
          size: 28,
        ),
        title: "Language".text(),
        subtitle: "language.$curLocale".tr().text(),
        to: (_) => LanguageSelectorPage(
          candidates: R.supportedLocales,
          selected: curLocale,
        ),
      ),
    );
    return all;
  }
}

class NavigationListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final WidgetBuilder? to;

  const NavigationListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.to,
  });

  @override
  Widget build(BuildContext context) {
    final to = this.to;
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: to == null
          ? null
          : () {
              context.navigator.push(MaterialPageRoute(builder: to));
            },
      trailing: to == null
          ? null
          : const Icon(
              Icons.navigate_next_rounded,
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
      onWillPop: () async{
        await context.setLocale(curSelected);
        return true;
      },
      child: Scaffold(
        body: CustomScrollView(
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
