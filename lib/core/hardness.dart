import 'package:escape_wild_flutter/core.dart';
import 'package:escape_wild_flutter/i18n.dart';
import 'package:escape_wild_flutter/utils/random.dart';
import 'package:flutter/foundation.dart';

typedef ValueFixer = double Function(double raw);

class Hardness with TagsMixin {
  final String name;
  final ValueFixer attrCostFix;
  final ValueGetter<int> maxFireMakingPrompt;
  final ValueFixer attrBounceFix;
  final ValueGetter<double> journeyLength;

  Hardness({
    required this.name,
    required this.attrCostFix,
    required this.attrBounceFix,
    required this.maxFireMakingPrompt,
    required this.journeyLength,
  });

  String localizedName() => I18n["hardness.$name.name"];

  String localizedDesc() => I18n["hardness.$name.desc"];
  static final Hardness easy = Hardness(
    name: "easy",
    attrCostFix: (e) => e * Rand.float(0.5, 0.8),
    maxFireMakingPrompt: () => 2,
    attrBounceFix: (e) => e * Rand.float(1.2, 1.5),
    journeyLength: () => 40 * Rand.float(0.9, 1.1),
  );
  static final Hardness normal = Hardness(
    name: "normal",
    attrCostFix: (e) => e * Rand.float(0.8, 1.2),
    maxFireMakingPrompt: () => 4,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.2),
    journeyLength: () => 40 * Rand.float(0.8, 1.2),
  );
  static final Hardness hard = Hardness(
    name: "hard",
    attrCostFix: (e) => e * Rand.float(1.1, 1.5),
    maxFireMakingPrompt: () => 8,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.0),
    journeyLength: () => 40 * Rand.float(0.8, 1.2),
  );
}
