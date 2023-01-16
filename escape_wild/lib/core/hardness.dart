import 'dart:math';

import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/random.dart';
import 'package:flutter/foundation.dart';

typedef ValueFixer = double Function(double raw);
typedef RandomGetter<T> = T Function(Random rand);

/// TODO: Add to [Contents].
class Hardness with Moddable, TagsMixin {
  @override
  final String name;
  final ValueFixer attrCostFix;
  final ValueGetter<Times> maxFireMakingPrompt;
  final ValueFixer attrBounceFix;
  final RandomGetter<Distance> journeyDistance;
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
    attrCostFix: (e) => e * Rand.f(0.5, 0.8),
    maxFireMakingPrompt: () => 2,
    attrBounceFix: (e) => e * Rand.f(1.2, 1.5),
    journeyDistance: (rand) => 40 * rand.f(0.9, 1.1),
    resourceIntensity: () => 10 * Rand.f(0.9, 1.1),
  );
  static final Hardness normal = Hardness(
    name: "normal",
    attrCostFix: (e) => e * Rand.f(0.8, 1.2),
    maxFireMakingPrompt: () => 4,
    attrBounceFix: (e) => e * Rand.f(0.8, 1.2),
    journeyDistance: (rand) => 48 * rand.f(1, 1.2),
    resourceIntensity: () => Rand.f(0.8, 1.2),
  );
  static final Hardness hard = Hardness(
    name: "hard",
    attrCostFix: (e) => e * Rand.f(1.1, 1.5),
    maxFireMakingPrompt: () => 8,
    attrBounceFix: (e) => e * Rand.f(0.8, 1.0),
    journeyDistance: (rand) => 55 * rand.f(1.2, 1.8),
    resourceIntensity: () => Rand.f(0.8, 1.2),
  );
}
