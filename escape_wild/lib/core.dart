import 'package:jconverter/jconverter.dart';

export 'package:escape_wild/core/action.dart';
export 'package:escape_wild/core/attribute.dart';
export 'package:escape_wild/core/backpack.dart';
export 'package:escape_wild/core/level.dart';
export 'package:escape_wild/core/content.dart';
export 'package:escape_wild/core/time.dart';
export 'package:escape_wild/core/ecs.dart';
export 'package:escape_wild/core/craft.dart';
export 'package:escape_wild/core/i18n.dart';
export 'package:escape_wild/core/hardness.dart';
export 'package:escape_wild/core/item.dart';
export 'package:escape_wild/core/explore.dart';
export 'package:escape_wild/core/mod.dart';
export 'package:escape_wild/core/player.dart';
export 'package:escape_wild/core/route.dart';
export 'package:escape_wild/core/i18n.dart';
export 'package:escape_wild/core/campfire.dart';
export 'package:escape_wild/ambiguous.dart';
export 'package:escape_wild/core/item_pool.dart';

// ignore: non_constant_identifier_names
final Cvt = JConverter();

List<T> deserializeList<T extends JConvertibleProtocol>(dynamic json) {
  final res = <T>[];
  for (final e in json as List) {
    final restored = Cvt.fromJsonObj<T>(e);
    res.add(restored!);
  }
  return res;
}
