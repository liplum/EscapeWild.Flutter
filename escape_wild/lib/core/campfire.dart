class FireState {
  final bool active;
  final double fuel;

  const FireState({
    this.active = false,
    this.fuel = 0.0,
  });

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
