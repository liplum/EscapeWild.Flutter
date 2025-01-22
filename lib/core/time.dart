import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Ts implements Comparable<Ts> {
  final int minutes;
  static const zero = Ts(minutes: 0);

  const Ts({required this.minutes});

  const Ts.from({int day = 0, int hour = 0, int minute = 0}) : minutes = day * 60 * 60 + (hour % 24) * 60 + minute % 60;

  @override
  int compareTo(Ts other) => minutes.compareTo(other.minutes);

  factory Ts.fromJson(int minutes) => Ts(minutes: minutes);

  int toJson() => minutes;

  @override
  String toString() {
    final s = StringBuffer();
    final day = dayPart;
    if (day > 0) {
      s.write(day);
      s.write(" day ");
    }
    final hour = hourPart;
    if (hour > 0) {
      s.write(hour);
      s.write(" hour ");
    }
    final min = minutePart;
    s.write(min);
    s.write(" min");
    return s.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Ts) return false;
    if (runtimeType != other.runtimeType) return false;
    return minutes == other.minutes;
  }

  @override
  int get hashCode => minutes.hashCode;
}

extension IntX on int {
  Ts ts() => Ts(minutes: this);
}

extension TsX on Ts {
  int get dayPart => minutes ~/ 1440; // 60 * 24 = 1440

  int get hourPart => minutes ~/ 60 % 24;

  int get minutePart => minutes % 60;

  double get hours => minutes / 60;

  double operator /(Ts b) => minutes / b.minutes;

  bool operator >(Ts other) => minutes > other.minutes;

  bool operator >=(Ts other) => minutes >= other.minutes;

  bool operator <(Ts other) => minutes < other.minutes;

  bool operator <=(Ts other) => minutes <= other.minutes;

  Ts operator +(Ts b) => Ts(minutes: minutes + b.minutes);

  Ts operator -(Ts b) => Ts(minutes: minutes - b.minutes);

  Ts operator *(num factor) => Ts(minutes: (minutes * factor.toDouble()).toInt());

  Ts operator ~/(num factor) => Ts(minutes: minutes ~/ factor.toDouble());
}

extension TsNumX on num {
  Ts operator *(Ts ts) => Ts(minutes: (toDouble() * ts.minutes).toInt());
}
