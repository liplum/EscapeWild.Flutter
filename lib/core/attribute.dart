import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonEnum()
enum Attr { health, food, water, energy }

abstract class AttributeModelProtocol {
  double get health;

  set health(double value);

  double get food;

  set food(double value);

  double get water;

  set water(double value);

  double get energy;

  set energy(double value);
}

abstract class AttributeManagerProtocol {
  void setAttr(Attr attr, double value);

  double getAttr(Attr attr);

  void modify(Attr attr, double delta);
}

extension AttributeManagerProtocolX on AttributeManagerProtocol {
  operator [](Attr attr) => getAttr(attr);

  operator []=(Attr attr, double value) => setAttr(attr, value);
}

class AttributeManager with AttributeManagerMixin implements AttributeManagerProtocol {
  @override
  final AttributeModelProtocol model;

  const AttributeManager(this.model);
}

mixin AttributeManagerMixin implements AttributeManagerProtocol {
  static const maxValue = 1.0;
  static const underflowPunishmentRadio = 2.0;

  AttributeModelProtocol get model;

  /// If the result should be is more than [maxValue], the [delta] will be attenuated based on overflow.
  @override
  void modify(Attr attr, double delta) {
    // [1] former = 0.8, delta = 0.5
    // [2] former = 1.2, delta = 0.6
    var former = getAttr(attr);
    // [1] after = 1.3
    // [2] after = 1.8
    var after = former + delta;
    if (after > maxValue) {
      // [1] restToMax = Max(0, 1 - 0.8) = 0.2
      // [2] restToMax = Max(0, 1 - 1.2) = 0
      var restToMax = max(maxValue - former, 0);
      // [1] extra = 0.5 - 0.2 = 0.3
      // [2] extra = 0.6 - 0.0 = 0.6
      var extra = delta - restToMax;
      // [1] after = 0.8 + 0.2 + 0.3 * 0.5^0.8 = 1.172
      // [2] after = 1.2 + 0.0 + 0.6 * 0.5^1.2 = 1.461
      after = (former + restToMax + extra * pow(0.5, former));

      setAttr(attr, after);
    } else {
      if (after < 0) {
        var underflow = after.abs();
        switch (attr) {
          case Attr.food:
          case Attr.water:
          case Attr.energy:
            setAttr(attr, 0);
            setAttr(Attr.health, getAttr(Attr.health) - underflow * underflowPunishmentRadio);
            break;
          case Attr.health:
            setAttr(attr, after);
            break;
        }
      } else {
        setAttr(attr, after);
      }
    }
  }

  @override
  void setAttr(Attr attr, double value) {
    switch (attr) {
      case Attr.health:
        model.health = min(value, 1);
        break;
      case Attr.food:
        model.food = value;
        break;
      case Attr.water:
        model.water = value;
        break;
      case Attr.energy:
        model.energy = value;
        break;
    }
  }

  @override
  double getAttr(Attr attr) {
    switch (attr) {
      case Attr.food:
        return model.food;
      case Attr.water:
        return model.water;
      case Attr.health:
        return model.health;
      default:
        return model.energy;
    }
  }
}

class DefaultAttributeModel with DefaultAttributeModelMixin implements AttributeModelProtocol {}

mixin DefaultAttributeModelMixin implements AttributeModelProtocol {
  @override
  double health = 0.0;
  @override
  double food = 0.0;
  @override
  double water = 0.0;
  @override
  double energy = 0.0;
}

@JsonSerializable(createToJson: false)
class AttrModifier {
  @JsonKey()
  final Attr attr;
  final double delta;

  const AttrModifier(this.attr, this.delta);

  factory AttrModifier.fromJson(Map<String, dynamic> json) => _$AttrModifierFromJson(json);
}

extension AttrTypeX on Attr {
  AttrModifier operator +(double delta) => AttrModifier(this, delta);

  AttrModifier operator -(double delta) => AttrModifier(this, -delta);
}

class AttrModifierBuilder {
  final List<AttrModifier> modifiers = [];

  bool get hasAnyEffect => modifiers.isNotEmpty;

  void add(AttrModifier modifier) {
    modifiers.add(modifier);
  }

  void addAll(List<AttrModifier> modifiers) {
    this.modifiers.addAll(modifiers);
  }

  void performModification(AttributeManagerProtocol attrs) {
    for (var modifier in modifiers) {
      attrs.modify(modifier.attr, modifier.delta);
    }
  }
}
