// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'package:fic/src/fic.dart';

/// This mixin implements all [ImmutableSet] members (without config),
/// but it does **NOT** implement [Iterable] nor [ImmutableSet].
///
/// It is meant to help you wrap an [ImmutableSet] into another class (composition).
/// You must override the [iterable] getter to return the inner [ImmutableSet].
/// All other methods are efficiently implemented in terms of the [iterable].
///
/// To use this mixin, your class must:
///
/// 1. Override the [iterable] getter to return the inner [ImmutableSet].
/// 1. Override the [newInstance] method to return a new instance of the class.
///
/// Example:
///
/// ```dart
/// class Students with FromISetMixin<Student, Students> {
///   final ISet<Student> _students;
///
///   Students([Iterable<Student> students]) : _students = ISet(students);
///
///   Students newInstance(ISet<Student> iset) => Students(iset);
///
///   ISet<Student> get iter => _students;
/// }
///
/// class Student implements Comparable<Student> {
///   final String name;
///
///   const Student(this.name);
///
///   String toString() => "Student: $name";
///
///   bool operator ==(Object other) =>
///      identical(this, other) ||
///      other is Student &&
///          runtimeType == other.runtimeType &&
///          name == other.name;
///
///   int get hashCode => name.hashCode;
///
///   int compareTo(Student other) => name.compareTo(other.name);
/// }
/// ```
///
/// See also: [FromIterableISetMixin].
mixin FromISetMixin<T, I extends FromISetMixin<T, I>> implements CanBeEmpty {
  //
  /// Classes `with` [FromISetMixin] must override this.
  ImmutableSet<T> get iterable;

  /// Classes `with` [FromISetMixin] must override this.
  I newInstance(ImmutableSet<T> iset);

  bool any(bool Function(T element) test) => iterable.any(test);

  Iterable<R> cast<R>() => iterable.cast<R>();

  bool contains(covariant T? element) => iterable.contains(element);

  T elementAt(int index) =>
      throw UnsupportedError("elementAt in $runtimeType is not allowed");

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

  I operator +(Iterable<T> other) => newInstance(iterable + other);

  /// If we have ISet<Never>, we cast it to ISet<T>.
  ImmutableSet<T> get _castIter => (iterable is ImmutableSet<Never>)
      ? iterable.cast<T>().toImmutableSet()
      : iterable;

  I add(T item) => newInstance(_castIter.add(item));

  I addAll(Iterable<T> items) => newInstance(_castIter.addAll(items));

  I clear() => newInstance(iterable.clear());

  bool equalItems(covariant Iterable<T> other) => iterable.equalItems(other);

  bool same(I other) => iterable.same(other.iterable);

  I remove(T item) => newInstance(iterable.remove(item));

  I removeWhere(bool Function(T element) test) =>
      newInstance(iterable.removeWhere(test));

  I retainWhere(bool Function(T element) test) =>
      newInstance(iterable.retainWhere(test));

  I toggle(T element) => newInstance(iterable.toggle(element));

  Set<T> unlock() => iterable.unlock();

  Set<T> unlockView() => iterable.unlockView();

  bool containsAll(Iterable<T> other) => iterable.containsAll(other);

  ImmutableSet<T> difference(Set<T> other) => iterable.difference(other);

  ImmutableSet<T> intersection(Set<T> other) => iterable.intersection(other);

  T? lookup(T element) => iterable.lookup(element);

  ImmutableSet<T> removeAll(Iterable<T> elements) =>
      iterable.removeAll(elements);

  ImmutableSet<T> retainAll(Iterable<T> elements) =>
      iterable.retainAll(elements);

  ImmutableSet<T> union(Set<T> other) => iterable.union(other);

  @override
  String toString() => "$runtimeType$iterable";
}
