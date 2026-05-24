part of 'immutable_list.dart';

abstract class ImmutableListDelegate<T extends Object?> implements Iterable<T> {
  ImmutableListDelegate();

  /// The [ImmutableListDelegate] class provides the default fallback methods of `Iterable`, but
  /// ideally all of its methods are implemented in all of its subclasses.
  ///
  /// Note these fallback methods need to calculate the flushed list, but
  /// because that's immutable, we cache it.
  List<T>? _flushed;

  /// Returns the flushed list (flushes it only once).
  /// **It is an error to use the flushed list outside of the [ImmutableListDelegate] class**.
  List<T> get flushed {
    _flushed ??= unlock();
    return _flushed!;
  }

  /// Returns a regular Dart (*mutable*, `growable`) List.
  List<T> unlock() => List<T>.of(this, growable: true);

  /// Returns a new `Iterator` that allows iterating the items of the [ImmutableList].
  @override
  Iterator<T> get iterator;

  @override
  bool get isEmpty => iterable.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  Iterable<T> get iterable;

  ImmutableListDelegate<T> add(T item) {
    return ImmutableListAddDelegate<T>(this, item);
  }

  ImmutableListDelegate<T> addAll(Iterable<T> items) =>
      ImmutableListAddAllDelegate<T>(
        this,
        ((items is ImmutableList<T>) ? items._delegate : items),
      );

  // TODO: Still need to implement efficiently.
  /// Removes the first occurrence of [element] from this list.
  ImmutableListDelegate<T> remove(T element) => !contains(element)
      ? this
      : ImmutableListFlatDelegate<T>.unsafe(unlock()..remove(element));

  ImmutableListDelegate<T> removeAll(Iterable<T?> elements) {
    var list = unlock();
    final originalLength = list.length;
    final set = HashSet.of(elements);
    list = unlock()..removeWhere(set.contains);
    if (list.length == originalLength) return this;
    return ImmutableListFlatDelegate<T>.unsafe(list);
  }

  // TODO: Still need to implement efficiently.
  ImmutableListDelegate<T> removeMany(T element) => !contains(element)
      ? this
      : ImmutableListFlatDelegate<T>.unsafe(
          unlock()..removeWhere((e) => e == element),
        );

  // TODO: Still need to implement efficiently.
  /// If the list has more than `maxLength` elements, removes the last elements so it remains
  /// with only `maxLength` elements. If the list has `maxLength` or less elements, doesn't
  /// change anything.
  ImmutableListDelegate<T> maxLength(int maxLength) => maxLength < 0
      ? throw ArgumentError(maxLength)
      : length <= maxLength
      ? this
      : ImmutableListFlatDelegate<T>.unsafe(unlock()..length = maxLength);

  /// Sorts this list according to the order specified by the [compare] function.
  /// If [compare] is not provided, it will use the natural ordering of the type [T].
  ImmutableListDelegate<T> sort([int Function(T a, T b)? compare]) {
    // Explicitly sorts MapEntry (since MapEntry is not Comparable).
    if ((compare == null) && (T == MapEntry)) {
      compare = (a, b) => (a as MapEntry).compareKeyAndValue(b as MapEntry);
    }

    return ImmutableListFlatDelegate<T>.unsafe(
      unlock()..sort(compare ?? compareObject),
    );
  }

  ImmutableListDelegate<T> sortOrdered([int Function(T a, T b)? compare]) {
    // Explicitly sorts MapEntry (since MapEntry is not Comparable).
    if ((compare == null) && (T == MapEntry)) {
      compare = (a, b) => (a as MapEntry).compareKeyAndValue(b as MapEntry);
    }

    return ImmutableListFlatDelegate<T>.unsafe(
      unlock()..sortOrdered(compare ?? compareObject),
    );
  }

  /// Sorts this list according to the order specified by the [ordering] iterable.
  /// Items which don't appear in [ordering] will be included in the end, in no particular order.
  ///
  /// Note: Not very efficient at the moment (will be improved in the future).
  /// Please use for a small number of items.
  ///
  ImmutableListDelegate<T> sortLike(Iterable<T> ordering) {
    final orderingSet = Set.of(ordering);
    final newSet = Set.of(this);
    final intersection = orderingSet.intersection(newSet);
    final difference = newSet.difference(orderingSet);
    final result = ordering.where(intersection.contains).toList()
      ..addAll(difference);
    return ImmutableListFlatDelegate<T>.unsafe(result);
  }

  @override
  bool any(bool Function(T element) test) => iterable.any(test);

  @override
  Iterable<R> cast<R>() => iterable.cast<R>();

  @override
  bool contains(covariant T? element) => iterable.contains(element);

  T operator [](int index);

  @override
  T elementAt(int index) => this[index];

  @override
  bool every(bool Function(T element) test) => iterable.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) => iterable.expand(f);

  @override
  int get length;

  @override
  T get first;

  @override
  T get last;

  @override
  T get single;

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.firstWhere(test, orElse: orElse);

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      iterable.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => iterable.followedBy(other);

  @override
  void forEach(void Function(T element) f) => iterable.forEach(f);

  @override
  String join([String separator = ""]) => iterable.join(separator);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.lastWhere(test, orElse: orElse);

  @override
  Iterable<E> map<E>(E Function(T element) f) => iterable.map(f);

  @override
  T reduce(T Function(T value, T element) combine) => iterable.reduce(combine);

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      iterable.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => iterable.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) =>
      iterable.skipWhile(test);

  @override
  Iterable<T> take(int count) => iterable.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) =>
      iterable.takeWhile(test);

  @override
  Iterable<T> where(bool Function(T element) test) => iterable.where(test);

  @override
  Iterable<E> whereType<E>() => iterable.whereType<E>();

  @override
  List<T> toList({bool growable = true}) =>
      List.of(iterable, growable: growable);

  /// Ordered set.
  @override
  Set<T> toSet() => Set.of(iterable);

  /// Ordered set. Same as [toSet].
  LinkedHashSet<T> toLinkedHashSet() => LinkedHashSet.of(iterable);

  /// Ordered set which is also a list.
  /// Returns a [ListSet], which has the same performance and needs
  /// less memory than a [LinkedHashSet], but can't change size.
  ListSet<T> toListSet() => ListSet.of(iterable);

  /// Unordered set. Returns a [HashSet], which is faster than [LinkedHashSet]
  /// and consumes less memory.
  HashSet<T> toHashSet() => HashSet.of(iterable);
}

/// First we have the items in [_l] and then the items in [_listOrL].
class ImmutableListAddAllDelegate<T extends Object?>
    extends ImmutableListDelegate<T> {
  //
  final ImmutableListDelegate<T> _l;

  // Will always store this as `List` or [L].
  final Iterable<T> _listOrL;

  /// **Safe**.
  /// Note: If you need to pass an [ImmutableList], pass its [ImmutableListDelegate] instead.
  ImmutableListAddAllDelegate(this._l, Iterable<T> items)
    : assert(items is! ImmutableList),
      _listOrL = (items is ImmutableListDelegate<T>)
          ? items
          : List<T>.of(items, growable: false);

  @override
  bool get isEmpty => _l.isEmpty && _listOrL.isEmpty;

  @override
  Iterator<T> get iterator => IteratorAddAll(_l.iterator, _listOrL.iterator);

  @override
  Iterable<T> get iterable => _l.followedBy(_listOrL);

  @override
  bool contains(covariant T? element) =>
      _l.contains(element) || _listOrL.contains(element);

  @override
  T operator [](int index) {
    final length1 = _l.length;
    final length2 = _listOrL.length;
    final length = length1 + length2;

    if (index < 0 || index >= length) {
      return throw RangeError.range(index, 0, length - 1, "index");
    } else {
      return index < length1
          ? _l[index]
          : (_listOrL is List<T>)
          ? _listOrL[index - length1]
          : (_listOrL as ImmutableListDelegate<T>)[index - length1];
    }
  }

  @override
  int get length => _l.length + _listOrL.length;

  @override
  T get first => _l.isNotEmpty ? _l.first : _listOrL.first;

  @override
  T get last => _listOrL.isNotEmpty ? _listOrL.last : _l.last;

  @override
  T get single => _l.isNotEmpty ? _l.single : _listOrL.single;
}

/// First we have the items in [_l] and then [_item].
class ImmutableListAddDelegate<T extends Object?>
    extends ImmutableListDelegate<T> {
  //
  final ImmutableListDelegate<T> _l;
  final T _item;

  ImmutableListAddDelegate(this._l, this._item);

  /// Never null, because even if _item is null it's not empty.
  @override
  bool get isEmpty => false;

  @override
  Iterator<T> get iterator => IteratorAdd(_l.iterator, _item);

  @override
  Iterable<T> get iterable => _l.followedBy([_item]);

  @override
  bool contains(covariant T? element) =>
      _l.contains(element) || _item == element;

  /// Implicitly uniting the list and the item.
  @override
  T operator [](int index) => index < 0 || index >= length
      ? throw RangeError.range(index, 0, length - 1, "index")
      : index == length - 1
      ? _item
      : _l[index];

  @override
  int get length => _l.length + 1;

  @override
  T get first => _l.isEmpty ? _item : _l.first;

  @override
  T get last => _item;

  @override
  T get single => _l.isEmpty ? _item : throw StateError("Too many elements");
}

class ImmutableListFlatDelegate<T extends Object?>
    extends ImmutableListDelegate<T> {
  final List<T> _list;

  /// **Safe**.
  ImmutableListFlatDelegate(Iterable<T> iterable)
    : _list = List.of(iterable, growable: false);

  ImmutableListFlatDelegate.unsafe(this._list);

  @override
  List<T> get flushed => _list;

  @override
  Iterator<T> get iterator => IteratorFlat(_list.iterator);

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  Iterable<T> get iterable => _list;

  @override
  bool contains(covariant T? element) => _list.contains(element);

  @override
  T operator [](int index) => _list[index];

  @override
  int get length => _list.length;

  @override
  T get first => _list.first;

  @override
  T get last => _list.last;

  @override
  T get single => _list.single;

  bool deepListEquals(ImmutableListFlatDelegate? other) =>
      (other != null) &&
      const ListEquality<Object?>().equals(_list, other._list);

  int deepListHashcode() => const ListEquality<Object?>().hash(_list);

  static ImmutableListDelegate<T> empty<T>() =>
      ImmutableListFlatDelegate.unsafe(<T>[]);
}
