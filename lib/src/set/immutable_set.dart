// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

part 'immutable_set_delegate.dart';
part 'immutable_set_literal.dart';

/// An **immutable**, **ordered** set.
/// It can be configured to order by insertion order, or sort.
///
/// You can access its items by index, as efficiently as with a [List],
/// by calling `ISet.elementAt(index)` or by using the `[]` operator.

@immutable
abstract class ImmutableSet<T extends Object?>
    extends ImmutableCollection<ImmutableSet<T>>
    implements Iterable<T> {
  const ImmutableSet._();

  /// Create an [ImmutableSet] from an [iterable], with the default configuration.
  /// Fast, if the iterable is another [ImmutableSet].
  ///
  /// To create an empty [ImmutableSet] with the default configuration, just omit
  /// the iterable: `ISet()`.
  ///
  /// Note: To create an [ImmutableSet] with a specific configuration, use the `ISet.withConfig()`
  /// constructor.
  ///
  /// Note: If you want to create an empty [ImmutableSet] of the same configuration as a
  /// source [ImmutableSet], simply call [clear] on the source [ImmutableSet].
  ///
  factory ImmutableSet([Iterable<T>? iterable]) =>
      .withConfig(iterable, defaultConfig);

  /// Create an empty [ImmutableSet].
  /// Use it with const: `const ISet.empty()` (It's always an [ImmutableSetEmpty]).
  @literal
  const factory ImmutableSet.empty() = ImmutableSetEmpty<T>._;

  @literal
  const factory ImmutableSet.literal(Set<T> set, {ImmutableSetConfig config}) =
      ImmutableSetLiteral<T>._;

  /// The set configuration.
  ImmutableSetConfig get config;

  ImmutableSetDelegate<T> get _delegate;

  set _delegate(ImmutableSetDelegate<T> value) {}

  int get _counter;

  set _counter(int value) {}

  int? get _hashCode;

  set _hashCode(int? value);

  Map<Object, Object?>? get _cache;

  set _cache(Map<Object, Object?>? value);

  /// Returns a cached value derived from this set, computing it on first access.
  ///
  /// Since [ImmutableSet] is immutable, any value derived from its contents is stable and
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
  /// class TagState {
  ///   final ISet<Tag> tags;
  ///
  ///   static final _byName = CacheKey<ISet<Tag>, Map<String, Tag>>(
  ///     (set) => {for (var t in set) t.name: t},
  ///   );
  ///
  ///   Tag? findByName(String name) => tags.cached(_byName)[name];
  /// }
  /// ```
  ///
  /// Note: Caching is supported only in regular [ImmutableSet] instances. Constant sets
  /// created with `const ISet.empty()` or `const ISetConst(...)` will compute
  /// the value each time without caching, since they cannot hold mutable state.
  ///
  R cached<R>(CacheKey<ImmutableSet<T>, R> key) {
    _cache ??= {};
    final cache = _cache;
    if (cache == null) return key.computeFrom(this);
    if (cache.containsKey(key)) return cache[key] as R;
    final result = key.computeFrom(this);
    cache[key] = result;
    return result;
  }

  /// Create an [ImmutableSet] from any [Iterable] and a [ImmutableSetConfig].
  /// Fast, if the Iterable is another [ImmutableSet].
  /// If [iterable] is null, return an empty [ImmutableSet].
  factory ImmutableSet.withConfig(
    Iterable<T>? iterable,
    ImmutableSetConfig config,
  ) {
    return ((iterable is ImmutableSet<T>) &&
            (iterable.isOfExactGenericType<T>()))
        ? (config == iterable.config)
              ? iterable
              : iterable.isEmpty
              ? ImmutableSetImplementation<T>.empty(config)
              : ImmutableSetImplementation<T>._(iterable, config: config)
        : (iterable == null)
        ? ImmutableSetImplementation<T>.empty(config)
        : ImmutableSetImplementation<T>._unsafe(
            ImmutableSetFlatDelegate<T>(iterable, config: config),
            config: config,
          );
  }

  /// Creates a new set with the given [config].
  ///
  /// To copy the config from another [ImmutableSet]:
  ///
  /// ```dart
  /// set = set.withConfig(other.config)
  /// ```
  ///
  /// To change the current config:
  ///
  /// ```dart
  /// set = set.withConfig(set.config.copyWith(isDeepEquals: isDeepEquals))
  /// ```
  ///
  /// See also: [withIdentityEquals] and [withDeepEquals].
  ///
  @useResult
  ImmutableSet<T> withConfig(ImmutableSetConfig config) {
    if (config == this.config) {
      return this;
    } else {
      // If the new config is not sorted it can use sorted or not sorted.
      // If the new config is sorted it can only use sorted.
      if (!config.sort || this.config.sort) {
        return ImmutableSetImplementation._unsafe(_delegate, config: config);
      } else {
        return ImmutableSetImplementation._unsafe(
          ImmutableSetFlatDelegate(_delegate, config: config),
          config: config,
        );
      }
    }
  }

  /// Returns a new set with the contents of the present [ImmutableSet],
  /// but the config of [other].
  @useResult
  ImmutableSet<T> withConfigFrom(ImmutableSet<T> other) =>
      withConfig(other.config);

  /// Creates a set in which the items are computed from the [iterable].
  ///
  /// For each element of the [iterable] it computes another iterable of items
  /// by applying [mapper]. The items of this resulting iterable will be added
  /// to the set.
  ///
  @useResult
  static ImmutableSet<T> fromIterable<T, I>(
    Iterable<I> iterable, {
    required Iterable<T>? Function(I) mapper,
    ImmutableSetConfig? config,
  }) {
    config ??= defaultConfig;
    final result = ListSet.of(
      iterable.expand(mapper as Iterable<T> Function(I)),
      sort: config.sort,
    );
    return ImmutableSetImplementation<T>._unsafeFromSet(result, config: config);
  }

  /// **Unsafe constructor**. Use this at your own peril.
  ///
  /// This constructor is fast, since it makes no defensive copies of the set.
  /// However, you should only use this with a new set you've created yourself,
  /// when you are sure no external copies exist. If the original set is modified,
  /// it will break the [ImmutableSet] and any other derived sets in unpredictable ways.
  ///
  /// Also, if [config] is [ImmutableSetConfig.sort] `true`, it assumes you will pass it a
  /// sorted set. It will not sort the set for you. In this case, if [set] is
  /// not sorted, it will break the [ImmutableSet] and any other derived sets in unpredictable
  /// ways.
  ///
  factory ImmutableSet.unsafe(
    Set<T> set, {
    required ImmutableSetConfig config,
  }) => ImmutableSetImplementation.unsafe(set, config: config);

  /// If [Iterable] is `null`, return `null`.
  ///
  /// Otherwise, create an [ImmutableSet] from the [Iterable].
  /// Fast, if the [Iterable] is another [ImmutableSet].
  ///
  /// This static factory is useful for implementing a `copyWith` method
  /// that accept an [Iterable]. For example:
  ///
  /// ```dart
  /// ISet<String> names;
  ///
  /// Students copyWith({Iterable<String>? names}) =>
  ///   Students(names: ISet.orNull(names) ?? this.names);
  /// ```
  ///
  /// Of course, if your `copyWith` accepts an [ImmutableSet], this is not necessary:
  ///
  /// ```dart
  /// ISet<String> names;
  ///
  /// Students copyWith({ISet<String>? names}) =>
  ///   Students(names: names ?? this.names);
  /// ```
  ///
  @useResult
  static ImmutableSet<T>? orNull<T>(
    Iterable<T>? iterable, [
    ImmutableSetConfig? config,
  ]) => (iterable == null)
      ? null
      : ImmutableSet.withConfig(iterable, config ?? defaultConfig);

  /// Converts from JSon. Json serialization support for json_serializable with @JsonSerializable.
  factory ImmutableSet.fromJson(dynamic json, T Function(Object?) fromJsonT) =>
      ImmutableSet<T>((json as Iterable).map(fromJsonT));

  /// Converts to JSon. Json serialization support for json_serializable with @JsonSerializable.
  Object toJson(Object? Function(T) toJsonT) => map(toJsonT).toList();

  /// See also: [ImmutableCollection], [ImmutableCollection.lockConfig],
  /// [ImmutableCollection.isConfigLocked],[flushFactor], [defaultConfig]
  static void resetAllConfigurations() {
    if (ImmutableCollection.isConfigLocked) {
      throw StateError(
        "Can't change the configuration of immutable collections.",
      );
    }
    ImmutableSet.flushFactor = _defaultFlushFactor;
    ImmutableSet.defaultConfig = _defaultConfig;
  }

  /// Global configuration that specifies if, by default, the [ImmutableSet]s
  /// use equality or identity for their [operator ==].
  ///
  /// By default `isDeepEquals: true` (sets are compared by equality)
  /// and `sort: false` (when `true`, certain outputs are sorted).
  static ImmutableSetConfig get defaultConfig => _defaultConfig;

  /// Indicates the number of operations an [ImmutableSet] may perform
  /// before it is eligible for auto-flush. Must be larger than 0.
  static int get flushFactor => _flushFactor;

  /// See also: [ImmutableListConfig], [ImmutableCollection], [resetAllConfigurations]
  static set defaultConfig(ImmutableSetConfig config) {
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

  static ImmutableSetConfig _defaultConfig = const ImmutableSetConfig();

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
  factory ImmutableSet._unsafe(
    ImmutableSetDelegate<T> delegate, {
    required ImmutableSetConfig config,
  }) => ImmutableSetImplementation._unsafe(delegate, config: config);

  /// **Unsafe**. Note: Does not sort.
  factory ImmutableSet._unsafeFromSet(
    Set<T> set, {
    required ImmutableSetConfig config,
  }) => ImmutableSetImplementation._unsafeFromSet(set, config: config);

  /// Creates a set with `identityEquals` (compares the internals by `identity`).
  @useResult
  ImmutableSet<T> get withIdentityEquals => config.isDeepEquals
      ? ImmutableSet._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: false),
        )
      : this;

  /// Creates a set with `deepEquals` (compares all set items by equality).
  @useResult
  ImmutableSet<T> get withDeepEquals => config.isDeepEquals
      ? this
      : ImmutableSet._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: true),
        );

  /// See also: [ImmutableListConfig]
  bool get isDeepEquals => config.isDeepEquals;

  /// See also: [ImmutableListConfig]
  bool get isIdentityEquals => !config.isDeepEquals;

  /// Unlocks the set, returning a regular (*mutable, ordered*) [Set]
  /// of type [LinkedHashSet]. This set is "safe", in the sense that is independent
  /// from the original [ImmutableSet].
  Set<T> unlock() => _delegate.unlock();

  /// Unlocks the set, returning a safe, unmodifiable (immutable) [Set] view.
  /// The word "view" means the set is backed by the original [ImmutableSet].
  /// Using this is very fast, since it makes no copies of the [ImmutableSet] items.
  /// However, if you try to use methods that modify the set, like [add],
  /// it will throw an [UnsupportedError].
  /// It is also very fast to lock this set back into an [ImmutableSet].
  ///
  /// See also: [UnmodifiableSetFromISet]
  Set<T> unlockView() => UnmodifiableSetFromISet(this);

  /// Unlocks the set, returning a safe, modifiable (mutable) [Set].
  /// Using this is very fast at first, since it makes no copies of the [ImmutableSet]
  /// items. However, if and only if you use a method that mutates the set,
  /// like [add], it will unlock internally (make a copy of all [ImmutableSet] items).
  /// This is transparent to you, and will happen at most only once. In other
  /// words, it will unlock the [ImmutableSet], lazily, only if necessary.
  /// If you never mutate the set, it will be very fast to lock this set
  /// back into an [ImmutableSet].
  ///
  /// See also: [ModifiableSetFromISet]
  Set<T> unlockLazy() => ModifiableSetFromISet(this);

  /// 1. If the set's [config] has [ImmutableSetConfig.sort] `true`, it will iterate in
  /// the natural order of items. In other words, if the items are [Comparable],
  /// they will be sorted by `a.compareTo(b)`.
  /// 2. If the set's [config] has [ImmutableSetConfig.sort] `false` (the default), or
  /// if the items are not [Comparable], the [iterator] order is the insertion order.
  ///
  @override
  Iterator<T> get iterator => _delegate.iterator;

  /// Returns `true` if there are no elements in this collection.
  @override
  bool get isEmpty => _delegate.isEmpty;

  /// Returns `true` if there is at least one element in this collection.
  @override
  bool get isNotEmpty => !isEmpty;

  /// - If [isDeepEquals] configuration is `true`:
  /// Will return `true` only if the set items are equal (and in the same order),
  /// and the set configurations are equal. This may be slow for very
  /// large sets, since it compares each item, one by one.
  ///
  /// - If [isDeepEquals] configuration is `false`:
  /// Will return `true` only if the sets internals are the same instances
  /// (comparing by identity). This will be fast even for very large sets,
  /// since it doesn't  compare each item.
  ///
  /// Note: This is not the same as `identical(set1, set2)` since it doesn't
  /// compare the sets themselves, but their internal state. Comparing the
  /// internal state is better, because it will return true more often.
  ///
  @override
  bool operator ==(Object other) => (other is ImmutableSet) && isDeepEquals
      ? equalItemsAndConfig(other)
      : (other is ImmutableSet<T>) && same(other);

  /// Returns the concatenation of this set and [other].
  /// Returns a new set containing the elements of this set followed by
  /// the elements of [other].
  @useResult
  ImmutableSet<T> operator +(Iterable<T> other) => addAll(other);

  /// Will return `true` only if the [ImmutableSet] has the same number of items as the
  /// iterable, and the [ImmutableSet] items are equal to the iterable items, in whatever
  /// order. This may be slow for very large sets, since it compares each item,
  /// one by one.
  @override
  bool equalItems(covariant Iterable? other) {
    if (other == null) return false;
    if (identical(this, other)) return true;

    if (other is ImmutableSet) {
      if (_isUnequalByHashCode(other)) return false;
      return (flush._delegate as ImmutableSetFlatDelegate).deepSetEquals(
        other.flush._delegate as ImmutableSetFlatDelegate,
      );
    }

    return (flush._delegate as ImmutableSetFlatDelegate<T>)
        .deepSetEqualsToIterable(other);
  }

  /// Will return `true` only if the [ImmutableSet] and the iterable items have the same number of elements,
  /// and the elements of the [ImmutableSet] can be paired with the elements of the iterable, so that each
  /// pair is equal. This may be slow for very large sets, since it compares each item,
  /// one by one.
  bool unorderedEqualItems(covariant Iterable? other) {
    if (other == null) return false;
    if (identical(this, other) || (other is ImmutableSet<T> && same(other))) {
      return true;
    }
    return const UnorderedIterableEquality<Object?>().equals(_delegate, other);
  }

  /// Will return `true` only if the set items are equal and the set configurations are equal.
  /// This may be slow for very large sets, since it compares each item, one by one.
  @override
  bool equalItemsAndConfig(ImmutableSet? other) {
    if (identical(this, other)) return true;

    // Objects with different hashCodes are not equal.
    if (_isUnequalByHashCode(other)) return false;

    return config == other!.config &&
        (identical(_delegate, other._delegate) ||
            (flush._delegate as ImmutableSetFlatDelegate).deepSetEquals(
              other.flush._delegate as ImmutableSetFlatDelegate,
            ));
  }

  /// Return `true` if other is `null` or the cached [hashCode]s proves the
  /// collections are **NOT** equal.
  ///
  /// Explanation: Objects with different [hashCode]s are not equal. However,
  /// if the hashCodes are the same, then nothing can be said about the equality.
  ///
  /// Note: We use the **CACHED** hashCodes. If any of the hashCodes is null it
  /// means we don't have this information yet, and we don't calculate it.
  bool _isUnequalByHashCode(ImmutableSet? other) {
    return (other == null) ||
        (_hashCode != null &&
            other._hashCode != null &&
            _hashCode != other._hashCode);
  }

  /// Will return `true` if the sets internals are the same instances
  /// (comparing by identity). This will be fast even for very large sets,
  /// since it doesn't  compare each item.
  ///
  /// It can also return `true` under some other situations where it's very
  /// cheap to determine that the sets are equal even if the sets internals
  /// are NOT the same.
  ///
  /// Note: This is not the same as `identical(set1, set2)` since it doesn't
  /// compare the sets themselves, but their internal state. Comparing the
  /// internal state is better, because it will return true more often.
  @override
  bool same(ImmutableSet<T>? other) =>
      (other != null) &&
      identical(_delegate, other._delegate) &&
      (config == other.config);

  @override
  int get hashCode {
    if (_hashCode != null) return _hashCode!;

    final hashCode =
        isDeepEquals //
        ? Object.hash(
            (flush._delegate as ImmutableSetFlatDelegate<T>).deepSetHashcode(),
            config.hashCode,
          )
        : Object.hash(identityHashCode(_delegate), config.hashCode);

    if (config.cacheHashCode) _hashCode = hashCode;

    return hashCode;
  }

  /// Flushes the set, if necessary. Chainable method.
  /// If the set is already flushed, don't do anything.
  @override
  ImmutableSet<T> get flush;

  /// Whether this set is already flushed or not.
  @override
  bool get isFlushed => _delegate is ImmutableSetFlatDelegate;

  /// Returns a new set containing the current set plus the given item.
  @useResult
  ImmutableSet<T> add(T item) {
    final ImmutableSet<T> result = config.sort
        ? ImmutableSet._unsafe(
            ImmutableSetFlatDelegate(
              _delegate.followedBy([item]),
              config: config,
            ),
            config: config,
          )
        : ImmutableSet<T>._unsafe(_delegate.add(item), config: config);

    // A set created with `add` has a larger counter than its source set.
    // This improves the order in which sets are flushed.
    // If the outer set is used, it will be flushed before the source set.
    // If the source set is not used directly, it will not flush unnecessarily,
    // and also may be garbage collected.
    result._counter = _counter;
    result._count();

    return result;
  }

  /// Returns a new set containing the current set plus all the given items.
  @useResult
  ImmutableSet<T> addAll(Iterable<T>? items) =>
      config.sort
            ? ImmutableSet._unsafe(
                ImmutableSetFlatDelegate(
                  _delegate.followedBy(items!),
                  config: config,
                ),
                config: config,
              )
            : ImmutableSet<T>._unsafe(_delegate.addAll(items!), config: config)
        // A set created with `addAll` has a larger counter than both its source
        // sets. This improves the order in which sets are flushed.
        // If the outer set is used, it will be flushed before the source sets.
        // If the source sets are not used directly, they will not flush
        // unnecessarily, and also may be garbage collected.
        .._counter = max(
          _counter,
          (items is ImmutableSet<T>) ? items._counter : 0,
        )
        .._count();

  /// Returns a new set containing the current set minus the given item.
  /// However, if the given item didn't exist in the current set,
  /// it will return the current set (same instance).
  @useResult
  ImmutableSet<T> remove(T item) {
    final result = _delegate.remove(item);
    return identical(result, _delegate)
        ? this
        : ImmutableSet<T>._unsafe(result, config: config);
  }

  /// Removes the element, if it exists in the set.
  /// Otherwise, adds it to the set.
  @useResult
  ImmutableSet<T> toggle(T item) => contains(item) ? remove(item) : add(item);

  /// Checks whether any element of this iterable satisfies [test].
  ///
  /// Checks every element in iteration order, and returns `true` if
  /// any of them make [test] return `true`, otherwise returns `false`.
  @override
  bool any(bool Function(T element) test) => _delegate.any(test);

  /// Returns an iterable of [R] instances.
  /// If this set contains instances which cannot be cast to [R],
  /// it will throw an error.
  @override
  Iterable<R> cast<R>() => _delegate.cast<R>();

  /// Returns `true` if the collection contains an element equal to [element], `false` otherwise.
  @override
  bool contains(covariant T? element) {
    _count();
    return _delegate.contains(element);
  }

  /// Returns the [index]th element.
  @override
  T elementAt(int index) => _delegate.elementAt(index);

  /// Returns the [index]th element.
  T operator [](int index) => _delegate[index];

  /// Checks whether every element of this iterable satisfies [test].
  @override
  bool every(bool Function(T element) test) => _delegate.every(test);

  /// Expands each element of this [ImmutableSet] into zero or more elements.
  @override
  Iterable<E> expand<E>(
    Iterable<E> Function(T) f, {
    ImmutableSetConfig? config,
  }) => _delegate.expand(f);

  /// The number of objects in this set.
  @override
  int get length {
    final int length = _delegate.length;

    /// Optimization: Flushes the set, if free.
    if (length == 0 && _delegate is! ImmutableSetFlatDelegate)
      _delegate = ImmutableSetFlatDelegate.empty<T>();

    return length;
  }

  /// Compare with [others] length
  bool lengthCompare(Iterable others) => length == others.length;

  /// Returns any item from the set. This is useful if you need to read
  /// some property that you know all items in the set have.
  ///
  /// Note: getting [anyItem] is faster that getting [first] or [last].
  T get anyItem {
    return _delegate.anyItem;
  }

  /// 1. If the set's [config] has [ImmutableSetConfig.sort] `true`, will return the first
  /// element in the natural order of items. Note: This is not a fast operation,
  /// as [ImmutableSet]s are not naturally sorted.
  /// 2. If the set's [config] has [ImmutableSetConfig.sort] `false` (the default), or if
  /// the items are not [Comparable], the first item by insertion will be returned.
  ///
  @override
  T get first => config.sort
      ? (flush._delegate as ImmutableSetFlatDelegate<T>).first
      : _delegate.first;

  /// 1. If the set's [config] has [ImmutableSetConfig.sort] `true`, will return the last
  /// element in the natural order of items. Note: This is not a fast operation,
  /// as [ImmutableSet]s are not naturally sorted.
  /// 2. If the set's [config] has [ImmutableSetConfig.sort] `false` (the default), or if
  /// the items are not [Comparable], the last item by insertion will be returned.
  ///
  @override
  T get last => config.sort
      ? (flush._delegate as ImmutableSetFlatDelegate<T>).last
      : _delegate.last;

  /// Checks that this iterable has only one element, and returns that element.
  /// Throws a [StateError] if the set is empty or has more than one element.
  @override
  T get single => _delegate.single;

  /// Returns the first element, or `null` if the set is empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or `null` if the set is empty.
  T? get lastOrNull => isEmpty ? null : last;

  /// Checks that the set has only one element, and returns that element.
  /// Return `null` if the set is empty or has more than one element.
  T? get singleOrNull => length != 1 ? null : single;

  /// Returns the first element, or [orElse] if the set is empty.
  T firstOr(T orElse) => isEmpty ? orElse : first;

  /// Returns the last element, or [orElse] if the set is empty.
  T lastOr(T orElse) => isEmpty ? orElse : last;

  /// Checks if the set has only one element, and returns that element.
  /// Return `null` if the set is empty or has more than one element.
  T singleOr(T orElse) => (length != 1) ? orElse : single;

  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// - If no element satisfies [test], the result of invoking the [orElse]
  /// function is returned.
  /// - If [orElse] is omitted, it defaults to throwing a [StateError].
  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _delegate.firstWhere(test, orElse: orElse);

  /// Reduces a collection to a single value by iteratively combining eac element of the collection
  /// with an existing value.
  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      _delegate.fold(initialValue, combine);

  /// Returns the lazy concatenation of this iterable and [other].
  @override
  Iterable<T> followedBy(Iterable<T> other) => _delegate.followedBy(other);

  /// Applies the function [f] to each element of this collection in iteration order.
  @override
  void forEach(void Function(T element) f) {
    _delegate.forEach(f);
  }

  /// Converts each element to a [String] and concatenates the strings with the [separator]
  /// in-between each concatenation.
  @override
  String join([String separator = ""]) => config.sort
      ? (flush._delegate as ImmutableSetFlatDelegate<T>).join(separator)
      : _delegate.join(separator);

  /// Returns the last element that satisfies the given predicate [test].
  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _delegate.lastWhere(test, orElse: orElse);

  /// Returns an [Iterable] with elements that are created by calling [f]
  /// on each element of this [ImmutableSet] in iteration order.
  @override
  Iterable<E> map<E>(E Function(T element) f, {ImmutableSetConfig? config}) =>
      _delegate.map(f);

  /// Reduces a collection to a single value by iteratively combining elements of the collection
  /// using the provided function.
  @override
  T reduce(T Function(T value, T element) combine) => _delegate.reduce(combine);

  /// Returns the single element that satisfies [test].
  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _delegate.singleWhere(test, orElse: orElse);

  /// Returns an [ImmutableSet] that provides all but the first [count] elements.
  @override
  Iterable<T> skip(int count) => _delegate.skip(count);

  /// Returns an [ImmutableSet] that skips leading elements while [test] is satisfied.
  @override
  Iterable<T> skipWhile(bool Function(T value) test) =>
      _delegate.skipWhile(test);

  /// Returns an [ImmutableSet] of the [count] first elements of this iterable.
  @override
  Iterable<T> take(int count) => _delegate.take(count);

  /// Returns an [ImmutableSet] of the leading elements satisfying [test].
  @override
  Iterable<T> takeWhile(bool Function(T value) test) =>
      _delegate.takeWhile(test);

  /// Returns an [ImmutableSet] with all elements that satisfy the predicate [test].
  @override
  Iterable<T> where(bool Function(T element) test) => _delegate.where(test);

  /// Returns an [ImmutableSet] with all elements that have type [E].
  @override
  Iterable<E> whereType<E>() => _delegate.whereType<E>();

  /// Returns a [List] with all items from the set.
  ///
  /// If you provide a [compare] function, the list will be sorted with it.
  ///
  @override
  List<T> toList({bool growable = true, int Function(T a, T b)? compare}) {
    if (config.sort && compare == null) {
      return (flush._delegate as ImmutableSetFlatDelegate<T>).toList(
        growable: growable,
      );
    } else {
      final result = _delegate.toList(growable: growable);
      if (compare != null) result.sort(compare);
      return result;
    }
  }

  /// Returns a [ImmutableList] with all items from the set.
  ///
  /// If you provide a [compare] function, the list will be sorted with it.
  ///
  /// You can also provide a [config] for the [ImmutableList].
  ///
  ImmutableList<T> toImmutableList({
    int Function(T a, T b)? compare,
    ImmutableListConfig? config,
  }) => ImmutableList.fromISet(this, compare: compare, config: config);

  /// Returns a [Set] with all items from the [ImmutableSet].
  ///
  /// If you provide a [compare] function, the resulting set will be sorted with it.
  ///
  @override
  Set<T> toSet({int Function(T a, T b)? compare}) {
    if (config.sort && compare == null) {
      final List<T> orderedList =
          (flush._delegate as ImmutableSetFlatDelegate<T>).toList(
            growable: false,
          );
      return LinkedHashSet.of(orderedList);
    } else {
      if (compare != null) {
        final orderedList = toList(growable: false, compare: compare);
        return LinkedHashSet.of(orderedList);
      } else {
        return LinkedHashSet.of(_delegate);
      }
    }
  }

  /// Returns a string representation of (some of) the elements of `this`.
  ///
  /// Use either the [prettyPrint] or the [ImmutableCollection.prettyPrint] parameters to get a
  /// prettier print.
  ///
  /// See also: [ImmutableCollection]
  @override
  String toString([bool? prettyPrint]) {
    if (prettyPrint ?? ImmutableCollection.prettyPrint) {
      final int length = _delegate.length;
      if (length == 0) {
        return "{}";
      } else if (length == 1) {
        return "{${_delegate.single}}";
      } else {
        return "{\n   ${_delegate.join(",\n   ")}\n}";
      }
    } else {
      return "{${_delegate.join(", ")}}";
    }
  }

  /// Returns an empty set with the same configuration.
  @useResult
  ImmutableSet<T> clear() => ImmutableSetImplementation<T>.empty(config);

  /// Returns whether this [ImmutableSet] contains all the elements of [other].
  bool containsAll(Iterable<T> other) {
    _count();
    return _delegate.containsAll(other);
  }

  Set<T> _setFromIterable(Iterable<T> other) {
    Set<T> otherSet;
    if (other is Set<T>) {
      otherSet = other;
    } else if (other is ImmutableSet<T>) {
      otherSet = other.unlockView();
    } else {
      otherSet = Set.of(other);
    }
    return otherSet;
  }

  /// Returns a new set with the elements of this that are not in [other].
  ///
  /// That is, the returned set contains all the elements of this [ImmutableSet] that
  /// are not elements of [other] according to `other.contains`.
  @useResult
  ImmutableSet<T> difference(Iterable<T> other) {
    final Set<T> otherSet = _setFromIterable(other);
    return ImmutableSet._unsafeFromSet(
      _delegate.difference(otherSet),
      config: config,
    );
  }

  /// Returns a new set which is the intersection between this set and [other].
  ///
  /// That is, the returned set contains all the elements of this [ImmutableSet] that
  /// are also elements of [other] according to `other.contains`.
  @useResult
  ImmutableSet<T> intersection(Iterable<T> other) {
    final Set<T> otherSet = _setFromIterable(other);
    return ImmutableSet._unsafeFromSet(
      _delegate.intersection(otherSet),
      config: config,
    );
  }

  /// Returns a new set which contains all the elements of this set and [other].
  ///
  /// That is, the returned set contains all the elements of this [ImmutableSet] and
  /// all the elements of [other].
  @useResult
  ImmutableSet<T> union(Iterable<T> other) => addAll(other);

  /// If an object equal to [object] is in the set, return it.
  ///
  /// Checks whether [object] is in the set, like [contains], and if so,
  /// returns the object in the set, otherwise returns `null`.
  ///
  /// If the equality relation used by the set is not identity,
  /// then the returned object may not be *identical* to [object].
  /// Some set implementations may not be able to implement this method.
  ///
  /// If the [contains] method is computed,
  /// rather than being based on an actual object instance,
  /// then there may not be a specific object instance representing the
  /// set element.
  T? lookup(T element) {
    _count();
    return _delegate.lookup(element);
  }

  /// Removes each element of [elements] from this set.
  @useResult
  ImmutableSet<T> removeAll(Iterable<Object?> elements) {
    return ImmutableSet._unsafeFromSet(
      unlock()..removeAll(elements),
      config: config,
    );
  }

  /// Removes all elements of this set that satisfy [test].
  @useResult
  ImmutableSet<T> removeWhere(bool Function(T element) test) {
    return ImmutableSet._unsafeFromSet(
      unlock()..removeWhere(test),
      config: config,
    );
  }

  /// Removes all elements of this set that are not elements in [elements].
  ///
  /// Checks for each element of [elements] whether there is an element in this
  /// set that is equal to it (according to `this.contains`), and if so, the
  /// equal element in this set is retained, and elements that are not equal
  /// to any element in `elements` are removed.
  @useResult
  ImmutableSet<T> retainAll(Iterable<Object?> elements) {
    return ImmutableSet._unsafeFromSet(
      unlock()..retainAll(elements),
      config: config,
    );
  }

  /// Removes all elements of this set that fail to satisfy [test].
  @useResult
  ImmutableSet<T> retainWhere(bool Function(T element) test) {
    return ImmutableSet._unsafeFromSet(
      unlock()..retainWhere(test),
      config: config,
    );
  }
}

@visibleForTesting
@immutable
// ignore: must_be_immutable
class ImmutableSetImplementation<T extends Object?> extends ImmutableSet<T> {
  ImmutableSetImplementation.unsafe(Set<T> set, {required this.config})
    : _delegate = ImmutableSetFlatDelegate<T>.unsafe(set),
      super._() {
    if (ImmutableCollection.disallowUnsafeConstructors) {
      throw UnsupportedError("ISet.unsafe is disallowed.");
    }
  }

  /// **Unsafe**.
  ImmutableSetImplementation._unsafe(this._delegate, {required this.config})
    : super._();

  /// **Unsafe**.
  ImmutableSetImplementation._unsafeFromSet(Set<T> set, {required this.config})
    : _delegate = ImmutableSetFlatDelegate<T>.unsafe(set),
      super._();

  /// Returns an empty [ImmutableSet], with the given configuration. If a
  /// configuration is not provided, it will use the default configuration.
  ///
  /// Note: If you want to create an empty immutable collection of the same
  /// type and same configuration as a source collection, simply call [clear]
  /// on the source collection.
  factory ImmutableSetImplementation.empty([ImmutableSetConfig? config]) =>
      ImmutableSetImplementation._unsafe(
        ImmutableSetFlatDelegate.empty<T>(),
        config: config ?? ImmutableSet.defaultConfig,
      );

  /// **Safe**. Fast if the [Iterable] is an [ImmutableSet].
  ImmutableSetImplementation._(Iterable<T>? iterable, {required this.config})
    : _delegate =
          iterable
              is ImmutableSet<T> //
          ? iterable._delegate
          : iterable == null
          ? ImmutableSetFlatDelegate.empty<T>()
          : ImmutableSetFlatDelegate<T>(iterable),
      super._();

  /// The set configuration ([ImmutableSetConfig]).
  @override
  final ImmutableSetConfig config;

  @override
  final ImmutableSetDelegate<T> _delegate;

  @override
  int _counter = 0;

  @override
  // ignore: use_late_for_private_fields_and_variables
  int? _hashCode;

  @override
  // ignore: use_late_for_private_fields_and_variables
  Map<Object, Object?>? _cache;

  /// Flushes the set, if necessary. Chainable method.
  /// If the set is already flushed, don't do anything.
  @override
  ImmutableSet<T> get flush {
    if (!isFlushed) {
      // Flushes the original _s because maybe it's used elsewhere.
      // Or maybe it was flushed already, and we can use it as is.
      _delegate = ImmutableSetFlatDelegate<T>.unsafe(
        _delegate.getFlushed(config),
      );
      _counter = 0;
    }
    return this;
  }
}

/// **Don't use this class**.
@visibleForTesting
extension type const ImmutableSetInternals<T extends Object?>(ImmutableSet<T> _)
    implements ImmutableSet<T> {
  ImmutableSetDelegate<T> get delegate => _._delegate;

  /// To access the private counter, add this to the test file:
  ///
  /// ```dart
  /// extension TestExtension on ISet {
  ///   int get counter => InternalsForTestingPurposesISet(this).counter;
  /// }
  /// ```
  int get counter => _._counter;
}
