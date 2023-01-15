import 'dart:math';

class Rand {
  Rand._();

  static Random backend = Random();

  static void setSeed(int seed) {
    backend = Random(seed);
  }

  /// [min] is inclusive, [max] is exclusive
  static int i(int min, int max) {
    return backend.nextInt(max - min) + min;
  }

  static bool b() {
    return backend.nextInt(2) == 1;
  }

  /// [min] is inclusive, [max] is exclusive
  static double f(double min, double max) {
    return backend.nextDouble() * (max - min) + min;
  }

  static double one() {
    return backend.nextDouble();
  }

  static double fluctuate(double fluctuate, [double basedOn = 1]) {
    fluctuate = fluctuate.abs();
    return f(basedOn - fluctuate, basedOn + fluctuate);
  }
}

extension RandomX on Random {
  /// [min] is inclusive, [max] is exclusive
  double f(double min, double max) {
    return nextDouble() * (max - min) + min;
  }

  /// [min] is inclusive, [max] is exclusive
  int i(int min, int max) {
    return nextInt(max - min) + min;
  }

  bool b() {
    return nextInt(2) == 1;
  }

  double one() {
    return nextDouble();
  }
}
