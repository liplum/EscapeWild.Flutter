import 'package:escape_wild/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

extension ThemeBuildContextX on BuildContext {
  BorderRadius get cardBorderRadius => (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius;

  BorderRadius get cardBorderRadiusTop =>
      ((theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius)
          .copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero);

  BorderRadius get cardBorderRadiusBottom =>
      ((theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius)
          .copyWith(topLeft: Radius.zero, topRight: Radius.zero);

  Color get themeColor {
    final theme = this.theme;
    if (theme.brightness == Brightness.light) {
      return theme.primaryColor;
    } else {
      return Color.lerp(theme.colorScheme.onPrimary, Colors.white, 0.6)!;
    }
  }

  RoundedRectangleBorder outlinedCardBorder() => RoundedRectangleBorder(
        side: BorderSide(
          color: isDarkMode ? colorScheme.outline : colorScheme.secondary,
        ),
        borderRadius: cardBorderRadius,
      );

  Color fixColorBrightness(Color color) {
    if (isDarkMode) {
      return color.darken(0.1);
    } else {
      return color.lighten(0.2);
    }
  }
}
