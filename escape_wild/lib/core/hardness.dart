import 'package:escape_wild/core.dart';
import 'package:escape_wild/i18n.dart';
import 'package:escape_wild/utils/random.dart';
import 'package:flutter/foundation.dart';

typedef ValueFixer = double Function(double raw);

class Hardness with TagsMixin {
  final String name;
  final ValueFixer attrCostFix;
  final ValueGetter<Times> maxFireMakingPrompt;
  final ValueFixer attrBounceFix;
  final ValueGetter<Distance> journeyDistance;
  final ValueGetter<Ratio> resourceIntensity;

  Hardness({
    required this.name,
    required this.attrCostFix,
    required this.attrBounceFix,
    required this.maxFireMakingPrompt,
    required this.journeyDistance,
    required this.resourceIntensity,
  });

  String localizedName() => I18n["hardness.$name.name"];

  String localizedDesc() => I18n["hardness.$name.desc"];
  static final Hardness easy = Hardness(
    name: "easy",
    attrCostFix: (e) => e * Rand.float(0.5, 0.8),
    maxFireMakingPrompt: () => 2,
    attrBounceFix: (e) => e * Rand.float(1.2, 1.5),
    journeyDistance: () => 40 * Rand.float(0.9, 1.1),
    resourceIntensity: () => 10 * Rand.float(0.9, 1.1),
  );
  static final Hardness normal = Hardness(
    name: "normal",
    attrCostFix: (e) => e * Rand.float(0.8, 1.2),
    maxFireMakingPrompt: () => 4,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.2),
    journeyDistance: () => 48 * Rand.float(1, 1.2),
    resourceIntensity: () => Rand.float(0.8, 1.2),
  );
  static final Hardness hard = Hardness(
    name: "hard",
    attrCostFix: (e) => e * Rand.float(1.1, 1.5),
    maxFireMakingPrompt: () => 8,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.0),
    journeyDistance: () => 55 * Rand.float(1.2, 1.8),
    resourceIntensity: () => Rand.float(0.8, 1.2),
  );
}
