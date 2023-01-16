class TS {
  final int minutes;

  const TS(this.minutes);

  const TS.hm(int hour, int min) : minutes = hour * 60 + min;
}

extension IntX on int {
  TS ts() => TS(this);
}

extension TimeSpanX on TS {
  int get hourPart => minutes ~/ 60;

  int get minutePart => minutes % 60;

  double get hours => minutes / 60;

  TS operator +(TS b) => TS(minutes + b.minutes);

  TS operator -(TS b) => TS(minutes - b.minutes);

  TS operator *(double factor) => TS((minutes * factor).toInt());

  TS operator /(double factor) => TS(minutes ~/ factor);

  double operator ~/(TS b) => minutes / b.minutes;
}
