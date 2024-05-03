import 'package:json_annotation/json_annotation.dart';

part 'item_prop.g.dart';

@JsonEnum()
enum ItemProp {
  mass,
  wetness,
  durability,
  freshness;
}

extension ItemPropX on ItemProp {
  ItemPropModifier operator +(double deltaPerMinute) => ItemPropModifier(this, deltaPerMinute);

  ItemPropModifier operator -(double deltaPerMinute) => ItemPropModifier(this, -deltaPerMinute);
}

@JsonSerializable(createToJson: false)
class ItemPropModifier {
  @JsonKey()
  final ItemProp prop;
  @JsonKey()
  final double deltaPerMinute;

  const ItemPropModifier(this.prop, this.deltaPerMinute);

  /// ## Supported format:
  /// - original json object:
  /// ```json
  /// {
  ///   "attr":"durability",
  ///   "deltaPerMinute": -1.5
  /// }
  /// ```
  /// - String literal:
  /// ```json
  /// "durability/-1.5"
  /// ```
  factory ItemPropModifier.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _$ItemPropModifierFromJson(json);
    } else {
      final literal = json.toString();
      final ItemProp prop;
      final double deltaPerMinute;
      final attrNDelta = literal.split("/");
      prop = $enumDecode(_$ItemPropEnumMap, attrNDelta[0]);
      deltaPerMinute = num.parse(attrNDelta[1]).toDouble();
      return ItemPropModifier(prop, deltaPerMinute);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ItemPropModifier || other.runtimeType != runtimeType) return false;
    return prop == other.prop && deltaPerMinute == other.deltaPerMinute;
  }

  @override
  int get hashCode => Object.hash(prop, deltaPerMinute);
}

extension ItemPropModifierX on ItemPropModifier {
  ItemPropModifier operator +(double deltaPerMinute) => ItemPropModifier(prop, this.deltaPerMinute + deltaPerMinute);

  ItemPropModifier operator -(double deltaPerMinute) => ItemPropModifier(prop, this.deltaPerMinute + deltaPerMinute);

  ItemPropModifier operator *(double factor) => ItemPropModifier(prop, deltaPerMinute * factor);

  ItemPropModifier operator /(double factor) => ItemPropModifier(prop, deltaPerMinute / factor);
}
