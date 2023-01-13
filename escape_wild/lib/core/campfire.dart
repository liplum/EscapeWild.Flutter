import 'package:json_annotation/json_annotation.dart';

part 'campfire.g.dart';

@JsonSerializable()
class FireState {
  @JsonKey()
  final bool active;
  @JsonKey()
  final double fuel;

  const FireState({
    this.active = false,
    this.fuel = 0.0,
  });

  factory FireState.fromJson(Map<String, dynamic> json) => _$FireStateFromJson(json);

  Map<String, dynamic> toJson() => _$FireStateToJson(this);

  const FireState.off() : this();

  FireState copyWith({
    bool? active,
    double? fuel,
  }) =>
      FireState(
        active: active ?? this.active,
        fuel: fuel ?? this.fuel,
      );
}
