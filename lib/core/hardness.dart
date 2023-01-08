import 'package:escape_wild_flutter/utils/random.dart';
import 'package:flutter/foundation.dart';

typedef ValueFixer = double Function(double raw);

class Hardness {
  final ValueFixer attrCostFix;
  final ValueGetter<int> maxFireMakingPrompt;
  final ValueFixer attrBounceFix;
  final ValueGetter<double> journeyLength;

  const Hardness({
    required this.attrCostFix,
    required this.attrBounceFix,
    required this.maxFireMakingPrompt,
    required this.journeyLength,
  });
}

class HardnessTable {
  static final Hardness easy = Hardness(
    attrCostFix: (e) => e * Rand.float(0.5, 0.8),
    maxFireMakingPrompt: () => 2,
    attrBounceFix: (e) => e * Rand.float(1.2, 1.5),
    journeyLength: () => 40 * Rand.float(0.9, 1.1),
  );
  static final Hardness normal = Hardness(
    attrCostFix: (e) => e * Rand.float(0.8, 1.2),
    maxFireMakingPrompt: () => 4,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.2),
    journeyLength: () => 40 * Rand.float(0.8, 1.2),
  );
  static final Hardness hard = Hardness(
    attrCostFix: (e) => e * Rand.float(1.1, 1.5),
    maxFireMakingPrompt: () => 8,
    attrBounceFix: (e) => e * Rand.float(0.8, 1.0),
    journeyLength: () => 40 * Rand.float(0.8, 1.2),
  );
}
