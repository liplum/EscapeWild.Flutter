import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:tabler_icons/tabler_icons.dart';

class NavigationListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final WidgetBuilder? to;
  final VoidCallback? onPop;

  const NavigationListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.to,
    this.onPop,
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
          : () async {
              await context.navigator.push(MaterialPageRoute(builder: to));
              onPop?.call();
            },
      trailing: to == null
          ? null
          : const Icon(
              TablerIcons.chevron_right,
            ),
    );
  }
}
