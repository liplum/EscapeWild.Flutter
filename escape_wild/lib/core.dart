import 'package:jconverter/jconverter.dart';

export 'package:escape_wild/core/action.dart';
export 'package:escape_wild/core/attribute/attribute.dart';
export 'package:escape_wild/core/backpack/backpack.dart';
export 'package:escape_wild/core/item/durability/durability.dart';
export 'package:escape_wild/core/item/file_starter/fire_starter.dart';
export 'package:escape_wild/core/item/freshness/freshness.dart';
export 'package:escape_wild/core/item/fuel/fuel.dart';
export 'package:escape_wild/core/item/tool/tool.dart';
export 'package:escape_wild/core/item/usable/usable.dart';
export 'package:escape_wild/core/item/wetness/wetness.dart';
export 'package:escape_wild/core/ecs/ecs.dart';
export 'package:escape_wild/core/level.dart';
export 'package:escape_wild/core/content.dart';
export 'package:escape_wild/core/time.dart';
export 'package:escape_wild/core/item/item_prop.dart';
export 'package:escape_wild/core/craft/craft.dart';
export 'package:escape_wild/core/i18n.dart';
export 'package:escape_wild/core/hardness/hardness.dart';
export 'package:escape_wild/core/item/item.dart';
export 'package:escape_wild/core/item/continuous/continuous.dart';
export 'package:escape_wild/core/explore.dart';
export 'package:escape_wild/core/mod.dart';
export 'package:escape_wild/core/data_class.dart';
export 'package:escape_wild/core/player.dart';
export 'package:escape_wild/core/route.dart';
export 'package:escape_wild/core/campfire/campfire.dart';
export 'package:escape_wild/core/cook/cook.dart';
export 'package:escape_wild/core/item_pool.dart';
export 'package:escape_wild/ambiguous.dart';

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
