import 'dart:core' as core;
import 'dart:math';

class Rand {
  Rand._();

  static Random _rand = Random();

  static void setSeed(core.int seed) {
    _rand = Random(seed);
  }

  static core.int int(core.int min, core.int max) {
    return _rand.nextInt(max - min) + min;
  }

  static core.bool bool() {
    return _rand.nextInt(2) == 1;
  }

  static core.double float(core.double min, core.double max) {
    return _rand.nextDouble() * (max - min) + min;
  }

  static core.double one() {
    return _rand.nextDouble();
  }

  static core.double fluctuate(core.double fluctuate, [core.double basedOn = 1]) {
    fluctuate = fluctuate.abs();
    return float(basedOn - fluctuate, basedOn + fluctuate);
  }
}

extension RandomX on Random {
  core.double float(core.double min, core.double max) {
    return nextDouble() * (max - min) + min;
  }
}
