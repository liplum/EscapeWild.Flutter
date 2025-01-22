import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

import 'package:escape_wild/core/index.dart';
import 'package:flutter/widgets.dart';

part 'campfire.g.dart';

@JsonSerializable()
class FireState {
  @JsonKey()
  final double ember;
  @JsonKey()
  final double fuel;
  static const maxVisualFuel = 500.0;

  FireState({
    double ember = 0.0,
    double fuel = 0.0,
  })  : ember = max(0, ember),
        fuel = max(0, fuel);

  bool get active => fuel > 0 || ember > 0;
  bool get isOff => fuel <= 0 && ember <= 0;

  factory FireState.fromJson(Map<String, dynamic> json) => _$FireStateFromJson(json);

  Map<String, dynamic> toJson() => _$FireStateToJson(this);

  static final FireState off = FireState();

  FireState copyWith({
    double? ember,
    double? fuel,
  }) =>
      FireState(
        ember: ember ?? this.ember,
        fuel: fuel ?? this.fuel,
      );
}

abstract class CampfirePlaceProtocol extends PlaceProtocol with ChangeNotifier {
  FireState get fireState;

  set fireState(FireState v);

  List<ItemStack> get onCampfire;

  set onCampfire(List<ItemStack> v);

  List<ItemStack> get offCampfire;

  set offCampfire(List<ItemStack> v);

  void onResetCooking();
}

extension CampfireHolderProtocolX on CampfirePlaceProtocol {
  bool get isCampfireHasAnyStack => onCampfire.isNotEmpty || offCampfire.isNotEmpty;
}

mixin CampfireCookingMixin on CampfirePlaceProtocol {
  @JsonKey(fromJson: tsFromJson, toJson: tsToJson, includeIfNull: false)
  Ts cookingTime = Ts.zero;
  List<ItemStack> _onCampfire = [];

  @override
  @JsonKey(fromJson: campfireStackFromJson, toJson: campfireStackToJson, includeIfNull: false)
  List<ItemStack> get onCampfire => _onCampfire;

  @override
  set onCampfire(List<ItemStack> v) {
    _onCampfire = v;
    notifyListeners();
  }

  List<ItemStack> _offCampfire = [];

  @override
  @JsonKey(fromJson: campfireStackFromJson, toJson: campfireStackToJson, includeIfNull: false)
  List<ItemStack> get offCampfire => _offCampfire;

  @override
  set offCampfire(List<ItemStack> v) {
    _offCampfire = v;
    notifyListeners();
  }

  @CookRecipeProtocol.jsonKey
  CookRecipeProtocol? recipe;

  FireState _fireState = FireState.off;

  @override
  @JsonKey(fromJson: fireStateFromJson, toJson: fireStateStackToJson, includeIfNull: false)
  FireState get fireState => _fireState;

  @override
  set fireState(FireState v) {
    _fireState = v;
    notifyListeners();
  }

  double get fuelCostPerMinute;

  /// Call this after changing [onCampfire].
  @override
  void onResetCooking() {
    cookingTime = Ts.zero;
    final matched = matchCookRecipe(onCampfire);
    recipe = matched;
    if (matched != null) {
      // for instant cooking
      final changed = matched.onMatch(onCampfire, offCampfire);
      if (changed) {
        notifyListeners();
      }
    }
  }

  Future<void> onCampfirePass(Ts delta) async {
    // update items the place holds
    for (final stack in onCampfire) {
      await stack.onPassTime(delta);
    }
    for (final stack in offCampfire) {
      await stack.onPassTime(delta);
    }
    if (fireState.active) {
      final cost = delta.minutes * fuelCostPerMinute;
      fireState = _burningFuel(fireState, cost);
    }
    // only cooking when fire has fuel.
    if (fireState.fuel <= 0) return;
    if (onCampfire.isEmpty) return;
    final recipe = this.recipe ??= matchCookRecipe(onCampfire);
    if (recipe == null) {
      cookingTime = Ts.zero;
    } else {
      cookingTime += delta;
      final changed = recipe.updateCooking(onCampfire, offCampfire, cookingTime, delta);
      if (changed) {
        this.recipe = null;
        cookingTime = Ts.zero;
        notifyListeners();
      }
    }
  }

  Future<void> onFirePass(double fuelCostSpeed, Ts delta) async {
    final fireState = this.fireState;
    if (fireState.active) {
      final cost = delta / actionStepTime * fuelCostSpeed;
      this.fireState = _burningFuel(fireState, cost);
    }
  }

  static List<ItemStack> campfireStackFromJson(dynamic json) =>
      json == null ? [] : (json as List<dynamic>).map((e) => ItemStack.fromJson(e as Map<String, dynamic>)).toList();

  static dynamic campfireStackToJson(List<ItemStack> list) => list.isEmpty ? null : list;

  static Ts tsFromJson(dynamic json) => json == null ? Ts.zero : Ts.fromJson((json as num).toInt());

  static dynamic tsToJson(Ts ts) => ts == Ts.zero ? null : ts;

  static FireState fireStateFromJson(dynamic json) => json == null ? FireState.off : FireState.fromJson(json);

  static dynamic fireStateStackToJson(FireState fire) => fire.isOff ? null : fire;
}

const _emberCostFactor = 5;

// TODO: Better formula
FireState _burningFuel(
  FireState former,
  double cost,
) {
  final curFuel = former.fuel;
  var resFuel = curFuel;
  var resEmber = former.ember;
  if (curFuel <= cost) {
    final costOverflow = cost - curFuel;
    resFuel = 0;
    resEmber += curFuel;
    resEmber -= costOverflow * _emberCostFactor;
  } else {
    resFuel -= cost;
    resEmber += cost;
  }
  return FireState(ember: resEmber, fuel: resFuel);
}
