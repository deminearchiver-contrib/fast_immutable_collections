part of 'immutable_set.dart';

abstract class ImmutableSetDelegate<T extends Object?> implements Iterable<T> {
  //

  /// The [ImmutableSetDelegate] class provides the default fallback methods of `Iterable`, but
  /// ideally all of its methods are implemented in all of its subclasses.
  ///
  /// Note these fallback methods need to calculate the flushed set, but
  /// because that's immutable, we **cache** it.
  ListSet<T>? _flushed;

  /// Returns the flushed set (flushes it only once).
  /// It is an error to use the flushed set outside of the [ImmutableSetDelegate] class.
  ListSet<T> getFlushed(ImmutableSetConfig? config) {
    _flushed ??= ListSet.of(
      this,
      sort: (config ?? ImmutableSet.defaultConfig).sort,
    );
    return _flushed!;
  }

  /// Returns a Dart [Set] (*mutable, ordered, of type [LinkedHashSet]*).
  Set<T> unlock() => LinkedHashSet.of(this);

  /// Returns a new [Iterator] that allows iterating the items of the [ImmutableSet].
  @override
  Iterator<T> get iterator;

  @override
  bool get isEmpty => iter.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  Iterable<T> get iter;

  /// Returns any item from the set.
  T get anyItem;

  /// Returns a new set containing the current set plus the given item.
  /// However, if the given item already exists in the set,
  /// it will return the current set (same instance).
  ImmutableSetDelegate<T> add(T item) =>
      contains(item) ? this : ImmutableSetAddDelegate(this, item);

  /// Returns a new set containing the current set plus all the given items.
  /// However, if all given items already exists in the set,
  /// it will return the current set (same instance).
  /// Note: The items of [items] which are already in the original set will be ignored.
  ImmutableSetDelegate<T> addAll(Iterable<T> items) {
    final Set<T> setToBeAdded = ListSet.of(
      items.where((item) => !contains(item)),
    );
    return setToBeAdded.isEmpty
        ? this
        : ImmutableSetAddAllDelegate.unsafe(this, setToBeAdded);
  }

  // TODO: Still need to implement efficiently.
  ImmutableSetDelegate<T> remove(T element) => !contains(element)
      ? this
      : ImmutableSetFlatDelegate<T>.unsafe(unlock()..remove(element));

  @override
  bool any(bool Function(T element) test) => iter.any(test);

  @override
  Iterable<R> cast<R>() => iter.cast<R>();

  @override
  bool contains(covariant T? element);

  bool containsAll(Iterable<T> other);

  T? lookup(T element);

  Set<T> difference(Set<T> other);

  Set<T> intersection(Set<T> other);

  Set<T> union(Set<T> other);

  @override
  bool every(bool Function(T element) test) => iter.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) => iter.expand(f);

  @override
  int get length => iter.length;

  @override
  T get first => iter.first;

  @override
  T get last => iter.last;

  @override
  T get single => iter.single;

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iter.firstWhere(test, orElse: orElse);

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      iter.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => iter.followedBy(other);

  @override
  void forEach(void Function(T element) f) => iter.forEach(f);

  @override
  String join([String separator = ""]) => iter.join(separator);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iter.lastWhere(test, orElse: orElse);

  @override
  Iterable<E> map<E>(E Function(T element) f) => iter.map(f);

  @override
  T reduce(T Function(T value, T element) combine) => iter.reduce(combine);

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iter.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => iter.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => iter.skipWhile(test);

  @override
  Iterable<T> take(int count) => iter.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => iter.takeWhile(test);

  @override
  Iterable<T> where(bool Function(T element) test) => iter.where(test);

  @override
  Iterable<E> whereType<E>() => iter.whereType<E>();

  @override
  List<T> toList({bool growable = true}) => List.of(this, growable: growable);

  @override
  Set<T> toSet() => LinkedHashSet.of(this);

  @override
  T elementAt(int index) => this[index];

  T operator [](int index);
}

/// First we have the items in [_s] and then the items in [_setOrS].
///
/// The [ImmutableSetAddAllDelegate] class does not check for duplicate elements. In other words,
/// it's up to the caller (in this case [ImmutableSetDelegate]) to make sure [_s] and [_setOrS]
/// do not contain any same elements.
///
class ImmutableSetAddAllDelegate<T extends Object?>
    extends ImmutableSetDelegate<T> {
  final ImmutableSetDelegate<T> _s;

  // Will always store this as `Set` or [S].
  final Iterable<T> _setOrS;

  /// **Safe**.
  /// Note: If you need to pass an [ImmutableSet], pass its [ImmutableSetDelegate] instead.
  ImmutableSetAddAllDelegate(this._s, Iterable<T> items)
    : assert(items is! ImmutableSet),
      _setOrS = (items is ImmutableSetDelegate) ? items : Set.of(items);

  /// **Unsafe**.
  ImmutableSetAddAllDelegate.unsafe(this._s, Set<T> items) : _setOrS = items;

  @override
  bool get isEmpty => false;

  @override
  Iterator<T> get iterator => IteratorAddAll(_s.iterator, _setOrS.iterator);

  @override
  Iterable<T> get iter => _s.followedBy(_setOrS);

  @override
  bool contains(covariant T? element) {
    // Check the real set first (It's probably faster).
    return _setOrS.contains(element) || _s.contains(element);
  }

  @override
  bool containsAll(Iterable<T> other) {
    for (final o in other) {
      if ((!_setOrS.contains(o)) && (!_s.contains(o))) return false;
    }
    return true;
  }

  @override
  T? lookup(T element) {
    final T? result = _s.lookup(element);

    if (result != null)
      return result;
    else if (_setOrS is ImmutableSetDelegate)
      return (_setOrS as ImmutableSetDelegate<T>).lookup(element);
    else if (_setOrS is Set)
      return (_setOrS as Set<T>).lookup(element);
    else
      throw AssertionError();
  }

  @override
  Set<T> difference(Set<T> other) =>
      Set.of(_s.followedBy(_setOrS))..removeAll(other);

  @override
  Set<T> intersection(Set<T> other) =>
      _s.intersection(other)..addAll(_setOrS.toSet().intersection(other));

  @override
  Set<T> union(Set<T> other) => _s.union(_setOrS.toSet())..addAll(other);

  @override
  int get length => _s.length + _setOrS.length;

  @override
  T get anyItem => _s.first;

  @override
  T get first => _s.isNotEmpty ? _s.first : _setOrS.first;

  @override
  T get last => _setOrS.isNotEmpty ? _setOrS.last : _s.last;

  @override
  T get single => _s.isNotEmpty ? _s.single : _setOrS.single;

  @override
  T operator [](int index) {
    final sLength = _s.length;
    return (index < sLength) ? _s[index] : _setOrS.elementAt(index - sLength);
  }
}

/// The [ImmutableSetAddDelegate] class does not check for duplicate elements. In other words,
/// it's up to the caller (in this case [ImmutableSetDelegate]) to make sure [_s] does not
/// contain [_item].
///
class ImmutableSetAddDelegate<T extends Object?>
    extends ImmutableSetDelegate<T> {
  final ImmutableSetDelegate<T> _s;
  final T _item;

  ImmutableSetAddDelegate(this._s, this._item);

  @override
  bool get isEmpty => false;

  @override
  Iterator<T> get iterator => IteratorAdd(_s.iterator, _item);

  @override
  Iterable<T> get iter => _s.followedBy([_item]);

  @override
  bool contains(covariant T? element) =>
      _s.contains(element) || _item == element;

  @override
  bool containsAll(Iterable<T> other) {
    for (final o in other) {
      if ((_item != o) && (!_s.contains(o))) return false;
    }
    return true;
  }

  @override
  T? lookup(T element) {
    T? result = _s.lookup(element);
    result ??= (_item == element) ? _item : null;
    return result;
  }

  @override
  Set<T> difference(Set<T> other) {
    if (other.contains(_item)) {
      return _s.difference(other);
    } else {
      return _s.difference(other)..add(_item);
    }
  }

  @override
  Set<T> intersection(Set<T> other) {
    final containsItem = other.contains(_item);
    final result = _s.intersection(other);
    if (containsItem) result.add(_item);
    return result;
  }

  @override
  Set<T> union(Set<T> other) => _s.union({_item})..addAll(other);

  @override
  int get length => _s.length + 1;

  @override
  T get anyItem => _item;

  @override
  T get first => _s.isEmpty ? _item : _s.first;

  @override
  T get last => _item;

  @override
  T get single => _s.isEmpty ? _item : throw StateError("Too many elements");

  @override
  T operator [](int index) {
    final sLength = _s.length;
    if (index < 0 || index >= sLength + 1)
      throw RangeError.range(index, 0, sLength + 1, "index");
    return (index < sLength) ? _s[index] : _item;
  }
}

class ImmutableSetFlatDelegate<T extends Object?>
    extends ImmutableSetDelegate<T> {
  final ListSet<T> _set;

  static ImmutableSetDelegate<T> empty<T>() =>
      ImmutableSetFlatDelegate.unsafe(ListSet<T>.empty());

  /// **Safe**. Note: This will sort according to the configuration.
  ImmutableSetFlatDelegate(Iterable<T> iterable, {ImmutableSetConfig? config})
    : _set = ListSet.of(
        iterable,
        sort: (config ?? ImmutableSet.defaultConfig).sort,
      );

  /// **Unsafe**. Note: Does not sort.
  ImmutableSetFlatDelegate.unsafe(Set<T> set) : _set = ListSet.unsafeView(set);

  @override
  ListSet<T> getFlushed(ImmutableSetConfig? config) => _set;

  @override
  Iterator<T> get iterator => _set.iterator;

  @override
  bool get isEmpty => _set.isEmpty;

  @override
  Iterable<T> get iter => _set;

  @override
  T get anyItem => _set.first;

  @override
  bool contains(covariant T? element) => _set.contains(element);

  @override
  bool containsAll(Iterable<T> element) => _set.containsAll(element);

  @override
  T? lookup(Object? object) => _set.lookup(object);

  @override
  Set<T> difference(Set<T> other) => _set.difference(other);

  @override
  Set<T> intersection(Set<T> other) => _set.intersection(other);

  @override
  Set<T> union(Set<T> other) => _set.union(other);

  @override
  int get length => _set.length;

  @override
  T get first => _set.first;

  @override
  T get last => _set.last;

  @override
  T get single => _set.single;

  @override
  T operator [](int index) => _set[index];

  bool deepSetEqualsToIterable(Iterable<Object?>? other) {
    if (other == null) return false;
    final set = other is Set<Object?> ? other : Set<Object?>.of(other);
    return const SetEquality<Object?>(
      MapEntryEquality<Object?>(),
    ).equals(_set, set);
  }

  bool deepSetEquals(ImmutableSetFlatDelegate<Object?>? other) =>
      (other != null) &&
      const SetEquality<Object?>(
        MapEntryEquality<Object?>(),
      ).equals(_set, other._set);

  int deepSetHashcode() =>
      const SetEquality<Object?>(MapEntryEquality<Object?>()).hash(_set);
}
