class TimeSpan {
  final int minutes;

  const TimeSpan(this.minutes);

  const TimeSpan.hm(int hour, int min) : minutes = hour * 60 + min;
}

extension IntX on int {
  TimeSpan toMinute() => TimeSpan(this);
}

extension TimeSpanX on TimeSpan {
  int get hourPart => minutes ~/ 60;

  int get minutePart => minutes % 60;

  double get hours => minutes / 60;

  TimeSpan operator +(TimeSpan b) => TimeSpan(minutes + b.minutes);

  TimeSpan operator -(TimeSpan b) => TimeSpan(minutes - b.minutes);

  TimeSpan operator *(double factor) => TimeSpan((minutes * factor).toInt());

  TimeSpan operator /(double factor) => TimeSpan(minutes ~/ factor);
}
