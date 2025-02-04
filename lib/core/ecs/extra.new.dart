import 'package:escape_wild/core/ecs/clone.dart';

abstract class WithExtra<TSelf extends WithExtra<TSelf>> implements Cloneable<TSelf>{
  /// Nested objects are not allowed
  Map<String, dynamic> get extra;

  TSelf updateExtra(Map<String, dynamic> newExtra);
}

