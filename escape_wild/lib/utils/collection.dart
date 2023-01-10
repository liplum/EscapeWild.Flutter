extension IterableX<T> on Iterable<T> {
  int count(bool Function(T item) test) {
    var number = 0;
    for (var item in this) {
      if (test(item)) number++;
    }
    return number;
  }

  T? maxOfOrNull<V extends Comparable>(V Function(T item) map) {
    T? maxItem;
    V? maxValue;
    for (var item in this) {
      if (maxValue == null) {
        maxItem = item;
        maxValue = map(item);
      } else {
        final value = map(item);
        if (value.compareTo(maxValue) > 0) {
          maxItem = item;
          maxValue = value;
        }
      }
    }
    return maxItem;
  }

  T maxOf<V extends Comparable>(V Function(T item) map) => maxOfOrNull(map)!;
}
