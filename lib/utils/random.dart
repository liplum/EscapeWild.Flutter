import 'dart:core' as core;
import 'dart:math';

class Rand {
  static Random _rand = Random();

  static void setSeed(core.int seed) {
    _rand = Random(seed);
  }

  static core.int int(core.int min, core.int max) {
    return _rand.nextInt(max - min) + min;
  }

  static core.double float(core.double min, core.double max) {
    return _rand.nextDouble() * (max - min) + min;
  }

  static core.double one() {
    return _rand.nextDouble();
  }
}
