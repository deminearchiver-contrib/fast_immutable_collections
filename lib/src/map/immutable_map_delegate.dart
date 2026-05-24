part of 'immutable_map.dart';

abstract class ImmutableMapDelegate<K extends Object?, V extends Object?> {
  ImmutableMapDelegate();

  /// The [ImmutableMapDelegate] class provides the default fallback methods of `Iterable`, but
  /// ideally all of its methods are implemented in all of its subclasses.
  ///
  /// Note these fallback methods need to calculate the flushed map, but
  /// because that"s immutable, we cache it.
  Map<K, V>? _flushed;

  /// Returns the flushed map (flushes it only once).
  /// **It is an error to use the flushed map outside of the [ImmutableMapDelegate] class.**
  Map<K, V> getFlushed(ImmutableMapConfig? config) {
    _flushed ??= ListMap.fromEntries(
      entries,
      sort: (config ?? ImmutableMap.defaultConfig).sort,
    );
    return _flushed!;
  }

  /// Returns a regular Dart (*mutable*) Map.
  Map<K, V> get unlock => <K, V>{}..addEntries(entries);

  Iterable<MapEntry<K, V>> get entries;

  Iterable<K> get keys;

  Iterable<V> get values;

  Iterator<MapEntry<K, V>> get iterator;

  int get length;

  /// Used by tail-call-optimisation.
  /// Returns type [V] or [ImmutableMapDelegate].
  @protected
  Object? getVOrM(K key);

  /// Used by tail-call-optimisation.
  /// Returns type [bool] or [ImmutableMapDelegate].
  @protected
  Object containsKeyOrM(K? key);

  /// Returns a new map containing the current map plus the given key:value.
  /// However, if the given key already exists in the set,
  /// it will remove the old one and add the new one.
  ImmutableMapDelegate<K, V> add({required K key, required V value}) {
    final bool contains = containsKey(key);
    if (!contains) {
      return ImmutableMapAddDelegate<K, V>(this, key, value);
    } else {
      final V? oldValue = this[key];
      return (oldValue == value) //
          ? this
          : ImmutableMapReplaceDelegate<K, V>(this, key, value);
    }
  }

  /// The entries of the given [imap] will be added to the original map.
  /// Note: [imap] entries that already exist in the original map will be overwritten
  /// with new values.
  ///
  /// If the current map is sorted, then if [keepOrder] is `false` (the default),
  /// those entries that already exist will go to the end of the new map. If
  /// [keepOrder] is `true`, those entries that already exist will be replaced in
  /// place.
  ///
  /// If the current map is NOT sorted, the [keepOrder] parameter is ignored.
  ///
  /// Note: This will NOT sort anything.
  ///
  @useResult
  ImmutableMapDelegate<K, V> addAll(
    ImmutableMap<K, V> imap, {
    bool keepOrder = false,
  }) {
    if (keepOrder) {
      final Map<K, V> map = Map.fromEntries(entries.followedBy(imap.entries));
      return ImmutableMapFlatDelegate<K, V>.unsafe(map);
    }
    //
    else {
      // We want the entries being added to overwrite those of the original add.
      // So we have to remove the entries that are already present in the second map.
      final Map<K, V> firstMap = ListMap.fromEntries(
        entries.where((entry) => !imap.containsKey(entry.key)),
      );

      final ImmutableMapDelegate<K, V> firstM =
          ImmutableMapFlatDelegate<K, V>.unsafe(firstMap);

      return ImmutableMapAddAllDelegate<K, V>.unsafe(firstM, imap._delegate);
    }
  }

  /// The [map] entries will be added to the original map.
  /// Note: [map] entries that already exist in the original map will be overwritten
  /// with new values, in place (keeping order).
  ///
  /// Note: This will NOT sort anything.
  ///
  ImmutableMapDelegate<K, V> addMap(Map<K, V> map) {
    final Map<K, V> newMap = Map.fromEntries(entries.followedBy(map.entries));
    return ImmutableMapFlatDelegate<K, V>.unsafe(newMap);
  }

  /// The [entries] will be added to the original map.
  /// Note: [entries] that already exist in the original map will overwrite
  /// those of the original map, in place (keeping order).
  ///
  /// Note: This will NOT sort anything.
  ///
  ImmutableMapDelegate<K, V> addEntries(Iterable<MapEntry<K, V>> entries) {
    final Map<K, V> map = Map.fromEntries(this.entries.followedBy(entries));
    return ImmutableMapFlatDelegate<K, V>.unsafe(map);
  }

  // TODO: Still need to implement efficiently.
  ImmutableMapDelegate<K, V> remove(K key) {
    return !containsKey(key)
        ? this
        : ImmutableMapFlatDelegate<K, V>.unsafe(unlock..remove(key));
  }

  /// Removes all entries of this map that satisfy the given [predicate].
  ImmutableMapDelegate<K, V> removeWhere(
    bool Function(K key, V value) predicate,
  ) {
    final Map<K, V> oldMap = unlock;
    final int oldLength = oldMap.length;
    final Map<K, V> newMap = oldMap..removeWhere(predicate);
    return (newMap.length == oldLength)
        ? this
        : ImmutableMapFlatDelegate<K, V>.unsafe(newMap);
  }

  /// Provides a view of this map as having [RK] keys and [RV] instances.
  /// May return `M<RK, RV>` or `Map<RK, RV>`.
  Map<RK, RV> cast<RK, RV>(ImmutableMapConfig config) => (RK == K && RV == V)
      ? (this as Map<RK, RV>)
      : getFlushed(config).cast<RK, RV>();

  /// Returns `true` if there is no key/value pair in the map.
  bool get isEmpty => length == 0;

  /// Returns `true` if there is at least one key/value pair in the map.
  bool get isNotEmpty => !isEmpty;

  V? operator [](K key);

  /// Returns `true` if this map contains the given [key] with the given [value].
  bool contains(K key, V value) {
    final V? _value = this[key];
    return (_value == null) ? containsKey(key) : (_value == value);
  }

  /// Returns `true` if this map contains the given [key].
  ///
  /// Returns `true` if any of the keys in the map are equal to `key`
  /// according to the equality used by the map.
  bool containsKey(K? key);

  /// Returns `true` if this map contains the given [value].
  ///
  /// Returns `true` if any of the values in the map are equal to `value`
  /// according to the `==` operator.
  bool containsValue(V? value);

  bool containsEntry(MapEntry<K, V> entry) => contains(entry.key, entry.value);

  bool any(bool Function(K key, V value) test) =>
      entries.any((entry) => test(entry.key, entry.value));

  bool anyEntry(bool Function(MapEntry<K, V>) test) => entries.any(test);

  bool everyEntry(bool Function(MapEntry<K, V>) test) => entries.every(test);

  void forEach(void Function(K key, V value) f) =>
      entries.forEach((entry) => f(entry.key, entry.value));

  Map<K, V> where(bool Function(K key, V value) test) {
    final Map<K, V> matches = {};
    entries.forEach((entry) {
      if (test(entry.key, entry.value)) matches[entry.key] = entry.value;
    });
    return matches;
  }
}

class ImmutableMapAddAllDelegate<K extends Object?, V extends Object?>
    extends ImmutableMapDelegate<K, V> {
  final ImmutableMapDelegate<K, V> _m, _items;

  ImmutableMapAddAllDelegate.unsafe(this._m, this._items);

  @override
  bool get isEmpty => _m.isEmpty && _items.isEmpty;

  @override
  Iterable<MapEntry<K, V>> get entries => _m.entries.followedBy(_items.entries);

  @override
  Iterable<K> get keys => _m.keys.followedBy(_items.keys);

  @override
  Iterable<V> get values => _m.values.followedBy(_items.values);

  @override
  V? operator [](K key) => _items[key] ?? _m[key];

  /// This may be used to help avoid stack-overflow.
  @protected
  @override
  Object? getVOrM(K key) => _items[key] ?? _m;

  /// Used by tail-call-optimisation.
  /// Returns type [bool] or [ImmutableMapDelegate].
  @protected
  @override
  Object containsKeyOrM(K? key) =>
      _items.containsKey(key) || _m.containsKey(key);

  @override
  bool contains(K key, V value) {
    final V? _value = _items[key] ?? _m[key];
    return value == _value;
  }

  @override
  bool containsKey(K? key) => _items.containsKey(key) || _m.containsKey(key);

  @override
  bool containsValue(V? value) =>
      _items.containsValue(value) || _m.containsValue(value);

  @override
  int get length => _m.length + _items.length;

  @override
  Iterator<MapEntry<K, V>> get iterator =>
      IteratorAddAll(_m.iterator, _items.iterator);
}

class ImmutableMapAddDelegate<K extends Object?, V extends Object?>
    extends ImmutableMapDelegate<K, V> {
  final ImmutableMapDelegate<K, V> _m;
  final K _key;
  final V _value;

  ImmutableMapAddDelegate(this._m, this._key, this._value);

  @override
  bool get isEmpty => false;

  @override
  Iterable<MapEntry<K, V>> get entries =>
      _m.entries.followedBy([MapEntry<K, V>(_key, _value)]);

  @override
  Iterable<K> get keys => _m.keys.followedBy(<K>[_key]);

  @override
  Iterable<V> get values => _m.values.followedBy(<V>[_value]);

  /// This may be used to help avoid stack-overflow.
  @protected
  @override
  Object? getVOrM(K key) => (key == _key) ? _value : _m;

  /// Used by tail-call-optimisation.
  /// Returns type [bool] or [ImmutableMapDelegate].
  @protected
  @override
  Object containsKeyOrM(K? key) => (key == _key) ? true : _m;

  /// Implicitly uniting the maps.
  @override
  V? operator [](K key) {
    // This is the tail-call-optimisation for:
    // `V? operator [](K key) => (key == _key) ? _value : _m[key];`
    if (key == _key) {
      return _value;
    } else {
      Object? vOrM = _m;
      while (vOrM is ImmutableMapDelegate) {
        vOrM = vOrM.getVOrM(key);
      }
      return vOrM as V?;
    }
  }

  @override
  bool containsKey(K? key) {
    // This is the tail-call-optimisation for:
    // `bool containsKey(K? key) => (key == _key) || _m.containsKey(key);`
    if ((key == _key))
      return true;
    else {
      Object vOrM = _m;
      while (vOrM is ImmutableMapDelegate) {
        vOrM = vOrM.containsKeyOrM(key);
        if (vOrM is bool) return vOrM;
      }
      return vOrM as bool;
    }
  }

  @override
  bool contains(K key, V value) =>
      (key == _key && value == _value) || _m.contains(key, value);

  @override
  bool containsValue(V? value) => (value == _value) || _m.containsValue(value);

  @override
  int get length => _m.length + 1;

  @override
  Iterator<MapEntry<K, V>> get iterator =>
      IteratorAdd(_m.iterator, MapEntry(_key, _value));
}

class ImmutableMapFlatDelegate<K extends Object?, V extends Object?>
    extends ImmutableMapDelegate<K, V> {
  static ImmutableMapDelegate<K, V> empty<K, V>() =>
      ImmutableMapFlatDelegate<K, V>.unsafe(<K, V>{});

  final Map<K, V> _map;

  /// **Safe**. Note: This will sort according to the configuration.
  ImmutableMapFlatDelegate(Map<K, V> map, {ImmutableMapConfig? config})
    : _map = ListMap.of(map, sort: (config ?? ImmutableMap.defaultConfig).sort);

  ImmutableMapFlatDelegate.fromEntries(
    Iterable<MapEntry<K, V>> entries, {
    ImmutableMapConfig? config,
  }) : _map = ListMap<K, V>.fromEntries(
         entries,
         sort: (config ?? ImmutableMap.defaultConfig).sort,
       );

  ImmutableMapFlatDelegate.from(
    ImmutableMapDelegate<K, V> delegate, {
    ImmutableMapConfig? config,
  }) : _map = ListMap<K, V>.fromEntries(
         delegate.entries,
         sort: (config ?? ImmutableMap.defaultConfig).sort,
       );

  /// **Unsafe**. Note: Does not sort.
  ImmutableMapFlatDelegate.unsafe(Map<K, V> map)
    : _map = ListMap.unsafeView(map);

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  Iterable<V> get values => _map.values;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  Map<RK, RV> cast<RK, RV>(ImmutableMapConfig config) => _map.cast<RK, RV>();

  @override
  bool any(bool Function(K, V) test) =>
      _map.entries.any((entry) => test(entry.key, entry.value));

  @override
  V? operator [](K key) => _map[key];

  @override
  bool contains(K key, V value) =>
      (value != null) //
      ? (_map[key] == value)
      : (_map.containsKey(key) && (_map[key] == null));

  @override
  bool containsKey(K? key) => _map.containsKey(key);

  @override
  bool containsValue(V? value) => _map.containsValue(value);

  /// This may be used to help avoid stack-overflow.
  @protected
  @override
  Object? getVOrM(K key) => _map[key];

  /// Used by tail-call-optimisation.
  /// Returns type [bool] or [ImmutableMapDelegate].
  @protected
  @override
  Object containsKeyOrM(K? key) => _map.containsKey(key);

  @override
  int get length => _map.length;

  @override
  Iterator<MapEntry<K, V>> get iterator => entries.iterator;

  /// Map equality but with an [Iterable] of [MapEntry].
  /// Like the other [Map] equalities, it doesn't  take order into consideration.
  bool deepMapEqualsToIterable(Iterable<MapEntry<Object?, Object?>>? entries) {
    if (entries == null) return false;
    final map = Map<Object?, Object?>.fromEntries(entries);
    return const MapEquality<Object?, Object?>().equals(_map, map);
  }

  bool deepMapEquals(ImmutableMapFlatDelegate? other) =>
      (other != null) &&
      const MapEquality<Object?, Object?>().equals(_map, other._map);

  int deepMapHashcode() => const MapEquality<Object?, Object?>().hash(_map);
}

/// The [_m] already contains the [_key]. But the [_value] should be the new one.
class ImmutableMapReplaceDelegate<K extends Object?, V extends Object?>
    extends ImmutableMapDelegate<K, V> {
  final ImmutableMapDelegate<K, V> _m;
  final K _key;
  final V _value;

  ImmutableMapReplaceDelegate(this._m, this._key, this._value);

  @override
  bool get isEmpty => false;

  @override
  Iterable<MapEntry<K, V>> get entries => _m.entries.map(
    (entry) => (entry.key == _key) ? MapEntry(_key, _value) : entry,
  );

  @override
  Iterable<K> get keys => _m.keys;

  @override
  Iterable<V> get values => entries.map((entry) => entry.value);

  /// This may be used to help avoid stack-overflow.
  @protected
  @override
  Object? getVOrM(K key) => (key == _key) ? _value : _m;

  /// Used by tail-call-optimisation.
  /// Returns type [bool] or [ImmutableMapDelegate].
  @protected
  @override
  Object containsKeyOrM(K? key) => (key == _key) ? true : _m;

  /// Implicitly uniting the maps.
  @override
  V? operator [](K key) {
    // This is the tail-call-optimisation for:
    // `V? operator [](K key) => (key == _key) ? _value : _m[key];`
    if ((key == _key)) {
      return _value;
    } else {
      Object? vOrM = _m;
      while (vOrM is ImmutableMapDelegate) {
        vOrM = vOrM.getVOrM(key);
      }
      return vOrM as V?;
    }
  }

  @override
  bool containsKey(K? key) {
    // This is the tail-call-optimisation for:
    // `bool containsKey(K? key) => (key == _key) || _m.containsKey(key);`
    if ((key == _key))
      return true;
    else {
      Object vOrM = _m;
      while (vOrM is ImmutableMapDelegate) {
        vOrM = vOrM.containsKeyOrM(key);
        if (vOrM is bool) return vOrM;
      }
      return vOrM as bool;
    }
  }

  @override
  bool contains(K key, V value) =>
      (key == _key) //
      ? value == _value
      : _m.contains(key, value);

  @override
  bool containsValue(V? value) => entries.any((entry) => entry.value == value);

  @override
  int get length => _m.length;

  @override
  Iterator<MapEntry<K, V>> get iterator => entries.iterator;
}
