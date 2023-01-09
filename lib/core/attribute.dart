import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonEnum()
enum AttrType { health, food, water, energy }

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
  void setAttr(AttrType attr, double value);

  double getAttr(AttrType attr);

  void modify(AttrType attr, double delta);
}

extension AttributeManagerProtocolX on AttributeManagerProtocol {
  operator [](AttrType attr) => getAttr(attr);

  operator []=(AttrType attr, double value) => setAttr(attr, value);
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
  void modify(AttrType attr, double delta) {
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
          case AttrType.food:
          case AttrType.water:
          case AttrType.energy:
            setAttr(attr, 0);
            setAttr(AttrType.health, getAttr(AttrType.health) - underflow * underflowPunishmentRadio);
            break;
          case AttrType.health:
            setAttr(attr, after);
            break;
        }
      } else {
        setAttr(attr, after);
      }
    }
  }

  @override
  void setAttr(AttrType attr, double value) {
    switch (attr) {
      case AttrType.health:
        model.health = min(value, 1);
        break;
      case AttrType.food:
        model.food = value;
        break;
      case AttrType.water:
        model.water = value;
        break;
      case AttrType.energy:
        model.energy = value;
        break;
    }
  }

  @override
  double getAttr(AttrType attr) {
    switch (attr) {
      case AttrType.food:
        return model.food;
      case AttrType.water:
        return model.water;
      case AttrType.health:
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
  final AttrType attr;
  final double delta;

  const AttrModifier(this.attr, this.delta);

  factory AttrModifier.fromJson(Map<String, dynamic> json) => _$AttrModifierFromJson(json);
}

extension AttrTypeX on AttrType {
  AttrModifier operator +(double delta) => AttrModifier(this, delta);
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
