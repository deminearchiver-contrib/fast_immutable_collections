// TODO: optimize
extension FICZipExtension<U, V> on Iterable<(U, V)> {
  /// Iterable Record as Iterable
  (Iterable<U>, Iterable<V>) unzip() => (
    Iterable<U>.generate(length, (index) => elementAt(index).$1),
    Iterable<V>.generate(length, (index) => elementAt(index).$2),
  );
}
