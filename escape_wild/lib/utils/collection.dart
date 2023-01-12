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

  Iterable<K> ofType<K>() sync* {
    for (final e in this) {
      if (e is K) {
        yield e;
      }
    }
  }
}

List<List<T>> list2dOf<T>(int maxX, int maxY, T Function(int x, int y) pos, [bool growable = true]) {
  return List.generate(
    maxX,
    growable: growable,
    (x) => List.generate(
      maxY,
      growable: growable,
      (y) => pos(x, y),
    ),
  );
}

List<List<List<T>>> list3dOf<T>(int maxX, int maxY, int maxZ, T Function(int x, int y, int z) pos,
    [bool growable = true]) {
  return List.generate(
    maxX,
    growable: growable,
    (x) => List.generate(
      maxY,
      growable: growable,
      (y) => List.generate(
        maxZ,
        (z) => pos(x, y, z),
      ),
    ),
  );
}
