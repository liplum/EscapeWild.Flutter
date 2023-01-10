import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

extension ThemeBuildContextX on BuildContext {
  BorderRadius? get cardBorderRadius =>
      (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius?;

  BorderRadius? get cardBorderRadiusTop =>
      ((theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius?)
          ?.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero);

  BorderRadius? get cardBorderRadiusBottom =>
      ((theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius as BorderRadius?)
          ?.copyWith(topLeft: Radius.zero, topRight: Radius.zero);
}
