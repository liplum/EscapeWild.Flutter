import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class Empty extends StatelessWidget {
  final Widget? icon;
  final String? title;
  final String? subtitle;
  final Widget? action;

  const Empty({super.key, this.icon, this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final subtitle = this.subtitle;
    final icon = this.icon;
    final action = this.action;
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallerSide = min(constraints.maxHeight, constraints.maxWidth);
        final iconSize = (smallerSide * 0.48).clamp(1.0, 68.0);
        final spacing = (smallerSide * 0.03).clamp(8.0, 24.0);
        final shortestSide = min(constraints.maxHeight, constraints.maxWidth);
        final iconWidget = icon != null
            ? IconTheme.merge(
                data: IconThemeData(color: context.colorScheme.secondary, size: iconSize),
                child: icon,
              )
            : null;
        final titleStyle = switch (shortestSide) {
          > 360 => context.textTheme.titleLarge,
          > 200 => context.textTheme.titleMedium,
          _ => context.textTheme.bodyLarge,
        };
        final subtitleStyle = switch (shortestSide) {
          > 360 => context.textTheme.bodyMedium,
          > 200 => context.textTheme.bodySmall,
          _ => context.textTheme.labelSmall,
        };
        return [
          if (iconWidget != null) iconWidget,
          if (title != null && shortestSide > 120)
            Text(
              title,
              textAlign: .center,
              style: titleStyle?.copyWith(fontWeight: .w600),
              maxLines: 2,
            ).padH(16),
          if (subtitle != null && shortestSide > 160)
            Text(subtitle, textAlign: .center, style: subtitleStyle).padH(16),
          if (action != null && shortestSide > 80) action.padSymmetric(v: spacing / 2),
        ].column(maa: .center, mas: .min, spacing: spacing).center();
      },
    );
  }
}
