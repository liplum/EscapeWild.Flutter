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
