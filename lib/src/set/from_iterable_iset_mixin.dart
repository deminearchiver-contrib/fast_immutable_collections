// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'package:fic/src/fic.dart';

/// This mixin implements all [Iterable] methods,
/// but it does **NOT** implement [Iterable] nor [ImmutableSet].
///
/// It is meant to help you wrap an [ImmutableSet] into another class (composition).
/// You must override the [iterable] getter to return the inner [ImmutableSet].
/// All other methods are efficiently implemented in terms of the [iterable].
///
/// Note: This class does NOT implement [Iterable]. Unfortunately, the [expect]
/// method in tests compares [Iterable]s by comparing its items. So if you
/// create a class that implement [Iterable] and then you want to use the
/// [expect] method, it will just compare its items, completing ignoring its
/// `operator ==`.
///
/// If you need to iterate over this class, you can use the [iterable] getter:
///
/// ```dart
/// class MyClass with IterableLikeISetMixin<T> { ... }
///
/// MyClass obj = MyClass({1, 2, 3});
///
/// for (int value in obj.iter) print(value);
/// ```
///
/// Please note, if you really want to make your class [Iterable], you can
/// just add the `implements Iterable<T>` to its declaration. For example:
///
/// ```dart
/// class MyClass with IterableLikeISetMixin<T> implements Iterable<T> { ... }
///
/// MyClass obj = MyClass({1, 2, 3});
///
/// for (int value in obj) print(value);
/// ```
///
/// See also: [FromISetMixin].
mixin FromIterableISetMixin<T extends Object?> implements CanBeEmpty {
  /// Classes `with` [FromIterableISetMixin] must override this.
  ImmutableSet<T> get iterable;

  bool any(bool Function(T element) test) => iterable.any(test);

  Iterable<R> cast<R>() => throw UnsupportedError("cast");

  bool contains(covariant T? element) => iterable.contains(element);

  T elementAt(int index) =>
      throw UnsupportedError("elementAt in ISet is not allowed");

  bool every(bool Function(T element) test) => iterable.every(test);

  Iterable<E> expand<E>(Iterable<E> Function(T) f) => iterable.expand(f);

  int get length => iterable.length;

  T get first => iterable.first;

  T get last => iterable.last;

  T get single => iterable.single;

  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.firstWhere(test, orElse: orElse);

  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      iterable.fold(initialValue, combine);

  Iterable<T> followedBy(Iterable<T> other) => iterable.followedBy(other);

  void forEach(void Function(T element) f) => iterable.forEach(f);

  String join([String separator = ""]) => iterable.join(separator);

  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.lastWhere(test, orElse: orElse);

  Iterable<E> map<E>(E Function(T element) f) => iterable.map(f);

  T reduce(T Function(T value, T element) combine) => iterable.reduce(combine);

  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.singleWhere(test, orElse: orElse);

  Iterable<T> skip(int count) => iterable.skip(count);

  Iterable<T> skipWhile(bool Function(T value) test) =>
      iterable.skipWhile(test);

  Iterable<T> take(int count) => iterable.take(count);

  Iterable<T> takeWhile(bool Function(T value) test) =>
      iterable.takeWhile(test);

  Iterable<T> where(bool Function(T element) test) => iterable.where(test);

  Iterable<E> whereType<E>() => iterable.whereType<E>();

  @override
  bool get isEmpty => iterable.isEmpty;

  @override
  bool get isNotEmpty => iterable.isNotEmpty;

  Iterator<T> get iterator => iterable.iterator;

  List<T> toList({bool growable = true}) =>
      List.of(iterable, growable: growable);

  Set<T> toSet() => Set.of(iterable);

  @override
  String toString() => "$runtimeType$iterable";
}
