import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';

extension StringX on String {
  AutoSizeText autoSizeText({
    Key? key,
    TextStyle? style,
    double minFontSize = 12,
    double maxFontSize = double.infinity,
    double stepGranularity = 1,
    List<double>? presetFontSizes,
    AutoSizeGroup? group,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    bool wrapWords = true,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
  }) => AutoSizeText(
    this,
    key: key,
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    minFontSize: minFontSize,
    maxFontSize: maxFontSize,
    stepGranularity: stepGranularity,
    presetFontSizes: presetFontSizes,
    group: group,
    wrapWords: wrapWords,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
  );
}
