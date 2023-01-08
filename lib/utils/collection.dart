extension IterableExtension<T> on Iterable<T> {
  int count(bool Function(T element) test) {
    var number = 0;
    for (var item in this) {
      if (test(item)) number++;
    }
    return number;
  }
}
