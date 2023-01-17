import 'package:json_annotation/json_annotation.dart';

abstract class MinuteProtocol implements Comparable<MinuteProtocol> {
  final int minutes;

  const MinuteProtocol({required this.minutes});

  const MinuteProtocol.hm({int hour = 0, int minute = 0}) : minutes = hour * 60 + minute % 60;

  @override
  String toString() {
    final hour = hourPart;
    return hour > 0 ? "$hour:${minutePart.toString().padRight(2)}" : minutePart.toString().padRight(2);
  }

  int toJson() => minutes;
}

@JsonSerializable()
class Clock extends MinuteProtocol {
  static const zero = Clock(minutes: 0);

  const Clock({required super.minutes});

  const Clock.hm({int hour = 0, int minute = 0}) : super.hm(hour: hour, minute: minute);

  Clock operator +(TS delta) => Clock(minutes: minutes + delta.minutes);

  @override
  int compareTo(MinuteProtocol other) => minutes.compareTo(other.minutes);

  factory Clock.fromJsom(int minutes) => Clock(minutes: minutes);
}

@JsonSerializable()
class TS extends MinuteProtocol {
  static const zero = TS(minutes: 0);

  const TS({required super.minutes});

  const TS.hm({int hour = 0, int minute = 0}) : super.hm(hour: hour, minute: minute);

  static const jsonKey = JsonKey(fromJson: TS.fromJsom);

  @override
  int compareTo(MinuteProtocol other) => minutes.compareTo(other.minutes);

  factory TS.fromJsom(int minutes) => TS(minutes: minutes);
}

extension IntX on int {
  TS ts() => TS(minutes: this);
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

extension TSX on TS {
  TS operator +(TS b) => TS(minutes: minutes + b.minutes);

  TS operator -(TS b) => TS(minutes: minutes - b.minutes);

  TS operator *(num factor) => TS(minutes: (minutes * factor.toDouble()).toInt());

  TS operator ~/(num factor) => TS(minutes: minutes ~/ factor.toDouble());
}

extension TSNumX on num {
  TS operator *(TS ts) => TS(minutes: (toDouble() * ts.minutes).toInt());
}

extension TSDoubleX on double {}
