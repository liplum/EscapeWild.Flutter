import 'package:json_annotation/json_annotation.dart';

part 'campfire.g.dart';

@JsonSerializable()
class FireState {
  @JsonKey()
  final bool active;
  @JsonKey()
  final double fuel;
  static const maxVisualFuel = 500.0;

  const FireState({
    this.active = false,
    this.fuel = 0.0,
  });

  const FireState.active({
    this.fuel = 0.0,
  }) : active = true;

  factory FireState.fromJson(Map<String, dynamic> json) => _$FireStateFromJson(json);

  Map<String, dynamic> toJson() => _$FireStateToJson(this);

  static const FireState off = FireState();

  FireState copyWith({
    bool? active,
    double? fuel,
  }) =>
      FireState(
        active: active ?? this.active,
        fuel: fuel ?? this.fuel,
      );
}
