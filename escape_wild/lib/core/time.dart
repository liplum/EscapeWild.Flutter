import 'package:json_annotation/json_annotation.dart';

abstract class MinuteProtocol implements Comparable<MinuteProtocol> {
  int get minutes;

  const MinuteProtocol();

  @override
  String toString() {
    final hour = hourPart;
    return hour > 0 ? "$hour:${minutePart.toString().padRight(2)}" : minutePart.toString().padRight(2);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MinuteProtocol) return false;
    if (runtimeType != other.runtimeType) return false;
    return minutes == other.minutes;
  }

  int toJson() => minutes;

  @override
  int get hashCode => minutes.hashCode;
}

@JsonSerializable()
class Ts extends MinuteProtocol {
  @override
  final int minutes;
  static const zero = Ts(minutes: 0);

  const Ts({required this.minutes});

  const Ts.from({int day = 0, int hour = 0, int minute = 0}) : minutes = day * 60 * 60 + (hour % 24) * 60 + minute % 60;

  static const jsonKey = JsonKey(fromJson: Ts.fromJson);

  @override
  int compareTo(MinuteProtocol other) => minutes.compareTo(other.minutes);

  factory Ts.fromJson(int minutes) => Ts(minutes: minutes);
}

extension IntX on int {
  Ts ts() => Ts(minutes: this);
}

extension MinutesProtocolX<T extends MinuteProtocol> on T {
  int get hourPart => minutes ~/ 60;

  int get minutePart => minutes % 60;

  double get hours => minutes / 60;

  double operator /(T b) => minutes / b.minutes;

  bool operator >(T other) => minutes > other.minutes;

  bool operator >=(T other) => minutes >= other.minutes;

  bool operator <(T other) => minutes < other.minutes;

  bool operator <=(T other) => minutes <= other.minutes;
}

extension TSX on Ts {
  Ts operator +(Ts b) => Ts(minutes: minutes + b.minutes);

  Ts operator -(Ts b) => Ts(minutes: minutes - b.minutes);

  Ts operator *(num factor) => Ts(minutes: (minutes * factor.toDouble()).toInt());

  Ts operator ~/(num factor) => Ts(minutes: minutes ~/ factor.toDouble());
}

extension TSNumX on num {
  Ts operator *(Ts ts) => Ts(minutes: (toDouble() * ts.minutes).toInt());
}

extension TSDoubleX on double {}
