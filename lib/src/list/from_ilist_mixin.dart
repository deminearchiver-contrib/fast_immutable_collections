// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fic/src/fic.dart';

/// This mixin implements all [ImmutableList] methods (without `config` ([ImmutableListConfig])), plus
/// `operator []`, but it does **NOT** implement [Iterable] nor [ImmutableList].
///
/// It is meant to help you wrap an [ImmutableList] into another class (composition).
/// You must override the [iterable] getter to return the inner [ImmutableList].
/// All other methods are efficiently implemented in terms of the [iterable].
///
/// To use this mixin, your class must:
///
/// 1. Override the [iterable] getter to return the inner [ImmutableList].
/// 1. Override the [newInstance] method to return a new instance of the class.
///
/// Example:
///
/// ```dart
/// class Students with FromIListMixin<Student, Students> {
///   final IList<Student> _students;
///
///   Students([Iterable<Student> students]) : _students = IList(students);
///
///   @override
///   Students newInstance(IList<Student> ilist) => Students(ilist);
///
///   @override
///   IList<Student> get iter => _students;
/// }
///
/// class Student implements Comparable<Student>{
///   final String name;
///
///   const Student(this.name);
///
///   int compareTo(Student other) => name.compareTo(other.name);
/// }
/// ```
///
/// Note: Why does this class NOT implement [Iterable]? Unfortunately, the
/// [expect] method in tests compares [Iterable]s by comparing its items. So if
/// you create a class that implements [Iterable] and then, when you want to use the
/// [expect] method, it will just compare its items, completely ignoring its
/// `operator ==`.
///
/// If you need to iterate over this class, you can use the [iterable] getter:
///
/// ```dart
/// class MyClass with FromIListMixin<T, I> { ... }
///
/// MyClass obj = MyClass([1, 2, 3]);
///
/// for (int value in obj.iter) print(value);
/// ```
///
/// Please note: if you really want to make your class [Iterable],
/// you can simply add the `implements Iterable<T>` to its declaration.
/// For example:
///
/// ```dart
/// class MyClass with FromIListMixin<T, I> implements Iterable<T> { ... }
///
/// MyClass obj = MyClass([1, 2, 3]);
///
/// for (int value in obj) print(value);
/// ```
///
/// See also: [FromIterableIListMixin].
///
mixin FromImmutableListMixin<
  T extends Object?,
  I extends FromImmutableListMixin<T, I>
>
    implements CanBeEmpty {
  //
  /// Classes `with` [FromImmutableListMixin] must override this.
  ImmutableList<T> get iterable;

  /// Classes `with` [FromImmutableListMixin] must override this.
  I newInstance(ImmutableList<T> ilist);

  Iterator<T> get iterator => iterable.iterator;

  bool any(bool Function(T element) test) => iterable.any(test);

  Iterable<R> cast<R>() => iterable.cast<R>();

  bool contains(covariant T? element) => iterable.contains(element);

  T operator [](int index) => iterable[index];

  T elementAt(int index) => iterable[index];

  bool every(bool Function(T element) test) => iterable.every(test);

  Iterable<E> expand<E>(Iterable<E> Function(T) f) => iterable.expand(f);

  int get length => iterable.length;

  T get first => iterable.first;

  T get last => iterable.last;

  T get single => iterable.single;

  T? get firstOrNull => iterable.firstOrNull;

  T? get lastOrNull => iterable.lastOrNull;

  T? get singleOrNull => iterable.singleOrNull;

  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.firstWhere(test, orElse: orElse);

  T? firstWhereOrNull(bool Function(T element) test) =>
      iterable.firstWhereOrNull(test);

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

  List<T> toList({bool growable = true}) =>
      List.of(iterable, growable: growable);

  Set<T> toSet() => Set.of(iterable);

  I operator +(Iterable<T> other) => newInstance(iterable + other);

  /// If we have IList&lt;Never&gt;, we cast it to IList&lt;T&gt;.
  ImmutableList<T> get _castIter => (iterable is ImmutableList<Never>)
      ? iterable.cast<T>().toImmutableList()
      : iterable;

  I add(T item) {
    return newInstance(_castIter.add(item));
  }

  I addAll(Iterable<T> items) => newInstance(_castIter.addAll(items));

  ImmutableMap<int, T> asMap() => iterable.asMap();

  I clear() => newInstance(iterable.clear());

  bool equalItems(covariant Iterable<T> other) => iterable.equalItems(other);

  bool unorderedEqualItems(covariant Iterable<T> other) =>
      iterable.unorderedEqualItems(other);

  bool same(I other) => iterable.same(other.iterable);

  I fillRange(int start, int end, [T? fillValue]) =>
      newInstance(iterable.fillRange(start, end, fillValue));

  T? firstOr(T orElse) => iterable.firstOr(orElse);

  Iterable<T> getRange(int start, int end) => iterable.getRange(start, end);

  int indexOf(T element, [int start = 0]) => iterable.indexOf(element, start);

  int indexWhere(bool Function(T element) test, [int start = 0]) =>
      iterable.indexWhere(test, start);

  I insert(int index, T element) =>
      newInstance(iterable.insert(index, element));

  I insertAll(int index, Iterable<T> iterable) =>
      newInstance(this.iterable.insertAll(index, iterable));

  int lastIndexOf(T element, [int? start]) =>
      iterable.lastIndexOf(element, start);

  int lastIndexWhere(bool Function(T element) test, [int? start]) =>
      iterable.lastIndexWhere(test, start);

  T lastOr(T orElse) => iterable.lastOr(orElse);

  I maxLength(int maxLength, {int Function(T a, T b)? priority}) =>
      newInstance(iterable.maxLength(maxLength, priority: priority));

  I process({
    bool Function(ImmutableList<T> list, int index, T item)? test,
    required Iterable<T> Function(ImmutableList<T> list, int index, T item)
    apply,
  }) => newInstance(iterable.process(test: test, convert: apply));

  I put(int index, T value) => newInstance(iterable.put(index, value));

  I remove(T item) => newInstance(iterable.remove(item));

  (I, T) removeAt(int index) {
    final result = iterable.removeAt(index);
    return (newInstance(result.$1), result.$2);
  }

  (I, T) removeLast() {
    final result = iterable.removeLast();
    return (newInstance(result.$1), result.$2);
  }

  I removeRange(int start, int end) =>
      newInstance(iterable.removeRange(start, end));

  I removeWhere(bool Function(T element) test) =>
      newInstance(iterable.removeWhere(test));

  I replaceAll({required T from, required T to}) =>
      newInstance(iterable.replaceAll(from: from, to: to));

  I replaceAllWhere(bool Function(T element) test, T to) =>
      newInstance(iterable.replaceAllWhere(test, to));

  I replaceFirst({required T from, required T to}) =>
      newInstance(iterable.replaceFirst(from: from, to: to));

  I replaceFirstWhere(
    bool Function(T item) test,
    T Function(T? item) replacement,
  ) => newInstance(iterable.replaceFirstWhere(test, replacement));

  I replaceRange(int start, int end, Iterable<T> replacement) =>
      newInstance(iterable.replaceRange(start, end, replacement));

  I retainWhere(bool Function(T element) test) =>
      newInstance(iterable.retainWhere(test));

  I get reversed => newInstance(iterable.reversed);

  I setAll(int index, Iterable<T> iterable) =>
      newInstance(this.iterable.setAll(index, iterable));

  I setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) =>
      newInstance(this.iterable.setRange(start, end, iterable, skipCount));

  I shuffle([Random? random]) => newInstance(iterable.shuffle(random));

  T singleOr(T orElse) => iterable.singleOr(orElse);

  I sort([int Function(T a, T b)? compare]) =>
      newInstance(iterable.sort(compare));

  I sublist(int start, [int? end]) => newInstance(iterable.sublist(start, end));

  I toggle(T element) => newInstance(iterable.toggle(element));

  List<T> unlock() => iterable.unlock();

  List<T> unlockView() => iterable.unlockView();

  @override
  String toString() => "$runtimeType$iterable";
}
