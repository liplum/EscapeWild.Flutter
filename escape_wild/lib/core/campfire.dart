import 'package:json_annotation/json_annotation.dart';

part 'campfire.g.dart';

@JsonSerializable()
class FireState {
  @JsonKey()
  final double ember;
  @JsonKey()
  final double fuel;
  static const maxVisualFuel = 500.0;

  const FireState({
    this.ember = 0.0,
    this.fuel = 0.0,
  });

  bool get active => fuel > 0 || ember > 0;

  factory FireState.fromJson(Map<String, dynamic> json) => _$FireStateFromJson(json);

  Map<String, dynamic> toJson() => _$FireStateToJson(this);

  static const FireState off = FireState();

  FireState copyWith({
    double? ember,
    double? fuel,
  }) =>
      FireState(
        ember: ember ?? this.ember,
        fuel: fuel ?? this.fuel,
      );
}
