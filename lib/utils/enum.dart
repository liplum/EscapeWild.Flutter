extension EnumComparisonX on Enum {
  bool operator <(Enum other) {
    return index < other.index;
  }

  bool operator <=(Enum other) {
    return index <= other.index;
  }

  bool operator >(Enum other) {
    return index > other.index;
  }

  bool operator >=(Enum other) {
    return index >= other.index;
  }
}

mixin EnumCompareByIndexMixin<T extends Enum> implements Comparable<T> {
  @override
  int compareTo(other) => Enum.compareByIndex<T>(this as T, other);
}
