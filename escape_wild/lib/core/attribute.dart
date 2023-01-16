import 'dart:math';
import 'package:escape_wild/core.dart';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonEnum()
enum Attr {
  health,
  food,
  water,
  energy;

  String l10nName() => I18n["attribute.$name"];
}

@JsonSerializable()
class AttrModel {
  static const maxValue = 1.0;
  @JsonKey()
  final Progress health;
  @JsonKey()
  final Progress food;
  @JsonKey()
  final Progress water;
  @JsonKey()
  final Progress energy;

  factory AttrModel.fromJson(Map<String, dynamic> json) => _$AttrModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttrModelToJson(this);
  static const empty = AttrModel.all(0.0);
  static const full = AttrModel.all(maxValue);

  const AttrModel({
    this.health = AttrModel.maxValue,
    this.food = AttrModel.maxValue,
    this.water = AttrModel.maxValue,
    this.energy = AttrModel.maxValue,
  });

  const AttrModel.all(Progress v)
      : health = v,
        food = v,
        water = v,
        energy = v;

  AttrModel copyWith({
    Progress? health,
    Progress? food,
    Progress? water,
    Progress? energy,
  }) =>
      AttrModel(
        health: health ?? this.health,
        food: food ?? this.food,
        water: water ?? this.water,
        energy: energy ?? this.energy,
      );
}

abstract class AttributeManagerProtocol {
  void setAttr(Attr attr, double value);

  double getAttr(Attr attr);

  void modify(Attr attr, double delta);
}

extension AttributeManagerProtocolX on AttributeManagerProtocol {
  operator [](Attr attr) => getAttr(attr);

  operator []=(Attr attr, double value) => setAttr(attr, value);

  double get health => this[Attr.health];

  set health(double value) => this[Attr.health] = value;

  double get food => this[Attr.food];

  set food(double value) => this[Attr.food] = value;

  double get water => this[Attr.water];

  set water(double value) => this[Attr.water] = value;

  double get energy => this[Attr.energy];

  set energy(double value) => this[Attr.energy] = value;
}

class AttributeManagerListenable with AttributeManagerMixin, ChangeNotifier implements AttributeManagerProtocol {
  AttrModel _model;

  @override
  AttrModel get attrs => _model;

  @override
  set attrs(AttrModel value) {
    _model = value;
    notifyListeners();
  }

  AttributeManagerListenable({required AttrModel initial}) : _model = initial;
}

class AttributeManager with AttributeManagerMixin implements AttributeManagerProtocol {
  AttrModel _model;

  @override
  AttrModel get attrs => _model;

  @override
  set attrs(AttrModel value) => _model = value;

  AttributeManager({required AttrModel initial}) : _model = initial;
}

mixin AttributeManagerMixin implements AttributeManagerProtocol {
  static const maxValue = 1.0;
  static const underflowPunishmentRadio = 2.0;

  AttrModel get attrs;

  set attrs(AttrModel value);

  /// If the result is more than [maxValue], the [delta] will be attenuated based on overflow.
  /// If the [water], [food] or [energy] is under zero, [underflowPunishmentRadio] will be applied on health.
  @override
  void modify(Attr attr, double delta) {
    // TODO: Better formula
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
    value = max(0.0, value);
    switch (attr) {
      case Attr.health:
        value = min(value, 1);
        if (attrs.health != value) attrs = attrs.copyWith(health: value);
        break;
      case Attr.food:
        if (attrs.food != value) attrs = attrs.copyWith(food: value);
        break;
      case Attr.water:
        if (attrs.water != value) attrs = attrs.copyWith(water: value);
        break;
      case Attr.energy:
        if (attrs.energy != value) attrs = attrs.copyWith(energy: value);
        break;
    }
  }

  @override
  double getAttr(Attr attr) {
    switch (attr) {
      case Attr.food:
        return attrs.food;
      case Attr.water:
        return attrs.water;
      case Attr.health:
        return attrs.health;
      default:
        return attrs.energy;
    }
  }
}

@JsonSerializable(createToJson: false)
class AttrModifier {
  @JsonKey()
  final Attr attr;
  @JsonKey()
  final double delta;

  const AttrModifier(this.attr, this.delta);

  factory AttrModifier.fromJson(Map<String, dynamic> json) => _$AttrModifierFromJson(json);

  AttrModifier copyWith({
    Attr? attr,
    double? delta,
  }) =>
      AttrModifier(
        attr ?? this.attr,
        delta ?? this.delta,
      );
}

extension AttrModifierX on AttrModifier {
  AttrModifier operator +(double delta) => AttrModifier(attr, this.delta + delta);

  AttrModifier operator -(double delta) => AttrModifier(attr, this.delta + delta);

  AttrModifier operator *(double factor) => AttrModifier(attr, delta * factor);

  AttrModifier operator /(double factor) => AttrModifier(attr, delta / factor);
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

extension AttrModifierBuilderX on AttrModifierBuilder {
  operator <<(AttrModifier modifier) => add(modifier);
}
