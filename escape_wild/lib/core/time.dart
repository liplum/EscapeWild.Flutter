abstract class MinuteProtocol {
  final int minutes;

  const MinuteProtocol(this.minutes);

  @override
  String toString() {
    final hour = hourPart;
    return hour > 0 ? "$hour:${minutePart.toString().padRight(2)}" : minutePart.toString().padRight(2);
  }
}

class Clock extends MinuteProtocol {
  static const zero = Clock(0);

  const Clock(super.minutes);

  const Clock.hm(int hour, int min) : super(hour * 60 + min);

  Clock operator +(TS delta) => Clock(minutes + delta.minutes);
}

class TS extends MinuteProtocol {
  static const zero = TS(0);

  const TS(super.minutes);

  const TS.hm(int hour, int min) : super(hour * 60 + min);
}

extension IntX on int {
  TS ts() => TS(this);
}

extension MinutesProtocolX on MinuteProtocol {
  int get hourPart => minutes ~/ 60;

  int get minutePart => minutes % 60;

  double get hours => minutes / 60;

  double operator /(MinuteProtocol b) => minutes / b.minutes;
}

extension TSX on TS {
  TS operator +(TS b) => TS(minutes + b.minutes);

  TS operator -(TS b) => TS(minutes - b.minutes);

  TS operator *(double factor) => TS((minutes * factor).toInt());

  TS operator ~/(double factor) => TS(minutes ~/ factor);
}

extension TSDoubleX on double {}
