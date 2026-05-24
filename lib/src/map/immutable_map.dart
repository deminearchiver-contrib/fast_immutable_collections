// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

part 'immutable_map_delegate.dart';
part 'immutable_map_literal.dart';

/// An **immutable**, **unordered** map.
@immutable
abstract class ImmutableMap<K extends Object?, V extends Object?>
    extends ImmutableCollection<ImmutableMap<K, V>> {
  const ImmutableMap._();

  /// Create an [ImmutableMap] from a [Map].
  factory ImmutableMap([Map<K, V>? map]) => //
      ImmutableMap.withConfig(map, defaultConfig);

  /// Create an empty [ImmutableMap].
  /// Use it with const: `const IMap.empty()` (It's always an [ImmutableMapEmpty]).
  @literal
  const factory ImmutableMap.empty() = ImmutableMapEmpty<K, V>._;

  /// Create an [ImmutableMap] from a [Map] and a [ImmutableMapConfig].
  factory ImmutableMap.withConfig(Map<K, V>? map, ImmutableMapConfig config) {
    return (map == null || map.isEmpty)
        ? ImmutableMapImplementation.empty<K, V>(config)
        : ImmutableMapImplementation<K, V>._unsafe(
            ImmutableMapFlatDelegate<K, V>(map, config: config),
            config: config,
          );
  }

  ImmutableMapConfig get config;

  ImmutableMapDelegate<K, V> get _delegate;

  set _delegate(ImmutableMapDelegate<K, V> value) {}

  int get _counter;

  set _counter(int value) {}

  int? get _hashCode;

  set _hashCode(int? value);

  Map<Object, Object?>? get _cache;

  set _cache(Map<Object, Object?>? value);

  /// Returns a cached value derived from this map, computing it on first access.
  ///
  /// Since [ImmutableMap] is immutable, any value derived from its contents is stable and
  /// can be safely cached. Use a [CacheKey] to define the computation and retrieve
  /// the cached result.
  ///
  /// The [CacheKey] should be a `static final` or top-level variable so that the
  /// same object is reused across calls. Creating a new [CacheKey] on each call
  /// defeats caching.
  ///
  /// Example:
  ///
  /// ```dart
  /// class SettingsState {
  ///   final IMap<String, Setting> settings;
  ///
  ///   static final _byCategory = CacheKey<IMap<String, Setting>, Map<Category, List<Setting>>>(
  ///     (map) {
  ///       final result = <Category, List<Setting>>{};
  ///       for (var entry in map.entries) {
  ///         (result[entry.value.category] ??= []).add(entry.value);
  ///       }
  ///       return result;
  ///     },
  ///   );
  ///
  ///   List<Setting> findByCategory(Category cat) => settings.cached(_byCategory)[cat] ?? [];
  /// }
  /// ```
  ///
  /// Note: Caching is supported only in regular [ImmutableMap] instances. Constant maps
  /// created with `const IMap.empty()` or `const IMapConst(...)` will compute
  /// the value each time without caching, since they cannot hold mutable state.
  ///
  R cached<R>(CacheKey<ImmutableMap<K, V>, R> key) {
    _cache ??= {};
    final cache = _cache;
    if (cache == null) return key.computeFrom(this);
    if (cache.containsKey(key)) return cache[key] as R;
    final result = key.computeFrom(this);
    cache[key] = result;
    return result;
  }

  @override
  int get hashCode {
    if (_hashCode != null) return _hashCode!;

    final hashCode =
        isDeepEquals //
        ? Object.hash(
            (flush._delegate as ImmutableMapFlatDelegate<K, V>)
                .deepMapHashcode(),
            config.hashCode,
          )
        : Object.hash(identityHashCode(_delegate), config.hashCode);

    if (config.cacheHashCode) _hashCode = hashCode;

    return hashCode;
  }

  /// Creates a new map with the given [config].
  ///
  /// To copy the config from another [ImmutableMap]:
  ///
  /// ```dart
  /// map = map.withConfig(other.config)
  /// ```
  ///
  /// To change the current config:
  ///
  /// ```dart
  /// map = map.withConfig(map.config.copyWith(isDeepEquals: isDeepEquals))
  /// ```
  ///
  /// See also: [withIdentityEquals] and [withDeepEquals].
  ///
  @useResult
  ImmutableMap<K, V> withConfig(ImmutableMapConfig config) {
    if (config == this.config) {
      return this;
    } else {
      // If the new config is not sorted it can use sorted or not sorted.
      // If the new config is sorted it can only use sorted.
      if (!config.sort || this.config.sort) {
        return ImmutableMap._unsafe(_delegate, config: config);
      } else {
        return ImmutableMap._unsafe(
          ImmutableMapFlatDelegate.from(_delegate, config: config),
          config: config,
        );
      }
    }
  }

  /// Returns a new map with the contents of the present [ImmutableMap],
  /// but the config of [other].
  @useResult
  ImmutableMap<K, V> withConfigFrom(ImmutableMap<K, V> other) =>
      withConfig(other.config);

  /// Create an [ImmutableMap] from an [Iterable] of [MapEntry].
  /// If multiple [entries] have the same [key],
  /// later occurrences overwrite the earlier ones.
  ///
  factory ImmutableMap.fromEntries(
    Iterable<MapEntry<K, V>> entries, {
    ImmutableMapConfig? config,
  }) {
    config ??= defaultConfig;
    final Map<K, V> map = ListMap.fromEntries(entries, sort: config.sort);
    return ImmutableMapImplementation._(map, config: config);
  }

  /// Create an [ImmutableMap] from the given [keys].
  /// The [values] will be the result of applying [valueMapper] to the [keys].
  /// If a [key] repeats, later occurrences overwrite the earlier ones.
  ///
  /// ```dart
  /// // Results in {"Jim": 3, "David": 5}
  /// IMap<String, int> imap = IMap.fromKeys(
  ///     ["Jim", "David"], (String name) => name.length);
  /// ```
  factory ImmutableMap.fromKeys({
    required Iterable<K> keys,
    required V Function(K) valueMapper,
    ImmutableMapConfig? config,
  }) {
    config ??= defaultConfig;

    final Map<K, V> map = ListMap.fromEntries(
      keys.map((key) => MapEntry(key, valueMapper(key))),
      sort: config.sort,
    );

    return ImmutableMapImplementation._(map, config: config);
  }

  /// Create an [ImmutableMap] from the given [values].
  /// The [keys] will be the result of applying [keyMapper] to the [values].
  /// If a [key] repeats, later occurrences overwrite the earlier ones.
  ///
  /// ```dart
  /// // Results in {3: "Jim", 5: "David"}
  /// IMap<int, String> imap = IMap.fromValues(
  ///     (String name) => name.length, ["Jim", "David"]);
  /// ```
  factory ImmutableMap.fromValues({
    required K Function(V) keyMapper,
    required Iterable<V> values,
    ImmutableMapConfig? config,
  }) {
    config ??= defaultConfig;

    final Map<K, V> map = ListMap.fromEntries(
      values.map((value) => MapEntry(keyMapper(value), value)),
      sort: config.sort,
    );

    return ImmutableMapImplementation._(map, config: config);
  }

  /// Creates an IMap instance in which the [keys] and [values] are computed
  /// from the [iterable].
  ///
  /// For each element of the [iterable] it computes a key/value pair,
  /// by applying [keyMapper] and [valueMapper] respectively.
  ///
  /// The example below creates a new [Map] from a [List]. The keys of `map` are
  /// `list` values converted to strings, and the values of the `map` are the
  /// squares of the `list` values:
  ///
  /// ```dart
  /// List<int> list = [1, 2, 3];
  /// IMap<String, int> map = IMap.fromIterable(
  ///   list,
  ///   keyMapper: (item) => item.toString(),
  ///   valueMapper: (item) => item * item),
  /// );
  /// // The code above will yield:
  /// // {
  /// //   "1": 1,
  /// //   "2": 4,
  /// //   "3": 9,
  /// // }
  /// ```
  ///
  /// If no values are specified for [keyMapper] and [valueMapper],
  /// the default is the identity function.
  ///
  /// The keys computed by the source [iterable] do not need to be unique. The
  /// last occurrence of a key will simply overwrite any previous value.
  ///
  /// See also: [IMap.fromIterables]
  ///
  @useResult
  static ImmutableMap<K, V> fromIterable<K, V, I>(
    Iterable<I> iterable, {
    K Function(I)? keyMapper,
    V Function(I)? valueMapper,
    ImmutableMapConfig? config,
  }) {
    config ??= defaultConfig;
    keyMapper ??= (i) => i as K;
    valueMapper ??= (i) => i as V;

    final Map<K, V> map = ListMap.fromEntries(
      iterable.map((item) => MapEntry(keyMapper!(item), valueMapper!(item))),
      sort: config.sort,
    );

    return ImmutableMapImplementation._(map, config: config);
  }

  /// Creates an IMap instance associating the given [keys] to [values].
  ///
  /// This constructor iterates over [keys] and [values] and maps each element of
  /// [keys] to the corresponding element of [values].
  ///
  ///     List<String> letters = ['b', 'c'];
  ///     List<String> words = ['bad', 'cat'];
  ///     IMap<String, String> map = IMap.fromIterables(letters, words);
  ///     map['b'] + map['c'];  // badcat
  ///
  /// If [keys] contains the same object multiple times, the last occurrence
  /// overwrites the previous value.
  ///
  /// The two [Iterable]s must have the same length.
  ///
  /// See also: [fromIterable]
  ///
  factory ImmutableMap.fromIterables(
    Iterable<K> keys,
    Iterable<V> values, {
    ImmutableMapConfig? config,
  }) {
    final Map<K, V> map = ListMap.fromIterables(
      keys,
      values,
      sort: (config ?? defaultConfig).sort,
    );
    return ImmutableMapImplementation._(map, config: config ?? defaultConfig);
  }

  /// **Unsafe constructor**. Use this at your own peril.
  ///
  /// This constructor is fast, since it makes no defensive copies of the map.
  /// However, you should only use this with a new map you've created yourself,
  /// when you are sure no external copies exist. If the original map is modified,
  /// it will break the [ImmutableMap] and any other derived maps in unpredictable ways.
  ///
  /// Also, if [config] is [ImmutableMapConfig.sort] `true`, it assumes you will pass it a
  /// sorted mao. It will not sort the map for you. In this case, if [map] is not
  /// sorted, it will break the [ImmutableMap] and any other derived sets in unpredictable
  /// ways.
  ///
  factory ImmutableMap.unsafe(
    Map<K, V>? map, {
    required ImmutableMapConfig config,
  }) => ImmutableMapImplementation.unsafe(map, config: config);

  /// If [Map] is `null`, return `null`.
  ///
  /// Otherwise, create an [ImmutableMap] from the [Map].
  ///
  /// This static factory is useful for implementing a `copyWith` method
  /// that accepts maps. For example:
  ///
  /// ```dart
  /// IMap<Id, String> studentsPerId;
  ///
  /// Students copyWith({Map<Id, String>? studentsPerId}) =>
  ///   Students(studentsPerId: IMap.orNull(studentsPerId) ?? this.studentsPerId);
  /// ```
  ///
  /// Of course, if your `copyWith` accepts an [ImmutableMap], this is not necessary:
  ///
  /// ```dart
  /// IMap<Id, String> studentsPerId;
  ///
  /// Students copyWith({IMap<Id, String>? studentsPerId}) =>
  ///   Students(studentsPerId: studentsPerId ?? this.studentsPerId);
  /// ```
  ///
  @useResult
  static ImmutableMap<K, V>? orNull<K, V>(
    Map<K, V>? map, [
    ImmutableMapConfig? config,
  ]) => (map == null)
      ? null
      : ImmutableMap.withConfig(map, config ?? defaultConfig);

  /// Converts from JSon. Json serialization support for json_serializable with @JsonSerializable.
  factory ImmutableMap.fromJson(
    Map<String, Object?> json,
    K Function(Object?) fromJsonK,
    V Function(Object?) fromJsonV,
  ) => json
      .map<K, V>(
        (key, value) =>
            MapEntry(fromJsonK(_safeKeyFromJson<K>(key)), fromJsonV(value)),
      )
      .lockUnsafe();

  /// Converts to JSon. Json serialization support for json_serializable with @JsonSerializable.
  Object toJson(Object? Function(K) toJsonK, Object? Function(V) toJsonV) =>
      unlock().map(
        (key, value) => MapEntry(_safeKeyToJson(toJsonK(key)), toJsonV(value)),
      );

  /// See also: [ImmutableCollection], [ImmutableCollection.lockConfig],
  /// [ImmutableCollection.isConfigLocked],[flushFactor], [defaultConfig]
  static void resetAllConfigurations() {
    if (ImmutableCollection.isConfigLocked) {
      throw StateError(
        "Can't change the configuration of immutable collections.",
      );
    }
    ImmutableMap.flushFactor = _defaultFlushFactor;
    ImmutableMap.defaultConfig = _defaultConfig;
  }

  /// Global configuration that specifies if, by default, the [ImmutableMap]s
  /// use equality or identity for their [operator ==].
  /// By default `isDeepEquals: true` (maps are compared by equality),
  /// and `sortKeys: true` and `sortValues: true` (certain map outputs are sorted).
  static ImmutableMapConfig get defaultConfig => _defaultConfig;

  /// Indicates the number of operations an [ImmutableMap] may perform
  /// before it is eligible for auto-flush. Must be larger than `0`.
  static int get flushFactor => _flushFactor;

  /// See also: [ImmutableListConfig], [ImmutableCollection], [resetAllConfigurations]
  static set defaultConfig(ImmutableMapConfig config) {
    if (_defaultConfig == config) return;
    if (ImmutableCollection.isConfigLocked) {
      throw StateError(
        "Can't change the configuration of immutable collections.",
      );
    }
    _defaultConfig = config;
  }

  /// See also: [ImmutableCollection]
  static set flushFactor(int value) {
    if (_flushFactor == value) return;
    if (ImmutableCollection.isConfigLocked) {
      throw StateError(
        "Can't change the configuration of immutable collections.",
      );
    }
    if (value > 0) {
      _flushFactor = value;
    } else {
      throw StateError("flushFactor can't be $value.");
    }
  }

  static ImmutableMapConfig _defaultConfig = const ImmutableMapConfig();

  static const _defaultFlushFactor = 50;

  static int _flushFactor = _defaultFlushFactor;

  /// ## Auto-flush
  ///
  /// Keeps a counter variable which starts at `0` and is incremented each
  /// time collection methods are used. As soon as counter reaches the
  /// refresh-factor, the collection is flushed and `counter` returns to `0`.
  ///
  /// Note: [_count] is called in all methods that change, and some that read.
  /// It's not called in methods which create new [ILists] or flush the list.
  void _count() {
    if (!ImmutableCollection.autoFlush) return;

    if (isFlushed) {
      _counter = 0;
    } else {
      _counter++;
      if (_counter >= _flushFactor) {
        flush;
        _counter = 0;
      }
    }
  }

  /// **Unsafe**. Note: Does not sort.
  factory ImmutableMap._unsafe(
    ImmutableMapDelegate<K, V> delegate, {
    required ImmutableMapConfig config,
  }) => ImmutableMapImplementation._unsafe(delegate, config: config);

  /// **Unsafe**.
  factory ImmutableMap._unsafeFromMap(
    Map<K, V> map, {
    required ImmutableMapConfig config,
  }) => ImmutableMapImplementation._unsafeFromMap(map, config: config);

  /// Creates a map with `identityEquals` (compares the internals by `identity`).
  @useResult
  ImmutableMap<K, V> get withIdentityEquals => config.isDeepEquals
      ? ImmutableMap._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: false),
        )
      : this;

  /// Creates a map with `deepEquals` (compares all map entries by equality).
  @useResult
  ImmutableMap<K, V> get withDeepEquals => config.isDeepEquals
      ? this
      : ImmutableMap._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: true),
        );

  /// See also: [ImmutableListConfig]
  bool get isDeepEquals => config.isDeepEquals;

  /// See also: [ImmutableListConfig]
  bool get isIdentityEquals => !config.isDeepEquals;

  /// Returns an [Iterable] of the map entries of type [MapEntry].
  Iterable<MapEntry<K, V>> get entries => _delegate.entries;

  /// Return the [MapEntry] for the given [key].
  /// For key/value pairs that don't exist, it will return `MapEntry(key, null);`.
  MapEntry<K, V?> entry(K key) => MapEntry(key, _delegate[key]);

  /// Return the [MapEntry] for the given [key].
  /// For key/value pairs that don't exist, it will return null.
  MapEntry<K, V>? entryOrNull(K key) =>
      // ignore: null_check_on_nullable_type_parameter
      _delegate.containsKey(key) ? MapEntry(key, _delegate[key]!) : null;

  /// Returns an [Iterable] of the map entries of type [Entry]. Contrary to
  /// [MapEntry], [Entry] is comparable and implements equals (`==`) and [hashcode] by
  /// using its key and value.
  Iterable<Entry<K, V>> get comparableEntries =>
      _delegate.entries.map((e) => e.asComparableEntry);

  /// Returns an [Iterable] of the map keys.
  Iterable<K> get keys => _delegate.keys;

  /// Returns an [Iterable] of the map values, in the same order as the keys.
  /// If you need to sort the values, please use [valuesToImmutableList].
  Iterable<V> get values => _delegate.values;

  /// Returns an [ImmutableList] of the map entries.
  ///
  /// Optionally, you may provide a [config] for the list.
  ///
  /// The list will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  ImmutableList<MapEntry<K, V>> entriesToImmutableList({
    int Function(MapEntry<K, V>? a, MapEntry<K, V>? b)? compare,
    ImmutableListConfig? config,
  }) {
    var result = ImmutableList<MapEntry<K, V>>.withConfig(
      entries,
      config ?? ImmutableList.defaultConfig,
    );
    if (compare != null || this.config.sort) result = result.sort(compare);
    return result;
  }

  /// Returns an [ImmutableList] of the map keys.
  ///
  /// Optionally, you may provide a [config] for the list.
  ///
  /// The list will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  ImmutableList<K> keysToImmutableList({
    int Function(K? a, K? b)? compare,
    ImmutableListConfig? config,
  }) {
    var result = ImmutableList.withConfig(
      keys,
      config ?? ImmutableList.defaultConfig,
    );
    if (compare != null || this.config.sort) result = result.sort(compare);
    return result;
  }

  /// Returns an [ImmutableList] of the map values.
  ///
  /// Optionally, you may provide a [config] for the list.
  ///
  /// If [sort] is true, then the list will be sorted with [compare], if
  /// provided, or with [compareObject] if not provided. If [sort] is
  /// false, [compare] will be ignored.
  ///
  ImmutableList<V> valuesToImmutableList({
    bool sort = false,
    int Function(V a, V b)? compare,
    ImmutableListConfig? config,
  }) {
    assert(compare == null || sort);

    var result = ImmutableList.withConfig(
      values,
      config ?? ImmutableList.defaultConfig,
    );
    if (sort) result = result.sort(compare ?? compareObject);
    return result;
  }

  /// Returns an [ImmutableSet] of the map entries.
  /// Optionally, you may provide a [config] for the set.
  ImmutableSet<MapEntry<K, V>> entriesToImmutableSet({
    ImmutableSetConfig? config,
  }) => ImmutableSet.withConfig(entries, config ?? ImmutableSet.defaultConfig);

  /// Returns an [ImmutableSet] of the map keys.
  /// Optionally, you may provide a [config] for the set.
  ImmutableSet<K> keysToImmutableSet({ImmutableSetConfig? config}) {
    return ImmutableSet.withConfig(keys, config ?? ImmutableSet.defaultConfig);
  }

  /// Returns an [ImmutableSet] of the map values.
  /// Optionally, you may provide a [config] for the set.
  ImmutableSet<V> valuesToImmutableSet({ImmutableSetConfig? config}) {
    return ImmutableSet.withConfig(
      values,
      config ?? ImmutableSet.defaultConfig,
    );
  }

  /// Returns a [List] of the map entries.
  ///
  /// The list will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  List<MapEntry<K, V>> entriesToList({
    int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare,
  }) {
    final result = List<MapEntry<K, V>>.of(entries);
    if (compare != null || config.sort) result.sort(compare ?? compareObject);
    return result;
  }

  /// Returns a [List] of the map keys.
  ///
  /// The list will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  List<K> keysToList({int Function(K a, K b)? compare}) {
    final result = List.of(keys);
    if (compare != null || config.sort) result.sort(compare);
    return result;
  }

  /// Returns a [List] of the map values.
  ///
  /// If [sort] is true, then the list will be sorted with [compare], if
  /// provided, or with [compareObject] if not provided. If [sort] is
  /// false, [compare] will be ignored.
  ///
  List<V> valuesToList({bool sort = false, int Function(V a, V b)? compare}) {
    assert(compare == null || sort);

    final result = List.of(values);
    if (sort) result.sort(compare ?? compareObject);
    return result;
  }

  /// Returns a [Set] of the map entries.
  /// The set will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  Set<MapEntry<K, V>> entriesToSet({
    int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare,
  }) {
    if (compare == null) {
      return Set<MapEntry<K, V>>.of(entries);
    } else {
      return entriesToList(compare: compare).toSet();
    }
  }

  /// Returns a [Set] of the map keys.
  /// The set will be sorted if the map's [sort] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  Set<K> keysToSet({int Function(K a, K b)? compare}) {
    if (compare == null) {
      return Set<K>.of(keys);
    } else {
      return keysToList(compare: compare).toSet();
    }
  }

  /// Returns a [Set] of the map values.
  /// The set will be sorted if the map's [sortValues] configuration is `true`,
  /// or if you explicitly provide a [compare] method.
  ///
  Set<V> valuesToSet({int Function(V a, V b)? compare}) {
    return valuesToList(compare: compare).toSet();
  }

  /// Returns a new `Iterator` that allows iterating the entries of the [ImmutableMap].
  ///
  /// 1. If the map's [config] has [ImmutableMapConfig.sort] `true` (the default),
  /// it will iterate in the natural order of entries. In other words, if the
  /// keys/values are [Comparable], they will be sorted first by
  /// `keyA.compareTo(keyB)` and then by `valueA.compareTo(valueB)`.
  ///
  /// 2. If the map's [config] has [ImmutableMapConfig.sort] `false`, or if the
  /// keys/values are not [Comparable], the iterator order is by insertion order.
  ///
  Iterator<MapEntry<K, V>> get iterator => _delegate.iterator;

  /// Unlocks the map, returning a regular (mutable, ordered) [Map] of type
  /// [LinkedHashMap]. This map is "safe", in the sense that is independent from
  /// the original [ImmutableMap].
  Map<K, V> unlock() => _delegate.unlock();

  /// Unlocks the map, returning a regular, *mutable, ordered, sorted*, [Map]
  /// of type [LinkedHashMap]. This map is "safe", in the sense that is
  /// independent from the original [ImmutableMap].
  Map<K, V> unlockSorted() => <K, V>{}..addEntries(entriesToImmutableList());

  /// Unlocks the map, returning a safe, unmodifiable (immutable) [Map] view.
  /// The word "view" means the set is backed by the original [ImmutableMap].
  ///
  /// Using this is very fast, since it makes no copies of the [ImmutableMap] entries.
  /// However, if you try to use methods that modify the map, like [add],
  /// it will throw an [UnsupportedError].
  /// It is also very fast to lock this map back into an [ImmutableMap].
  ///
  /// See also: [UnmodifiableMapFromIMap]
  Map<K, V> unlockView() => UnmodifiableMapFromIMap(this);

  /// Unlocks the map, returning a safe, modifiable (mutable) [Map].
  ///
  /// Using this is very fast at first, since it makes no copies of the [ImmutableMap]
  /// entries. However, if and only if you use a method that mutates the map,
  /// like [add], it will unlock internally (make a copy of all [ImmutableMap] entries).
  /// This is transparent to you, and will happen at most only once. In other
  /// words, it will unlock the [ImmutableMap], lazily, only if necessary.
  /// If you never mutate the map, it will be very fast to lock this map
  /// back into an [ImmutableMap].
  ///
  /// See also: [ModifiableMapFromIMap]
  Map<K, V> unlockLazy() => ModifiableMapFromIMap(this);

  /// Returns `true` if there are no elements in this collection.
  @override
  bool get isEmpty => _delegate.isEmpty;

  /// Returns `true` if there is at least one element in this collection.
  @override
  bool get isNotEmpty => !isEmpty;

  /// - If [isDeepEquals] configuration is `true`:
  /// Will return `true` only if the map entries are equal (not necessarily in
  /// the same order), and the map configurations are equal. This may be slow
  /// for very large maps, since it compares each entry, one by one.
  ///
  /// - If [isDeepEquals] configuration is `false`:
  /// Will return `true` only if the maps internals are the same instances
  /// (comparing by identity). This will be fast even for very large maps,
  /// since it doesn't compare each entry.
  ///
  /// Note: This is not the same as `identical(map1, map2)` since it doesn't
  /// compare the maps themselves, but their internal state. Comparing the
  /// internal state is better, because it will return `true` more often.
  ///
  @override
  bool operator ==(Object other) => (other is ImmutableMap) && isDeepEquals
      ? equalItemsAndConfig(other)
      : (other is ImmutableMap<K, V>) && same(other);

  /// Will return `true` only if the [ImmutableMap] entries are equal to the entries in
  /// the [Iterable]. Order is irrelevant. This may be slow for very large maps,
  /// since it compares each entry, one by one. To compare with a map, use
  /// method [equalItemsToMap] or [equalItemsToIMap].
  @override
  bool equalItems(covariant Iterable<MapEntry<Object?, Object?>> other) {
    return (flush._delegate as ImmutableMapFlatDelegate<K, V>)
        .deepMapEqualsToIterable(other);
  }

  /// Will return `true` only if the two maps have the same number of entries, and
  /// if the entries of the two maps are pairwise equal on both key and value.
  bool equalItemsToMap(Map<Object?, Object?> other) =>
      const MapEquality<Object?, Object?>().equals(
        UnmodifiableMapFromIMap<Object?, Object?>(this),
        other,
      );

  /// Will return `true` only if the two maps have the same number of entries, and
  /// if the entries of the two maps are pairwise equal on both key and value.
  bool equalItemsToIMap(ImmutableMap other) {
    if (_isUnequalByHashCode(other)) return false;

    return (flush._delegate as ImmutableMapFlatDelegate).deepMapEquals(
      other.flush._delegate as ImmutableMapFlatDelegate,
    );
  }

  /// Will return `true` only if the list items are equal, and the map configurations are equal.
  /// This may be slow for very large maps, since it compares each item, one by one.
  @override
  bool equalItemsAndConfig(ImmutableMap other) {
    if (identical(this, other)) return true;

    // Objects with different hashCodes are not equal.
    if (_isUnequalByHashCode(other)) return false;

    return config == other.config &&
        (identical(_delegate, other._delegate) ||
            (flush._delegate as ImmutableMapFlatDelegate).deepMapEquals(
              other.flush._delegate as ImmutableMapFlatDelegate,
            ));
  }

  /// Return `true` if other is `null` or the cached [hashCode]s proves the
  /// collections are **NOT** equal.
  ///
  /// **Explanation**: Objects with different [hashCode]s are not equal. However,
  /// if the hashCodes are the same, then nothing can be said about the equality.
  ///
  /// Note: We use the **CACHED** hashCodes. If any of the hashCodes is `null` it
  /// means we don't have this information yet, and we don't calculate it.
  bool _isUnequalByHashCode(ImmutableMap? other) {
    return (other == null) ||
        (_hashCode != null &&
            other._hashCode != null &&
            _hashCode != other._hashCode);
  }

  /// Will return `true` if the maps internals are the same instances
  /// (comparing by identity). This will be fast even for very large maps,
  /// since it doesn't compare each entry.
  ///
  /// It can also return `true` under some other situations where it's very
  /// cheap to determine that the maps are equal even if the maps internals
  /// are NOT the same.
  ///
  /// Note: This is not the same as `identical(map1, map2)` since it doesn't
  /// compare the maps themselves, but their internal state. Comparing the
  /// internal state is better, because it will return `true` more often.
  @override
  bool same(ImmutableMap<K, V> other) =>
      identical(_delegate, other._delegate) && (config == other.config);

  /// Whether this map is already flushed or not.
  @override
  bool get isFlushed => _delegate is ImmutableMapFlatDelegate;

  /// Returns a new map containing the current map plus the given key:value.
  /// (if necessary, the given key:value pair will override the current).
  @useResult
  ImmutableMap<K, V> add(K key, V value) {
    ImmutableMap<K, V> result;
    result = config.sort
        ? ImmutableMap._unsafe(
            ImmutableMapFlatDelegate.fromEntries(
              _delegate.entries.followedBy([MapEntry(key, value)]),
              config: config,
            ),
            config: config,
          )
        : ImmutableMap<K, V>._unsafe(
            _delegate.add(key: key, value: value),
            config: config,
          );

    // A map created with `add` has a larger counter than its source map.
    // This improves the order in which maps are flushed.
    // If the outer map is used, it will be flushed before the source map.
    // If the source map is not used directly, it will not flush unnecessarily,
    // and also may be garbage collected.
    result._counter = _counter;
    result._count();

    return result;
  }

  /// Returns a new map containing the current map plus the given key:value.
  /// (if necessary, the given entry will override the current one).
  @useResult
  ImmutableMap<K, V> addEntry(MapEntry<K, V> entry) =>
      add(entry.key, entry.value);

  /// Returns a new map containing the current map plus the ones in the
  /// given [imap].
  ///
  /// Note: [imap] entries that already exist in the original map will be overwritten
  /// with new values.
  ///
  /// - If [keepOrder] is `false` (the default), those entries that already exist
  /// will be replaced at the end of the new map.
  /// - If [keepOrder] is `true`, the entries which already exist will be replaced
  /// at their current position.
  ///
  /// Note: [keepOrder] only makes sense if your map is **NOT** ordered, that is
  /// `ConfigMap.sort == false`.
  @useResult
  ImmutableMap<K, V> addAll(ImmutableMap<K, V> imap, {bool keepOrder = false}) {
    ImmutableMap<K, V> result;
    result = config.sort
        ? ImmutableMap._unsafe(
            ImmutableMapFlatDelegate.fromEntries(
              _delegate.entries.followedBy(imap.entries),
              config: config,
            ),
            config: config,
          )
        : ImmutableMap<K, V>._unsafe(
            _delegate.addAll(imap, keepOrder: keepOrder),
            config: config,
          );

    // A map created with `addAll` has a larger counter than both its source
    // maps. This improves the order in which maps are flushed.
    // If the outer map is used, it will be flushed before the source maps.
    // If the source maps are not used directly, they will not flush
    // unnecessarily, and also may be garbage collected.
    result._counter = max(_counter, imap._counter);
    result._count();

    return result;
  }

  /// Returns a new map containing the current map plus the given [map] entries.
  /// Note: [map] entries that already exist in the original map will be overwritten
  /// with new values, in place (keeping order).
  @useResult
  ImmutableMap<K, V> addMap(Map<K, V> map) {
    final ImmutableMap<K, V> result = config.sort
        ? ImmutableMap._unsafe(
            ImmutableMapFlatDelegate.fromEntries(
              _delegate.entries.followedBy(map.entries),
              config: config,
            ),
            config: config,
          )
        : ImmutableMap<K, V>._unsafe(_delegate.addMap(map), config: config);

    result._counter = _counter;
    result._count();

    return result;
  }

  /// Returns a new map containing the current map plus the given [entries].
  /// Note: [entries] that already exist in the original map will overwrite
  /// those of the original map, in place (keeping order).
  @useResult
  ImmutableMap<K, V> addEntries(Iterable<MapEntry<K, V>> entries) {
    ImmutableMap<K, V> result;
    result = config.sort
        ? ImmutableMap._unsafe(
            ImmutableMapFlatDelegate.fromEntries(
              _delegate.entries.followedBy(entries),
              config: config,
            ),
            config: config,
          )
        : ImmutableMap<K, V>._unsafe(
            _delegate.addEntries(entries),
            config: config,
          );

    result._counter = _counter;
    result._count();

    return result;
  }

  /// Returns a new map containing the current map minus the given key and its
  /// value. However, if the current map doesn't contain the key, it will
  /// return the current map (same instance).
  @useResult
  ImmutableMap<K, V> remove(K key) {
    final ImmutableMapDelegate<K, V> result = _delegate.remove(key);
    return identical(result, _delegate)
        ? this
        : ImmutableMap<K, V>._unsafe(result, config: config);
  }

  /// Returns a new map containing the current map minus the entries that
  /// satisfy the given [predicate]. However, if nothing is removed, it will
  /// return the current map (same instance).
  @useResult
  ImmutableMap<K, V> removeWhere(bool Function(K key, V value) predicate) {
    final ImmutableMapDelegate<K, V> result = _delegate.removeWhere(predicate);
    return identical(result, _delegate)
        ? this
        : ImmutableMap<K, V>._unsafe(result, config: config);
  }

  /// Returns the value for the given [key] or null if [key] is not in the map.
  V? operator [](K k) {
    _count();
    return _delegate[k];
  }

  /// Returns the value for the given [key] or null if [key] is not in the map.
  V? get(K k) {
    _count();
    return _delegate[k];
  }

  /// Checks whether any key-value pair of this map satisfies [test].
  bool any(bool Function(K key, V value) test) => _delegate.any(test);

  /// Provides a **view** of this map as having [RK] keys and [RV] instances,
  /// if necessary.
  ///
  /// If this map is already an `IMap<RK, RV>`, it is returned unchanged.
  ///
  /// If this map contains only keys of type [RK] and values of type [RV],
  /// all read operations will work correctly.
  /// If any operation exposes a non-[RK] key or non-[RV] value,
  /// the operation will throw instead.
  ///
  /// Entries added to the map must be valid for both an `IMap<K, V>` and an
  /// `IMap<RK, RV>`.
  @useResult
  ImmutableMap<RK, RV> cast<RK, RV>() {
    final Object result = _delegate.cast<RK, RV>(config);
    if (result is ImmutableMapDelegate<RK, RV>) {
      return ImmutableMap._unsafe(result, config: config);
    } else if (result is Map<RK, RV>)
      return ImmutableMapImplementation._(result, config: config);
    else
      throw AssertionError(result.runtimeType);
  }

  /// Checks whether any entry of this iterable satisfies [test].
  bool anyEntry(bool Function(MapEntry<K, V>) test) => _delegate.anyEntry(test);

  /// Checks whether every entry of this iterable satisfies [test].
  bool everyEntry(bool Function(MapEntry<K, V>) test) =>
      _delegate.everyEntry(test);

  /// Returns `true` if the map contains an element equal to the [key]-[value] pair, `false`
  /// otherwise.
  bool contains(K key, V value) {
    _count();
    return _delegate.contains(key, value);
  }

  /// Returns `true` if the map contains the [key], `false` otherwise.
  bool containsKey(K? key) {
    _count();
    return _delegate.containsKey(key);
  }

  /// Returns `true` if the map contains the [value], `false` otherwise.
  bool containsValue(V? value) {
    _count();
    return _delegate.containsValue(value);
  }

  /// Returns `true` if the map contains the [entry], `false` otherwise.
  bool containsEntry(MapEntry<K, V> entry) =>
      _delegate.contains(entry.key, entry.value);

  /// The number of objects in this list.
  int get length {
    final int length = _delegate.length;

    /// Optimization: Flushes the map, if free.
    if (length == 0 && _delegate is! ImmutableMapFlatDelegate)
      _delegate = ImmutableMapFlatDelegate.empty<K, V>();

    return length;
  }

  /// Applies the function [f] to each element.
  void forEach(void Function(K key, V value) f) {
    _delegate.forEach(f);
  }

  /// Returns an [ImmutableMap] with all elements that satisfy the predicate [test].
  @useResult
  ImmutableMap<K, V> where(bool Function(K key, V value) test) =>
      ImmutableMapImplementation<K, V>._(_delegate.where(test), config: config);

  /// Returns a new map where all entries of this map are transformed by
  /// the given [mapper] function. However, if [ifRemove] is provided,
  /// the mapped value will first be tested with it and, if [ifRemove]
  /// returns true, the value will be removed from the result map.
  ///
  /// See also: [mapTo].
  ///
  @useResult
  ImmutableMap<RK, RV> map<RK, RV>(
    MapEntry<RK, RV> Function(K key, V value) mapper, {
    bool Function(RK key, RV value)? ifRemove,
    ImmutableMapConfig? config,
  }) {
    config ??= defaultConfig;
    final Map<RK, RV> map = ListMap.fromEntries(
      entries
          .map((entry) => mapper(entry.key, entry.value))
          .where(
            (entry) => ifRemove == null || !ifRemove(entry.key, entry.value),
          ),
      sort: config.sort,
    );

    return ImmutableMap._unsafeFromMap(map, config: config);
  }

  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `mapper` on each entry of this `IMap` in
  /// iteration order.
  ///
  /// The returned iterable is lazy, so it won't iterate the elements of
  /// this map until it is itself iterated, and then it will apply
  /// [mapper] to create one element at a time.
  /// The converted elements are not cached.
  /// Iterating multiple times over the returned [Iterable]
  /// will invoke the supplied [mapper] function once per element
  /// for on each iteration.
  ///
  /// Note: While [map] returns a new `IMap`, [mapTo] returns an `Iterable`
  /// of elements created by combining the entries keys and values.
  ///
  Iterable<T> mapTo<T>(T Function(K key, V value) mapper) =>
      entries.map((entry) => mapper(entry.key, entry.value));

  /// Returns a string representation of (some of) the elements of `this`.
  ///
  /// Use either the [prettyPrint] or the [ImmutableCollection.prettyPrint] parameters to get a
  /// prettier print.
  ///
  /// See also: [ImmutableCollection]
  @override
  String toString([bool? prettyPrint]) {
    if ((prettyPrint ?? ImmutableCollection.prettyPrint)) {
      final int length = _delegate.length;
      if (length == 0) {
        return "{}";
      } else if (length == 1) {
        final entry = entries.single;
        return "{${entry.key}: ${entry.value}}";
      } else {
        final Iterable<MapEntry<K, V>> sortedEntries = config.sort
            ? (entries.toList()
                ..sort((e1, e2) => e1.key.compareObjectTo(e2.key)))
            : entries;
        return "{\n   ${sortedEntries.map((entry) => entry.print(prettyPrint)).join(",\n   ")}\n}";
      }
    } else {
      final Iterable<MapEntry<K, V>> sortedEntries = config.sort
          ? (entries.toList()..sort((e1, e2) => e1.key.compareObjectTo(e2.key)))
          : entries;
      return "{${sortedEntries.map((entry) => entry.print(prettyPrint)).join(", ")}}";
    }
  }

  /// Returns an empty map with the same configuration.
  @useResult
  ImmutableMap<K, V> clear() => ImmutableMapImplementation.empty<K, V>(config);

  /// Add a key-value pair to the map, but only if the key is NOT already
  /// present in the map.
  ///
  /// If the [key] is already present, the map remains unchanged and the
  /// existing value is saved in the mutable [previousValue], if provided.
  ///
  /// If the [key] is NOT present, the [ifAbsent] function is called to generate
  /// a new value, which is then added to the map. This new value is also saved
  /// in [previousValue], if provided.
  ///
  /// Finally, the modified map is returned.
  ///
  /// Example:
  /// ```dart
  /// var scores = IMap({"Bob": 36});
  /// Output<int> output = Output();
  ///
  /// scores = scores.putIfAbsent("Bob", () => "Bob".length, previousValue: output);
  /// print(output.value);  // 36
  ///
  /// scores = scores.putIfAbsent("Rohan", () => "Rohan".length, previousValue: output);
  /// print(output.value);  // 5
  ///
  /// scores = scores.putIfAbsent("Sophia", () => "Sophia".length, previousValue: output);
  /// print(output.value);  // 6
  ///
  /// print(scores["Bob"]);     // 36
  /// print(scores["Rohan"]);   //  5
  /// print(scores["Sophia"]);  //  6
  /// ```
  ///
  @useResult
  (ImmutableMap<K, V>, V) putIfAbsent(K key, V Function() ifAbsent) {
    if (containsKey(key)) {
      return (this, this[key] as V);
    } else {
      final calculatedValue = ifAbsent();
      final Map<K, V> map = ListMap.fromEntries(
        entries.followedBy([MapEntry(key, calculatedValue)]),
        sort: config.sort,
      );
      return (
        ImmutableMap._unsafeFromMap(map, config: config),
        calculatedValue,
      );
    }
  }

  /// Updates the value for the provided [key].
  ///
  /// 1. If the key is present:
  ///
  /// Invokes [update] with the current value and stores the new value in the
  /// map. However, if [ifRemove] is provided, the updated value will first
  /// be tested with it and, if [ifRemove] returns true, the value will be
  /// removed from the map, instead of updated. Note: If [update] returns
  /// the same INSTANCE as the current value, the original map instance will
  /// be returned, unchanged.
  ///
  /// 2. If the key is NOT present:
  ///
  /// If [ifAbsent] is provided, calls [ifAbsent] and adds the key with the
  /// returned value to the map. If the key is not present and [ifAbsent] is
  /// not provided, return the original map instance, without modification.
  /// Note: If you want [ifAbsent] to throw an error, pass it like
  /// this: `ifAbsent: () => throw ArgumentError();`.
  ///
  /// If you want to get the original value before the update/removal,
  /// you can provide the mutable [previousValue] parameter, which is
  /// of type [Output].
  ///
  @useResult
  (ImmutableMap<K, V>, V?) update(
    K key,
    V Function(V value) update, {
    bool Function(K key, V value)? ifRemove,
    V Function()? ifAbsent,
  }) {
    if (containsKey(key)) {
      final map = unlock();
      final originalValue = map[key] as V;
      final updatedValue = update(originalValue);
      if (ifRemove != null && ifRemove(key, updatedValue)) {
        map.remove(key);
        return (
          ImmutableMap._unsafeFromMap(map, config: config),
          originalValue,
        );
      } else {
        map[key] = updatedValue;
        return (
          identical(updatedValue, originalValue)
              ? this
              : ImmutableMap._unsafeFromMap(map, config: config),
          originalValue,
        );
      }
    } else {
      if (ifAbsent != null) {
        final updatedValue = ifAbsent();
        final Map<K, V> map = ListMap.fromEntries(
          entries.followedBy([MapEntry(key, updatedValue)]),
          sort: config.sort,
        );
        return (ImmutableMap._unsafeFromMap(map, config: config), null);
      } else {
        return (this, null);
      }
    }
  }

  /// Updates all values.
  ///
  /// Iterates over all entries in the map and updates them with the result
  /// of invoking [update].
  @useResult
  ImmutableMap<K, V> updateAll(
    V Function(K key, V value) update, {
    bool Function(K key, V value)? ifRemove,
  }) {
    final map = unlock()..updateAll(update);
    if (ifRemove != null) map.removeWhere(ifRemove);
    return ImmutableMap._unsafeFromMap(map, config: config);
  }
}

@visibleForTesting
@immutable
// ignore: must_be_immutable
final class ImmutableMapImplementation<K extends Object?, V extends Object?>
    extends ImmutableMap<K, V> {
  //
  /// The map configuration ([ImmutableMapConfig]).
  @override
  final ImmutableMapConfig config;

  @override
  final ImmutableMapDelegate<K, V> _delegate;

  @override
  int _counter = 0;

  @override
  // HashCode cache. Must be null if hashCode is not cached.
  // ignore: use_late_for_private_fields_and_variables
  int? _hashCode;

  @override
  // ignore: use_late_for_private_fields_and_variables
  Map<Object, Object?>? _cache;

  /// Flushes the map, if necessary. Chainable method.
  /// If the map is already flushed, doesn't do anything.
  @override
  ImmutableMap<K, V> get flush {
    if (!isFlushed) {
      // Flushes the original _m because maybe it's used elsewhere.
      // Or maybe it was flushed already, and we can use it as is.
      _delegate = ImmutableMapFlatDelegate<K, V>.unsafe(
        _delegate.getFlushed(config),
      );
      _counter = 0;
    }
    return this;
  }

  ImmutableMapImplementation.unsafe(Map<K, V>? map, {required this.config})
    : _delegate = (map == null)
          ? ImmutableMapFlatDelegate.empty<K, V>()
          : ImmutableMapFlatDelegate<K, V>.unsafe(map),
      super._() {
    if (ImmutableCollection.disallowUnsafeConstructors) {
      throw UnsupportedError("IMap.unsafe is disallowed.");
    }
  }

  /// **Unsafe**. Note: Does not sort.
  ImmutableMapImplementation._unsafe(this._delegate, {required this.config})
    : super._();

  /// **Unsafe**.
  ImmutableMapImplementation._unsafeFromMap(
    Map<K, V> map, {
    required this.config,
  }) : _delegate = ImmutableMapFlatDelegate<K, V>.unsafe(map),
       super._();

  /// Returns an empty [ImmutableMap], with the given configuration. If a
  /// configuration is not provided, it will use the default configuration.
  ///
  /// Note: If you want to create an empty immutable collection of the same
  /// type and same configuration as a source collection, simply call [clear]
  /// in the source collection.
  static ImmutableMapImplementation<K, V> empty<K, V>([
    ImmutableMapConfig? config,
  ]) => ImmutableMapImplementation._unsafe(
    ImmutableMapFlatDelegate.empty<K, V>(),
    config: config ?? ImmutableMap.defaultConfig,
  );

  /// **Unsafe**. Note: Does not sort, so the map should already respect config.
  ImmutableMapImplementation._(Map<K, V> map, {required this.config})
    : _delegate = ImmutableMapFlatDelegate<K, V>.unsafe(map),
      super._();
}

/// **Don't use this class**.
@visibleForTesting
extension type const ImmutableMapInternals<
  K extends Object?,
  V extends Object?
>(ImmutableMap<K, V> _) implements ImmutableMap<K, V> {
  ImmutableMapDelegate<K, V> get delegate => _._delegate;

  /// To access the private counter, add this to the test file:
  ///
  /// ```dart
  /// extension TestExtension on IMap {
  ///   int get counter => InternalsForTestingPurposesIMap(this).counter;
  /// }
  /// ```
  int get counter => _._counter;
}

String _safeKeyToJson<NewK extends Object?>(NewK key) {
  if (key == null) {
    return 'null';
  }
  //
  else if (key is String) {
    return key;
  }
  //
  else if (key is num ||
      key is bool ||
      key is DateTime ||
      key is BigInt ||
      key is Uri) {
    return key.toString();
  }
  //
  else if (key is Enum) {
    return key.name;
  }
  //
  else
    throw Exception(
      'IMap key $key of type ${key.runtimeType} not serializable to/from json',
    );
}

NewK _safeKeyFromJson<NewK extends Object?>(String key) {
  if (key == 'null') {
    return null as NewK;
  }
  if (_dummyBool is NewK) {
    return (key == 'true') as NewK;
  }
  if (_dummyDouble is NewK) {
    return double.parse(key) as NewK;
  }
  if (_dummyInt is NewK) {
    return int.parse(key) as NewK;
  }
  if (_dummyBigInt is NewK) {
    return BigInt.parse(key) as NewK;
  }
  if (_dummyDate is NewK) {
    return DateTime.parse(key) as NewK;
  }
  if (_dummyUri is NewK) {
    return Uri.parse(key) as NewK;
  }
  if (_dummyString is NewK) {
    return key as NewK;
  }
  try {
    return key as NewK;
  } catch (error) {
    throw UnsupportedError(
      "JSON deserialization of IMap keys "
      "of type $NewK are not supported at the moment.",
    );
  }
}

const _dummyInt = 1;
const _dummyDouble = 1.0;
const _dummyString = '';
const _dummyBool = true;
final _dummyUri = Uri.parse('https://www.google.com');
final _dummyDate = DateTime.now();
final _dummyBigInt = BigInt.from(1);
