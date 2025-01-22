abstract class RestorationProvider<T> {
  /// Return an restore id to save current place.
  dynamic getRestoreIdOf(covariant T place);

  /// Resolve [restoreId] to one of this places.
  T restoreById(dynamic restoreId);
}
