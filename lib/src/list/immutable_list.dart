// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

part 'immutable_list_delegate.dart';
part 'immutable_list_literal.dart';

/// An **immutable** list.
/// Note: The [replace] method is the equivalent of `operator []=` for the [List].
///
@immutable
abstract class ImmutableList<T extends Object?>
    extends ImmutableCollection<ImmutableList<T>>
    implements Iterable<T> {
  const ImmutableList._();

  /// **Unsafe**.
  factory ImmutableList._unsafe(
    ImmutableListDelegate<T> delegate, {
    required ImmutableListConfig config,
  }) => ImmutableListImplementation._unsafe(delegate, config: config);

  /// **Unsafe**.
  factory ImmutableList._unsafeFromList(
    List<T> list, {
    required ImmutableListConfig config,
  }) => ImmutableListImplementation._unsafeFromList(list, config: config);

  /// **Unsafe constructor. Use this at your own peril.**
  ///
  /// This constructor is fast, since it makes no defensive copies of the list.
  /// However, you should only use this with a new list you've created it yourself,
  /// when you are sure no external copies exist. If the original list is modified,
  /// it will break the [ImmutableList] and any other derived lists in unpredictable ways.
  ///
  /// Note you can optionally disallow unsafe constructors ([ImmutableCollection]) in the global
  /// configuration by doing: `ImmutableCollection.disallowUnsafeConstructors = true` (and then
  /// optionally preventing further configuration changes by calling `lockConfig()`).
  factory ImmutableList.unsafe(
    List<T> list, {
    required ImmutableListConfig config,
  }) => ImmutableListImplementation.unsafe(list, config: config);

  /// Create an [ImmutableList] from any [Iterable] and a [ImmutableListConfig].
  /// Fast, if the Iterable is another [ImmutableList].
  /// If [iterable] is null, return an empty [ImmutableList].
  factory ImmutableList.withConfig(
    Iterable<T>? iterable,
    ImmutableListConfig config,
  ) {
    return iterable is ImmutableList<T> && iterable.isOfExactGenericType<T>()
        ? config == iterable.config
              ? iterable
              : iterable.isEmpty
              ? .empty(config: config)
              : ImmutableListImplementation<T>._(iterable, config: config)
        : iterable == null
        ? .empty(config: config)
        : ._unsafe(ImmutableListFlatDelegate<T>(iterable), config: config);
  }

  /// Create an [ImmutableList] from an [iterable], with the default configuration.
  /// Fast, if the iterable is another [ImmutableList].
  ///
  /// To create an empty [ImmutableList] with the default configuration, just omit
  /// the iterable: `IList()`.
  ///
  /// Note: To create an [ImmutableList] with a specific configuration, use the `IList.withConfig()`
  /// constructor.
  ///
  /// Note: If you want to create an empty [ImmutableList] of the same configuration as a
  /// source [ImmutableList], simply call [clear] on the source [ImmutableList].
  ///
  factory ImmutableList([Iterable<T>? iterable]) => //
      ImmutableList.withConfig(iterable ?? const [], defaultConfig);

  factory ImmutableList.empty({ImmutableListConfig config}) =
      ImmutableListImplementation<T>._empty;

  /// Create an empty [ImmutableList].
  /// Use it with const: `const IList.empty()` (It's always an [ImmutableListEmpty]).
  @literal
  const factory ImmutableList.emptyLiteral({ImmutableListConfig config}) =
      ImmutableListEmpty<T>._;

  @literal
  const factory ImmutableList.literal(
    List<T> list, {
    ImmutableListConfig config,
  }) = ImmutableListLiteral<T>._;

  ImmutableListConfig get config;

  ImmutableListDelegate<T> get _delegate;

  set _delegate(ImmutableListDelegate<T> value) {}

  int get _counter;

  set _counter(int value) {}

  int? get _hashCode;

  set _hashCode(int? value);

  Map<Object, Object?>? get _cache;

  set _cache(Map<Object, Object?>? value);

  /// Returns a cached value derived from this list, computing it on first access.
  ///
  /// Since [ImmutableList] is immutable, any value derived from its contents is stable and
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
  /// class UserState {
  ///   final IList<User> users;
  ///
  ///   static final _byId = CacheKey<IList<User>, Map<String, User>>(
  ///     (list) => {for (var u in list) u.id: u},
  ///   );
  ///
  ///   User? findById(String id) => users.cached(_byId)[id];
  /// }
  /// ```
  ///
  /// Note: Caching is supported only in regular [ImmutableList] instances. Constant lists
  /// created with `const IList.empty()` or `const IListConst(...)` will compute
  /// the value each time without caching, since they cannot hold mutable state.
  ///
  R cached<R>(CacheKey<ImmutableList<T>, R> key) {
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

    final hashCode = isDeepEquals
        ? Object.hash(
            (flush._delegate as ImmutableListFlatDelegate<T>)
                .deepListHashcode(),
            config.hashCode,
          )
        : Object.hash(identityHashCode(_delegate), config.hashCode);

    if (config.cacheHashCode) _hashCode = hashCode;

    return hashCode;
  }

  /// Creates a new list with the given [config].
  ///
  /// To copy the config from another [ImmutableList]:
  ///
  /// ```dart
  /// list = list.withConfig(other.config);
  /// ```
  ///
  /// To change the current config:
  ///
  /// ```dart
  /// list = list.withConfig(list.config.copyWith(isDeepEquals: isDeepEquals));
  /// ```
  ///
  /// See also: [withIdentityEquals] and [withDeepEquals].
  ///
  @useResult
  ImmutableList<T> withConfig(ImmutableListConfig config) {
    return (config == this.config)
        ? this
        : ImmutableList._unsafe(_delegate, config: config);
  }

  /// Returns a new list with the contents of the present [ImmutableList],
  /// but the config of [other].
  @useResult
  ImmutableList<T> withConfigFrom(ImmutableList<T> other) =>
      withConfig(other.config);

  /// Special [ImmutableList] constructor from [ImmutableSet].
  ///
  /// If you provide a [compare] function, the resulting list will be sorted with it.
  ///
  factory ImmutableList.fromISet(
    ImmutableSet<T> iset, {
    int Function(T a, T b)? compare,
    required ImmutableListConfig? config,
  }) {
    final List<T> list = iset.toList(growable: false, compare: compare);
    return ImmutableList._unsafe(
      ImmutableListFlatDelegate<T>.unsafe(list),
      config: config ?? defaultConfig,
    );
  }

  /// Constructor [ImmutableList.orNull] accepts an [Iterable] or `null`.
  ///
  /// Behavior:
  /// - If [iterable] is `null`, it returns `null`.
  /// - If [iterable] is an [ImmutableList], it returns the same instance. No copy is created.
  /// - If [iterable] is any other [Iterable], it creates a new [ImmutableList] from it.
  ///
  /// This static factory is the recommended way to write constructors
  /// and `copyWith` methods that accept both [ImmutableList] and [Iterable].
  ///
  /// ## The problem
  ///
  /// Consider this code:
  ///
  /// ```dart
  /// class NotesState {
  ///   final IList<Note> notes;
  ///
  ///   NotesState({
  ///     this.notes = const IList.empty(),
  ///   });
  /// }
  ///
  /// NotesState copyWith({IList<Note>? notes})
  ///   => NotesState(
  ///     notes: notes ?? this.notes,
  ///   );
  ///
  /// // To use it, you must instantiate an IList.
  /// var notes = NotesState(notes: IList<Note>([note1, note2]));
  /// ```
  ///
  /// Here, callers must always create an [ImmutableList] themselves.
  ///
  /// ## Solution
  ///
  /// Use [ImmutableList.orNull] so your API can accept any [Iterable], or `null`:
  ///
  /// ```dart
  /// class NotesState {
  ///   final IList<Note> notes;
  ///
  ///   NotesState({
  ///     Iterable<Note>? notes,
  ///   }) : notes = IList.orNull(notes) ?? const IList.empty();
  ///
  ///   NotesState copyWith({Iterable<Note>? notes})
  ///     => NotesState(
  ///       notes: IList.orNull(notes) ?? this.notes,
  ///     );
  /// }
  ///
  /// // Use it
  /// var notes = NotesState(); // Creates an empty list
  /// var notes = NotesState(null); // Creates an empty list
  /// var notes = NotesState(notes: []); // List works
  /// var notes = NotesState(notes: IList<Note>([note1, note2])); // IList works
  /// var notes = NotesState(notes: [note1, note2]); // List works
  /// var notes = NotesState(notes: {note1, note2}); // Set works
  /// ```
  ///
  /// Summary:
  /// - If `notes` is `null` or omitted, an empty [ImmutableList] is used.
  /// - If `notes` is an [ImmutableList], the same instance is reused.
  ///   The exact object you pass in is kept.
  /// - If `notes` is any other [Iterable], a new [ImmutableList] is created.
  ///
  @useResult
  static ImmutableList<T>? orNull<T>(
    Iterable<T>? iterable, [
    ImmutableListConfig? config,
  ]) => (iterable == null)
      ? null
      : ImmutableList.withConfig(iterable, config ?? defaultConfig);

  /// Converts from JSon. Json serialization support for json_serializable with @JsonSerializable.
  factory ImmutableList.fromJson(dynamic json, T Function(Object?) fromJsonT) =>
      ImmutableList<T>((json as Iterable).map(fromJsonT));

  /// Converts to JSon. Json serialization support for json_serializable with @JsonSerializable.
  Object toJson(Object? Function(T) toJsonT) => map(toJsonT).toList();

  /// See also: [ImmutableCollection], [ImmutableCollection.lockConfig],
  /// [ImmutableCollection.isConfigLocked],[flushFactor], [defaultConfig]
  static void resetAllConfigurations() {
    if (ImmutableCollection.isConfigLocked) {
      throw StateError(
        "Can't change the configuration  of immutable collections.",
      );
    }
    ImmutableList.flushFactor = _defaultFlushFactor;
    ImmutableList.defaultConfig = _defaultConfig;
  }

  /// Apply Op on previous state of base and return all results
  @useResult
  static ImmutableList<U> iterate<U>(
    U base,
    int count,
    U Function(U element) op,
  ) {
    ImmutableList<U> iterations() {
      final l = List.filled(count, base, growable: false);
      var acc = base;
      var i = 1;
      l[0] = acc;

      while (i < count) {
        acc = op(acc);
        l[i] = acc;
        i += 1;
      }

      return l.lock;
    }

    return count > 0 ? iterations() : <U>[].lock;
  }

  /// Apply Op on previous state of base while predicate pass then return all results
  @useResult
  static ImmutableList<U> iterateWhile<U>(
    U base,
    bool Function(U element) test,
    U Function(U element) op,
  ) {
    final l = <U>[];
    var acc = base;
    l.add(acc);
    while (test(acc)) {
      acc = op(l.last);
      l.add(acc);
    }
    return l.lock;
  }

  static Iterable<U> tabulate<U>(int count, U Function(int at) generator) =>
      .generate(count, generator);

  static Iterable<Iterable<U>> tabulate2<U>(
    int count0,
    int count1,
    U Function(int at0, int at1) generator,
  ) => Iterable.generate(
    count0,
    (index0) =>
        Iterable.generate(count1, (index1) => generator(index0, index1)),
  );

  static Iterable<Iterable<Iterable<U>>> tabulate3<U>(
    int count0,
    int count1,
    int count2,
    U Function(int at0, int at1, int at2) on,
  ) => Iterable.generate(
    count0,
    (idx0) => Iterable.generate(
      count1,
      (idx1) => Iterable.generate(count2, (idx2) => on(idx0, idx1, idx2)),
    ),
  );

  static Iterable<Iterable<Iterable<Iterable<U>>>> tabulate4<U>(
    int count0,
    int count1,
    int count2,
    int count3,
    U Function(int at0, int at1, int at2, int at3) on,
  ) => Iterable.generate(
    count0,
    (idx0) => Iterable.generate(
      count1,
      (idx1) => Iterable.generate(
        count2,
        (idx2) =>
            Iterable.generate(count3, (idx3) => on(idx0, idx1, idx2, idx3)),
      ),
    ),
  );

  static Iterable<Iterable<Iterable<Iterable<Iterable<U>>>>> tabulate5<U>(
    int count0,
    int count1,
    int count2,
    int count3,
    int count4,
    U Function(int at0, int at1, int at2, int at3, int at4) on,
  ) => Iterable.generate(
    count0,
    (idx0) => Iterable.generate(
      count1,
      (idx1) => Iterable.generate(
        count2,
        (idx2) => Iterable.generate(
          count3,
          (idx3) => Iterable.generate(
            count4,
            (idx4) => on(idx0, idx1, idx2, idx3, idx4),
          ),
        ),
      ),
    ),
  );

  /// Global configuration that specifies if, by default, the [ImmutableList]s
  /// use equality or identity for their [operator ==].
  /// By default `isDeepEquals: true` (lists are compared by equality) and `cacheHashCode = true`.
  static ImmutableListConfig get defaultConfig => _defaultConfig;

  /// Indicates the number of operations an [ImmutableList] may perform
  /// before it is eligible for auto-flush. Must be larger than `0`.
  static int get flushFactor => _flushFactor;

  /// See also: [ImmutableListConfig], [ImmutableCollection], [resetAllConfigurations]
  static set defaultConfig(ImmutableListConfig config) {
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

  static ImmutableListConfig _defaultConfig = const ImmutableListConfig();

  static const _defaultFlushFactor = 500;

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

  /// Creates a list with `identityEquals` (compares the internals by `identity`).
  @useResult
  ImmutableList<T> get withIdentityEquals => config.isDeepEquals
      ? ImmutableList._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: false),
        )
      : this;

  /// Creates a list with `deepEquals` (compares all list items by equality).
  @useResult
  ImmutableList<T> get withDeepEquals => config.isDeepEquals
      ? this
      : ImmutableList._unsafe(
          _delegate,
          config: config.copyWith(isDeepEquals: true),
        );

  /// See also: [ImmutableListConfig]
  bool get isDeepEquals => config.isDeepEquals;

  /// See also: [ImmutableListConfig]
  bool get isIdentityEquals => !config.isDeepEquals;

  /// Unlocks the list, returning a regular (mutable, growable) [List]. This
  /// list is "safe", in the sense that is independent from the original [ImmutableList].
  List<T> get unlock => _delegate.unlock;

  /// Unlocks the list, returning a **safe**, unmodifiable (immutable) [List] view.
  /// The word "view" means the list is backed by the original [ImmutableList].
  /// Using this is very fast, since it makes no copies of the [ImmutableList] items.
  /// However, if you try to use methods that modify the list, like [add],
  /// it will throw an [UnsupportedError].
  /// It is also very fast to lock this list back into an [ImmutableList].
  ///
  /// See also: [UnmodifiableFromImmutableList]
  List<T> get unlockView => UnmodifiableFromImmutableList(this);

  /// Unlocks the list, returning a **safe**, modifiable (mutable) [List].
  /// Using this is very fast at first, since it makes no copies of the [ImmutableList]
  /// items. However, if and only if you use a method that mutates the list,
  /// like [add], it will unlock internally (make a copy of all [ImmutableList] items). This is
  /// transparent to you, and will happen at most only once. In other words,
  /// it will unlock the [ImmutableList], lazily, only if necessary.
  /// If you never mutate the list, it will be very fast to lock this list
  /// back into an [ImmutableList].
  ///
  /// See also: [ModifiableFromImmutableList]
  List<T> get unlockLazy => ModifiableFromImmutableList(this);

  /// Returns a new `Iterator` that allows iterating the elements of this [ImmutableList].
  @override
  Iterator<T> get iterator => _delegate.iterator;

  /// Returns `true` if there are no elements in this collection.
  @override
  bool get isEmpty => _delegate.isEmpty;

  /// Returns `true` if there is at least one element in this collection.
  @override
  bool get isNotEmpty => !isEmpty;

  /// - If [isDeepEquals] configuration is `true`:
  /// Will return `true` only if the list items are equal (and in the same order),
  /// and the list configurations are equal. This may be slow for very
  /// large lists, since it compares each item, one by one.
  ///
  /// - If [isDeepEquals] configuration is `false`:
  /// Will return `true` only if the lists internals are the same instances
  /// (comparing by identity). This will be fast even for very large lists,
  /// since it doesn't compare each item.
  ///
  /// Note: This is not the same as `identical(list1, list2)` since it doesn't
  /// compare the lists themselves, but their internal state. Comparing the
  /// internal state is better, because it will return `true` more often.
  ///
  @override
  bool operator ==(Object other) => (other is ImmutableList) && isDeepEquals
      ? equalItemsAndConfig(other)
      : (other is ImmutableList<T>) && same(other);

  /// Will return `true` only if the [ImmutableList] items are equal to the iterable items,
  /// and in the same order. This may be slow for very large lists, since it
  /// compares each item, one by one. You can compare the list with ordered
  /// sets, but unordered sets will throw a `StateError`. To compare the [ImmutableList]
  /// with unordered sets, try the [unorderedEqualItems] method.
  @override
  bool equalItems(covariant Iterable<Object?>? other) {
    if (other == null) return false;
    if (identical(this, other)) return true;

    if (other is ImmutableList) {
      if (_isUnequalByHashCode(other)) return false;
      return (flush._delegate as ImmutableListFlatDelegate).deepListEquals(
        other.flush._delegate as ImmutableListFlatDelegate,
      );
    }

    if (other is List<T>) {
      return const ListEquality<dynamic>().equals(
        UnmodifiableFromImmutableList<T>(this),
        other,
      );
    }

    if (other is HashSet) {
      throw StateError("Can't compare to HashSet (which is unordered).");
    }

    return const IterableEquality<dynamic>().equals(_delegate, other);
  }

  /// Will return `true` only if the [ImmutableList] and the iterable items have the same number of elements,
  /// and the elements of the [ImmutableList] can be paired with the elements of the iterable, so that each
  /// pair is equal. This may be slow for very large lists, since it compares each item,
  /// one by one.
  bool unorderedEqualItems(covariant Iterable<Object?>? other) {
    if (other == null) return false;
    if (identical(this, other) || (other is ImmutableList<T> && same(other))) {
      return true;
    }
    return const UnorderedIterableEquality<dynamic>().equals(_delegate, other);
  }

  /// Will return `true` only if the list items are equal and in the same order,
  /// and the list configurations are equal. This may be slow for very
  /// large lists, since it compares each item, one by one.
  @override
  bool equalItemsAndConfig(ImmutableList? other) {
    if (identical(this, other)) return true;

    // Objects with different hashCodes are not equal.
    if (_isUnequalByHashCode(other)) return false;

    return config == other!.config &&
        (identical(_delegate, other._delegate) ||
            (flush._delegate as ImmutableListFlatDelegate).deepListEquals(
              other.flush._delegate as ImmutableListFlatDelegate,
            ));
  }

  /// Return `true` if other is `null` or the cached [hashCodes] proves the
  /// collections are **NOT** equal.
  ///
  /// Explanation: Objects with different [hashCode]s are not equal. However,
  /// if the [hashCode]s are the same, then nothing can be said about the equality.
  /// Note: We use the CACHED [hashCode]. If any of the [hashCode] is `null` it
  /// means we don't have this information yet, and we don't calculate it.
  bool _isUnequalByHashCode(ImmutableList? other) {
    return (other == null) ||
        (_hashCode != null &&
            other._hashCode != null &&
            _hashCode != other._hashCode);
  }

  /// Will return `true` if the lists internals are the same instances
  /// (comparing by identity). This will be fast even for very large lists,
  /// since it doesn't compare each item.
  ///
  /// It can also return `true` under some other situations where it's very
  /// cheap to determine that the lists are equal even if the lists internals
  /// are NOT the same.
  ///
  /// Note: This is not the same as `identical(list1, list2)` since it doesn't
  /// compare the lists themselves, but their internal state. Comparing the
  /// internal state is better, because it will return `true` more often.
  @override
  bool same(ImmutableList<T>? other) =>
      (other != null) &&
      identical(_delegate, other._delegate) &&
      (config == other.config);

  /// Flushes the list, if necessary. Chainable getter.
  /// If the list is already flushed, don't do anything.
  @override
  ImmutableList<T> get flush;

  /// Whether this list is already [flush]ed or not.
  @override
  bool get isFlushed => _delegate is ImmutableListFlatDelegate;

  /// Return a new list with [item] added to the end of the current list,
  /// (thus extending the [length] by one).
  @useResult
  ImmutableList<T> add(T item) =>
      ImmutableList<T>._unsafe(_delegate.add(item), config: config)
        // A list created with `add` has a larger counter than its source list.
        // This improves the order in which lists are flushed.
        // If the outer list is used, it will be flushed before the source list.
        // If the source list is not used directly, it will not flush
        // unnecessarily, and also may be garbage collected.
        .._counter = _counter
        .._count();

  /// Returns a new list with all [items] added to the end of the current list,
  /// (thus extending the [length] by the [length] of items).
  @useResult
  ImmutableList<T> addAll(Iterable<T> items) {
    if (_delegate is ImmutableListDelegate<Never>) {
      return ImmutableListImplementation.unsafe(
        _delegate.cast<T>().toList(),
        config: config,
      );
    }
    return ImmutableList<T>._unsafe(_delegate.addAll(items), config: config)
      // A list created with `addAll` has a larger counter than both its source
      // lists. This improves the order in which lists are flushed.
      // If the outer list is used, it will be flushed before the source lists.
      // If the source lists are not used directly, they will not flush
      // unnecessarily, and also may be garbage collected.
      .._counter = max(
        _counter,
        ((items is ImmutableList<T>) ? items._counter : 0),
      )
      .._count();
  }

  /// Returns a new list where [newItems] are added or updated, by their [id]
  /// (and the [id] is a function of the item), like so:
  ///
  /// 1) Items with the same [id] will be replaced, in place.
  /// 2) Items with new [id]s will be added to the end of the list.
  ///
  /// Note: If the original list contains more than one item with the same
  /// [id] as some item in [newItems], the first will be replaced, and the
  /// others will be left untouched. If [newItems] contains more than one
  /// item with the same [id], the last one will be used, and the previous
  /// discarded.
  ///
  @useResult
  ImmutableList<T> updateById(
    Iterable<T> newItems,
    dynamic Function(T item) id,
  ) => ImmutableList._unsafeFromList(
    _delegate.updateById(newItems, id),
    config: config,
  );

  /// Removes the **first** occurrence of [item] from this [ImmutableList].
  ///
  /// ```dart
  /// IList<String> parts = ["head", "shoulders", "knees", "toes"].lock;
  /// parts.remove("head");
  /// parts.join(", ");     // "shoulders, knees, toes"
  /// ```
  ///
  /// The method has no effect if [item] was not in the list.
  ///
  @useResult
  ImmutableList<T> remove(T item) {
    final ImmutableListDelegate<T> result = _delegate.remove(item);
    return identical(result, _delegate)
        ? this
        : ImmutableList<T>._unsafe(result, config: config);
  }

  /// Removes all occurrences of all [items] from this list.
  /// Same as calling [removeMany] for each item in [items].
  ///
  /// The method has no effect if [item] was not in the list.
  ///
  @useResult
  ImmutableList<T> removeAll(Iterable<T?> items) {
    final ImmutableListDelegate<T> result = _delegate.removeAll(items);
    return identical(result, _delegate)
        ? this
        : ImmutableList<T>._unsafe(result, config: config);
  }

  /// Removes all occurrences of [item] from this list.
  ///
  /// ```dart
  /// IList<String> parts = ["head", "shoulders", "knees", "head", "toes"].lock;
  /// parts.removeMany("head");
  /// parts.join(", ");     // "shoulders, knees, toes"
  /// ```
  ///
  /// The method has no effect if [item] was not in the list.
  ///
  @useResult
  ImmutableList<T> removeMany(T item) {
    final ImmutableListDelegate<T> result = _delegate.removeMany(item);
    return identical(result, _delegate)
        ? this
        : ImmutableList<T>._unsafe(result, config: config);
  }

  /// Removes all nulls from this list.
  @useResult
  ImmutableList<T> removeNulls() => removeAll([null]);

  /// Removes duplicates (but keeps items which appear only
  /// once, plus the first time other items appear).
  @useResult
  ImmutableList<T> removeDuplicates() {
    final LinkedHashSet<T> set = _delegate.toLinkedHashSet();
    return ImmutableList<T>.withConfig(set, config);
  }

  /// Removes duplicates (but keeps items which appear only
  /// once, plus the first time other items appear).
  @useResult
  ImmutableList<T> removeNullsAndDuplicates() => ImmutableList<T>.withConfig(
    _delegate.toLinkedHashSet()..remove(null),
    config,
  );

  /// Removes the first instance of the element, if it exists in the list.
  /// Otherwise, adds it to the list.
  @useResult
  ImmutableList<T> toggle(T element) =>
      contains(element) ? remove(element) : add(element);

  /// Returns the object at the given [index] in the list or throws a [RangeError] if [index] is out
  /// of bounds.
  T operator [](int index) {
    _count();
    return _delegate[index];
  }

  /// Returns the [index]th element.
  /// This is the same as using the [] operator.
  /// See also: [get] and [getOrNull].
  @override
  T elementAt(int index) {
    _count();
    return _delegate[index];
  }

  /// Returns the [index]th element.
  /// If that index doesn't exist (negative, or out of range), will return
  /// the result of calling [orElse]. In this case, if [orElse] is not provided,
  /// will throw an error.
  T get(int index, {T Function(int index)? orElse}) {
    if (orElse == null) return _delegate[index];
    return (index < 0 || index >= _delegate.length) //
        ? orElse(index)
        : _delegate[index];
  }

  /// Returns the [index]th element.
  /// If that index doesn't exist (negative or out of range), will return null.
  /// This method will never throw an error.
  T? getOrNull(int index) =>
      (index < 0 || index >= _delegate.length) //
      ? null
      : _delegate[index];

  /// Gets the [index]th element, and then apply the [map] function to it, returning the result.
  /// If that index doesn't exist (negative, or out of range), will the [map] method
  /// will be called with `inRange` false and `value` null.
  T getAndMap(int index, T Function(int index, bool inRange, T? value) map) {
    final inRange = index >= 0 && index < _delegate.length;
    final value = inRange ? _delegate[index] : null;
    return map(index, inRange, value);
  }

  /// Checks whether any element of this iterable satisfies [test].
  ///
  /// Checks every element in iteration order, and returns `true` if
  /// any of them make [test] return `true`, otherwise returns `false`.
  @override
  bool any(bool Function(T element) test) => _delegate.any(test);

  /// Returns a list of [R] instances.
  /// If this list contains instances which cannot be cast to [R],
  /// it will throw an error.
  @override
  Iterable<R> cast<R>() => _delegate.cast<R>();

  /// Returns `true` if the collection contains an element equal to [element], `false` otherwise.
  @override
  bool contains(covariant T? element) {
    _count();
    return _delegate.contains(element);
  }

  /// Checks whether every element of this iterable satisfies [test].
  @override
  bool every(bool Function(T element) test) => _delegate.every(test);

  /// Expands each element of this [Iterable] into zero or more elements.
  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) => _delegate.expand(f);

  /// The number of objects in this list.
  @override
  int get length {
    final int length = _delegate.length;

    // Optimization: Flushes the list, if free.
    if (length == 0 && _delegate is! ImmutableListFlatDelegate) {
      _delegate = ImmutableListFlatDelegate.empty<T>();
    }

    return length;
  }

  /// Compare with [others] length
  bool lengthCompare(Iterable<Object?> others) => length == others.length;

  /// Returns `true` if the given [index] is valid (between `0` and `length - 1`).
  bool inRange(int index) => index >= 0 && index < length;

  /// Returns the first element.
  /// Throws a [StateError] if the list is empty.
  @override
  T get first => _delegate.first;

  /// Returns the last element.
  /// Throws a [StateError] if the list is empty.
  @override
  T get last => _delegate.last;

  /// Checks that this iterable has only one element, and returns that element.
  /// Throws a [StateError] if the list is empty or has more than one element.
  @override
  T get single => _delegate.single;

  /// Returns the first element, or `null` if the list is empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or `null` if the list is empty.
  T? get lastOrNull => isEmpty ? null : last;

  /// Checks that the list has only one element, and returns that element.
  /// Return `null` if the list is empty or has more than one element.
  T? get singleOrNull => length != 1 ? null : single;

  /// Returns the first element, or [orElse] if the list is empty.
  T firstOr(T orElse) => isEmpty ? orElse : first;

  /// Returns the last element, or [orElse] if the list is empty.
  T lastOr(T orElse) => isEmpty ? orElse : last;

  /// Checks if the list has only one element, and returns that element.
  /// Return `null` if the list is empty or has more than one element.
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

  /// Returns an [ImmutableList] containing successive accumulation values generated by applying
  /// [combine] from left to right to each element and the current accumulator value,
  /// starting with [initialValue].
  ///
  /// Similar to [fold], but instead of returning only the final accumulated value,
  /// it returns all intermediate accumulator values as a list.
  ///
  /// The result always starts with [initialValue] and has length `this.length + 1`.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3].lock.fold(0, (acc, e) => acc + e);  // Returns: 6
  /// [1, 2, 3].lock.scan(0, (acc, e) => acc + e);  // Returns: [0, 1, 3, 6]
  /// ```
  ///
  /// The accumulator type [E] can differ from the element type [T]:
  /// ```dart
  /// [1, 2, 3].lock.scan<String>('', (acc, e) => '$acc$e');  // Returns: ['', '1', '12', '123']
  /// ```
  ImmutableList<E> scan<E>(
    E initialValue,
    E Function(E previousValue, T element) combine,
  ) {
    final result = <E>[initialValue];
    var accumulator = initialValue;

    for (final element in this) {
      accumulator = combine(accumulator, element);
      result.add(accumulator);
    }

    return ImmutableList._unsafe(
      ImmutableListFlatDelegate<E>.unsafe(result),
      config: config,
    );
  }

  /// Returns the lazy concatenation of this iterable and [other].
  @override
  Iterable<T> followedBy(Iterable<T> other) => _delegate.followedBy(other);

  /// Applies the function [f] to each element of this collection in iteration order.
  @override
  void forEach(void Function(T element) f) {
    _delegate.forEach(f);
  }

  /// Returns the first element of this Iterable
  T get head => _delegate.first;

  /// Converts each element to a [String] and concatenates the strings with the [separator]
  /// in-between each concatenation.
  @override
  String join([String separator = ""]) => _delegate.join(separator);

  /// Returns the last element that satisfies the given predicate [test].
  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _delegate.lastWhere(test, orElse: orElse);

  /// Returns a new lazy [Iterable] with elements that are created by calling [f] on each element of
  /// this [Iterable] in iteration order.
  @override
  Iterable<E> map<E>(E Function(T element) f, {ImmutableListConfig? config}) =>
      _delegate.map(f);

  /// Reduces a collection to a single value by iteratively combining elements of the collection
  /// using the provided function.
  @override
  T reduce(T Function(T value, T element) combine) => _delegate.reduce(combine);

  /// Returns the single element that satisfies [test].
  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _delegate.singleWhere(test, orElse: orElse);

  /// Returns an [Iterable] that provides all but the first [count] elements.
  @override
  Iterable<T> skip(int count) => _delegate.skip(count);

  /// Returns an [Iterable] that skips leading elements while [test] is satisfied.
  @override
  Iterable<T> skipWhile(bool Function(T value) test) =>
      _delegate.skipWhile(test);

  /// Returns an [Iterable] that is the original iterable without head, aka first element
  Iterable<T> get tail => _delegate.skip(1);

  Iterable<Iterable<T>> tails() => ImmutableList.iterateWhile(
    this,
    (l) => l.isNotEmpty,
    (l) => l.toIList().tail,
  );

  Iterable<Iterable<T>> inits() => ImmutableList.iterateWhile(
    this,
    (l) => l.isNotEmpty,
    (l) => l.toIList().init,
  );

  /// Returns an [Iterable] that is the original iterable without the last element
  Iterable<T> get init => _delegate.take(_delegate.length - 1);

  /// Returns an [Iterable] of the [count] first elements of this iterable.
  @override
  Iterable<T> take(int count) => _delegate.take(count);

  /// Returns an [Iterable] of the leading elements satisfying [test].
  @override
  Iterable<T> takeWhile(bool Function(T value) test) =>
      _delegate.takeWhile(test);

  /// Returns an [Iterable] with all elements that satisfy the predicate [test].
  @override
  Iterable<T> where(bool Function(T element) test) => _delegate.where(test);

  /// Returns an [Iterable] with all elements that doest NOT satisfy the predicate [test].
  Iterable<T> whereNot(bool Function(T element) test) =>
      _delegate.where((e) => !test(e));

  /// Returns an [Iterable] with all elements that have type [E].
  @override
  Iterable<E> whereType<E>() => _delegate.whereType<E>();

  /// If the list has more than [maxLength] elements, remove the last elements
  /// so it remains with only [maxLength] elements. If the list has [maxLength]
  /// or less elements, doesn't change anything.
  ///
  /// If you want, you can provide a [priority] comparator, such as the elements to be removed are
  /// the ones that would be in the end of a list sorted with this comparator (the order of the
  /// remaining elements won't change).
  @useResult
  ImmutableList<T> maxLength(
    int maxLength, {
    int Function(T a, T b)? priority,
  }) {
    final originalLength = length;
    if (originalLength <= maxLength) {
      return this;
    } else if (priority == null) {
      return ImmutableList._unsafe(
        _delegate.maxLength(maxLength),
        config: config,
      );
    } else {
      List<T> toBeRemovedFromEnd = unlock..sort(priority);
      toBeRemovedFromEnd = toBeRemovedFromEnd.sublist(maxLength);
      final result = <T>[];
      for (int i = originalLength - 1; i >= 0; i--) {
        final item = this[i];
        if (!toBeRemovedFromEnd.contains(item)) {
          result.add(item);
        } else {
          toBeRemovedFromEnd.remove(item);
        }
      }
      return ImmutableList(result.reversed);
    }
  }

  /// Sorts this list according to the order specified by the [compare] function.
  ///
  /// The [compare] function must act as a [Comparator].
  ///
  /// ```dart
  /// IList<String> numbers = ['two', 'three', 'four'].lock;
  /// // Sort from shortest to longest.
  /// numbers = numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers);  // [two, four, three]
  /// ```
  ///
  /// The default list implementation use [Comparable.compare] if
  /// [compare] is omitted.
  ///
  /// ```dart
  /// IList<int> nums = [13, 2, -11].lock;
  /// nums = nums.sort();
  /// print(nums);  // [-11, 2, 13]
  /// ```
  ///
  /// A [Comparator] may compare objects as equal (return zero), even if they
  /// are distinct objects.
  /// The sort function is **not** guaranteed to be stable, so distinct objects
  /// that compare as equal may occur in any order in the result:
  ///
  /// ```dart
  /// IList<String> numbers = ['one', 'two', 'three', 'four'].lock;
  /// numbers = numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers);  // [one, two, four, three] OR [two, one, four, three]
  /// ```
  ///
  @useResult
  ImmutableList<T> sort([int Function(T a, T b)? compare]) =>
      ImmutableList._unsafe(_delegate.sort(compare), config: config);

  /// Sorts this list in reverse order in relation to the default [sort] method.
  @useResult
  ImmutableList<T> sortReversed([int Function(T a, T b)? compare]) {
    return (compare != null)
        ? sort((a, b) => compare(b, a))
        : sort((a, b) => compareObject(b, a));
  }

  /// Sorts this list according to the order specified by the [compare] function.
  ///
  /// This is similar to [sort], but uses a [merge sort algorithm](https://en.wikipedia.org/wiki/Merge_sort).
  ///
  /// On contrary to [sort], [sortOrdered] is stable, meaning distinct objects
  /// that compare as equal end up in the same order as they started in.
  ///
  /// ```dart
  /// IList<String> numbers = ['one', 'two', 'three', 'four'].lock;
  /// numbers = numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers);  // [one, two, four, three]
  /// ```
  @useResult
  ImmutableList<T> sortOrdered([int Function(T a, T b)? compare]) =>
      ImmutableList._unsafe(_delegate.sortOrdered(compare), config: config);

  /// Sorts this list according to the order specified by the [ordering] iterable.
  /// Items which don't appear in [ordering] will be included in the end, in no particular order.
  ///
  /// Note: Not very efficient at the moment (will be improved in the future).
  /// Please use for a small number of items.
  ///
  @useResult
  ImmutableList<T> sortLike(Iterable<T> ordering) =>
      ImmutableList._unsafe(_delegate.sortLike(ordering), config: config);

  /// Divides the list into two.
  /// The first one contains all items which satisfy the provided [test].
  /// The last one contains all the other items.
  /// The relative order of the items will be maintained.
  ///
  /// See also: [ImmutableListOf2]
  @useResult
  (ImmutableList<T>, ImmutableList<T>) divideIn2(bool Function(T item) test) {
    final first = <T>[];
    final last = <T>[];
    for (final item in this) {
      if (test(item)) {
        first.add(item);
      } else {
        last.add(item);
      }
    }
    return (
      ImmutableList._unsafeFromList(first, config: config),
      ImmutableList._unsafeFromList(last, config: config),
    );
  }

  /// Return true if length match and all Eq are true.
  bool corresponds<U>(Iterable<U> others, bool Function(T a, U b) equals) {
    if (length != others.length) return false;
    final iterator = others.iterator;
    for (final item in this) {
      final next = iterator.moveNext();
      if (!next) return false;
      final other = iterator.current;
      if (!equals(item, other)) return false;
    }
    return true;
  }

  /// Split the List at specified index
  (Iterable<T>, Iterable<T>) splitAt(int index) => (take(index), skip(index));

  /// Moves all items that satisfy the provided [test] to the end of the list.
  /// Keeps the relative order of the moved items.
  @useResult
  ImmutableList<T> whereMoveToTheEnd(bool Function(T item) test) {
    final lists = divideIn2(test);
    return lists.$2 + lists.$1;
  }

  /// Moves all items that satisfy the provided [test] to the start of the list.
  /// Keeps the relative order of the moved items.
  @useResult
  ImmutableList<T> whereMoveToTheStart(bool Function(T item) test) {
    final lists = divideIn2(test);
    return lists.$1 + lists.$2;
  }

  /// Creates a [List] containing the elements of this [ImmutableList].
  @override
  List<T> toList({bool growable = true}) =>
      _delegate.toList(growable: growable);

  /// Creates a [Set] containing the same elements as this [ImmutableList].
  @override
  Set<T> toSet() => _delegate.toSet();

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
        return "[]";
      } else if (length == 1) {
        return "[${_delegate.single}]";
      } else {
        return "[\n   ${_delegate.join(",\n   ")}\n]";
      }
    } else {
      return "[${_delegate.join(", ")}]";
    }
  }

  /// Returns the concatenation of this list and [other].
  /// Returns a new list containing the elements of this list followed by
  /// the elements of [other].
  @useResult
  ImmutableList<T> operator +(Iterable<T> other) => addAll(other);

  /// Returns an [ImmutableMap] view of this list.
  /// The map uses the indices of this list as keys and the corresponding objects
  /// as values. The `Map.keys` [Iterable] iterates the indices of this list
  /// in numerical order.
  ///
  /// ```dart
  /// final IList<String> words = ['hel', 'lo', 'there'].lock;
  /// final IMap<int, String> imap = words.asMap();
  /// print(imap[0] + imap[1]); // Prints 'hello';
  /// imap.keys.toList(); // [0, 1, 2, 3]
  /// ```
  @useResult
  ImmutableMap<int, T> asMap() =>
      ImmutableMap<int, T>(UnmodifiableFromImmutableList(this).asMap());

  /// Returns an empty list with the same configuration.
  @useResult
  ImmutableList<T> clear() => .empty(config: config);

  /// Returns the index of the first [element] in the list.
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object [:o:] is encountered so that [:o == element:],
  /// the index of [:o:] is returned.
  ///
  /// If [start] is not provided, this method searches from the start of the list.
  ///
  /// If [start] is provided and is different than zero, it will throw an ArgumentError
  /// in case it's `< 0` or `>= length`.
  ///
  /// ```dart
  /// final IList<String> notes = ['do', 're', 'mi', 're'].lock;
  /// notes.indexOf('re');    // 1
  /// notes.indexOf('re', 2); // 3
  /// ```
  ///
  /// Returns `-1` if [element] is not found.
  ///
  /// ```dart
  /// notes.indexOf('fa');    // -1
  /// ```
  int indexOf(T element, [int start = 0]) {
    _count();
    final length = this.length;
    if (start < 0 || (start > 0 && start >= length)) {
      throw ArgumentError.value(start, "index", "Index out of range");
    }
    for (var i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  /// This is the equivalent to `void operator []=(int index, T value);` for the [List].
  /// Sets the value at the given [index] in the list to [value]
  /// or throws a [RangeError] if [index] is out of bounds.
  ///
  /// Note: In the special case where you have an IList of ILists
  /// (Like `IList<IList<String>>`) you can use the
  /// extension [IList2dExtension.putXY].
  ///
  /// See also: [replace] (same as [put]) and [replaceBy].
  @useResult
  ImmutableList<T> put(int index, T value) {
    _count();
    return replace(index, value);
  }

  /// Finds the first occurrence of [from], and replace it with [to].
  @useResult
  ImmutableList<T> replaceFirst({required T from, required T to}) {
    final index = indexOf(from);
    return (index == -1) ? this : put(index, to);
  }

  /// Finds all occurrences of [from], and replace them with [to].
  @useResult
  ImmutableList<T> replaceAll({required T from, required T to}) => map(
    (element) => (element == from) ? to : element,
  ).toIList(config: config);

  /// Finds the first item that satisfies the provided [test],
  /// and replace it with the result of [replacement].
  ///
  /// - If [addIfNotFound] is `false`, return the unchanged
  /// list if no item satisfies the [test].
  ///
  /// - If [addIfNotFound] is `true`, add the [replacement]
  /// to the end of the list if no item satisfies the [test].
  ///
  @useResult
  ImmutableList<T> replaceFirstWhere(
    bool Function(T item) test,
    T Function(T? item) replacement, {
    bool addIfNotFound = false,
  }) {
    final int index = indexWhere(test);
    return (index != -1)
        ? put(index, replacement(this[index]))
        : addIfNotFound
        ? add(replacement(null))
        : this;
  }

  /// Finds all items that satisfy the provided [test],
  /// and replace it with [to].
  @useResult
  ImmutableList<T> replaceAllWhere(bool Function(T element) test, T to) =>
      map((element) => test(element) ? to : element).toIList(config: config);

  /// Allows for complex processing of a list.
  ///
  /// Iterates through each [item]. If the item satisfies the provided [test],
  /// replace it with applying [convert]. Otherwise, keep the item unchanged.
  /// If [test] is not provided, it will apply [convert] to all items.
  ///
  /// Function [convert] can:
  ///
  /// - Keep the [item] unchanged by returning `null`.
  /// - Remove an [item] by returning an empty iterable.
  /// - Convert an [item] to a single item by returning an iterable with an item.
  /// - Convert an [item] to many items, by returning an iterable with multiple
  /// items.
  ///
  /// If no [item]s satisfy the [test], or if [convert] kept items unchanged,
  /// [process] will return the same list instance.
  ///
  @useResult
  ImmutableList<T> process({
    bool Function(ImmutableList<T> list, int index, T item)? test,
    required Iterable<T>? Function(ImmutableList<T> list, int index, T item)
    convert,
  }) {
    var any = false;
    final List<T> result = [];
    final length = this.length;
    for (var index = 0; index < length; index++) {
      final T item = this[index];
      final satisfiesTest = (test == null) || test(this, index, item);
      if (!satisfiesTest) {
        result.add(item);
      } else {
        final converted = convert(this, index, item);

        // Keep the item unchanged by returning `null`.
        if (converted == null) {
          result.add(item);
        }
        // Remove an item by returning an empty iterable.
        else if (converted.isEmpty) {
          any = true;
        }
        // Convert an item to a single item by returning an iterable with an item.
        else if (converted.length == 1) {
          final newItem = converted.first;
          result.add(newItem);
          if (!identical(item, newItem)) any = true;
        }
        // Convert an item to many items, by returning an iterable with multiple
        else {
          result.addAll(converted);
          any = true;
        }
      }
    }
    return any ? ImmutableList._unsafeFromList(result, config: config) : this;
  }

  /// Returns the first index in the list that satisfies the provided [test].
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object `obj` is encountered so that `test(obj)` is true,
  /// the index of `obj` is returned.
  ///
  /// ```dart
  /// final IList<String> notes = ['do', 're', 'mi', 're'].lock;
  /// notes.indexWhere((note) => note.startsWith('r'));       // 1
  /// notes.indexWhere((note) => note.startsWith('r'), 2);    // 3
  /// ```
  ///
  /// Returns `-1` if [element] is not found.
  ///
  /// ```dart
  /// notes.indexWhere((note) => note.startsWith('k'));       // -1
  /// ```
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    final length = this.length;
    if (length == 0) return -1;
    if (start < 0 || start >= length) {
      throw ArgumentError.value(start, "index", "Index out of range");
    }
    for (var i = start; i <= length - 1; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Returns the last index of [element] in this list.
  ///
  /// Searches the list backwards from index [start] to `0`.
  ///
  /// The first time an object [:o:] is encountered such that [:o == element:],
  /// the index of [:o:] is returned.
  ///
  /// ```dart
  /// final IList<String> notes = ['do', 're', 'mi', 're'].lock;
  /// notes.lastIndexOf('re', 2); // 1
  /// ```
  ///
  /// If [start] is not provided, this method searches from the end of the list.
  ///
  /// ```dart
  /// notes.lastIndexOf('re');    // 3
  /// ```
  ///
  /// Returns `-1` if [element] is not found.
  ///
  /// ```dart
  /// notes.lastIndexOf('fa');    // -1
  /// ```
  int lastIndexOf(T element, [int? start]) {
    final length = this.length;
    start ??= length;
    if (start < 0) {
      throw ArgumentError.value(start, "index", "Index out of range");
    }
    for (int i = min(start, length - 1); i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  /// Returns the last index in the list that satisfies the provided [test].
  ///
  /// Searches the list from index [start] to `0`.
  /// The first time an object `obj` is encountered such that `test(obj)` is `true`,
  /// the index of `obj` is returned.
  /// If [start] is omitted, it defaults to the [length] of the list.
  ///
  /// ```dart
  /// final IList<String> notes = ['do', 're', 'mi', 're'].lock;
  /// notes.lastIndexWhere((note) => note.startsWith('r'));       // 3
  /// notes.lastIndexWhere((note) => note.startsWith('r'), 2);    // 1
  /// ```
  ///
  /// Returns `-1` if [element] is not found.
  ///
  /// ```dart
  /// notes.lastIndexWhere((note) => note.startsWith('k'));       // -1
  /// ```
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    final length = this.length;
    start ??= length;
    if (start < 0) {
      throw ArgumentError.value(start, "index", "Index out of range");
    }
    for (int i = min(start, length - 1); i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Removes the objects in the range [start] inclusive to [end] exclusive
  /// and inserts the contents of [replacement] in its place.
  ///
  /// ```dart
  /// final IList<int> ilist = [1, 2, 3, 4, 5].lock;
  /// ilist.replaceRange(1, 4, [6, 7]).join(', '); // '1, 6, 7, 5'
  /// ```
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  /// This method does not work on fixed-length lists, even when [replacement]
  /// has the same number of elements as the replaced range. In that case use
  /// [setRange] instead.
  ///
  @useResult
  ImmutableList<T> replaceRange(int start, int end, Iterable<T> replacement) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..replaceRange(start, end, replacement),
      config: config,
    );
  }

  /// Sets the objects in the range [start] inclusive to [end] exclusive
  /// to the given [fillValue].
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  /// Example with [List]:
  ///
  /// ```dart
  /// final List<int> list = List(3);
  /// list.fillRange(0, 2, 1);
  /// print(list);  // [1, 1, null]
  /// ```
  ///
  /// Example with [ImmutableList]:
  ///
  /// ```dart
  /// final IList<int> ilist = IList();
  /// ilist.fillRange(0, 2, 1);
  /// print(ilist); // [1, 1, null]
  /// ```
  ///
  /// If the element type is not nullable, omitting [fillValue] or passing `null`
  /// as [fillValue] will make the `fillRange` fail.
  ///
  @useResult
  ImmutableList<T> fillRange(int start, int end, [T? fillValue]) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: false)..fillRange(start, end, fillValue),
      config: config,
    );
  }

  /// Returns an [Iterable] that iterates over the objects in the range
  /// [start] inclusive to [end] exclusive.
  ///
  /// The provided range, given by [start] and [end], must be valid, which
  /// means `0 <= start <= end <= len`, where `len` is this list's `length`.
  /// The range starts at `start` and has length `end - start`.
  /// An empty range (with `end == start`) is valid.
  ///
  /// The returned [Iterable] behaves like `skip(start).take(end - start)`.
  ///
  /// ```dart
  /// final IList<String> colors = ['red', 'green', 'blue', 'orange', 'pink'].lock;
  /// final Iterable<String> range = colors.getRange(1, 4);
  /// range.join(', ');  // 'green, blue, orange'
  /// ```
  ///
  /// This method exists just to make the `IList` API more similar to that of
  /// the `List`, but to get a range here you should probably use the
  /// `IList.sublist()` method instead.
  ///
  @useResult
  Iterable<T> getRange(int start, int end) {
    // TODO: Still need to implement efficiently.
    return toList(growable: false).getRange(start, end);
  }

  /// Returns a new list containing the elements between [start] and [end].
  ///
  /// The new list is a `List<E>` containing the elements of this list at
  /// positions greater than or equal to [start] and less than [end] in the same
  /// order as they occur in this list.
  ///
  /// ```dart
  /// final IList<String> colors = ["red", "green", "blue", "orange", "pink"].lock;
  /// print(colors.sublist(1, 3)); // [green, blue]
  /// ```
  ///
  /// If [end] is omitted, it defaults to the [length] of this list.
  ///
  /// ```dart
  /// print(colors.sublist(1));    // [green, blue, orange, pink]
  /// ```
  ///
  /// The `start` and `end` positions must satisfy the relations
  /// 0 ≤ `start` ≤ `end` ≤ `this.length`
  /// If `end` is equal to `start`, then the returned list is empty.
  @useResult
  ImmutableList<T> sublist(int start, [int? end]) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: false).sublist(start, end),
      config: config,
    );
  }

  /// This is the equivalent to `void operator []=(int index, T value);` for the [List].
  /// Sets the value at the given [index] in the list to [value]
  /// or throws a [RangeError] if [index] is out of bounds.
  ///
  /// See also: [put] (same as [replace]), [replaceBy]
  /// and [IList2dExtension.putXY].
  @useResult
  ImmutableList<T> replace(int index, T value) {
    // TODO: Still need to implement efficiently.
    final newList = toList(growable: false);
    newList[index] = value;
    return ImmutableList._unsafeFromList(newList, config: config);
  }

  /// Returns a new [ImmutableList], replacing the object at position [index] with the result of calling
  /// the function [transform]. This function gets the previous object at position [index] as a
  /// parameter.
  ///
  /// If the index doesn't exist (negative, or out of range), will throw an error.
  ///
  /// See also: [replace].
  @useResult
  ImmutableList<T> replaceBy(int index, T Function(T item) transform) {
    final T originalValue = get(index);
    final T transformed = transform(originalValue);
    return replace(index, transformed);
  }

  /// Inserts the object at position [index] in this list and returns a new immutable list.
  ///
  /// This increases the [length] of the list by one and shifts all objects
  /// at or after the index towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  @useResult
  ImmutableList<T> insert(int index, T element) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..insert(index, element),
      config: config,
    );
  }

  /// Inserts all objects of [iterable] at position [index] in this list.
  ///
  /// This increases the [length] of the list by the length of [iterable] and
  /// shifts all later objects towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  @useResult
  ImmutableList<T> insertAll(int index, Iterable<T> iterable) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..insertAll(index, iterable),
      config: config,
    );
  }

  /// Removes the object at position [index] from this list.
  ///
  /// This method reduces the length of `this` by one and moves all later objects
  /// down by one position.
  ///
  /// Returns the list without the removed object.
  ///
  /// The [index] must be in the range `0 ≤ index < length`.
  ///
  /// If you want to recover the removed item, you can pass a mutable [removedItem].
  @useResult
  (ImmutableList<T>, T) removeAt(int index) {
    // TODO: Still need to implement efficiently.
    final list = toList(growable: true);
    final value = list.removeAt(index);
    return (ImmutableList._unsafeFromList(list, config: config), value);
  }

  /// Removes the last object from this list.
  /// This method reduces the length of `this` by one.
  ///
  /// The list must not be empty.
  ///
  /// If you want to recover the removed item, you can pass a mutable [removedItem].
  ///
  @useResult
  (ImmutableList<T>, T) removeLast() => removeAt(length - 1);

  /// Removes the objects in the range [start] inclusive to [end] exclusive.
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  @useResult
  ImmutableList<T> removeRange(int start, int end) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..removeRange(start, end),
      config: config,
    );
  }

  /// Removes all objects from this list that satisfy [test].
  ///
  /// An object [:o:] satisfies [test] if [:test(o):] is `true`.
  ///
  /// ```dart
  /// final IList<String> numbers = ['one', 'two', 'three', 'four'].lock;
  /// final IList<String> newNumbers = numbers.removeWhere((item) => item.length == 3);
  /// newNumbers.join(', '); // 'three, four'
  /// ```
  @useResult
  ImmutableList<T> removeWhere(bool Function(T element) test) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..removeWhere(test),
      config: config,
    );
  }

  /// Removes all objects from this list that fail to satisfy [test].
  ///
  /// An object [:o:] satisfies [test] if [:test(o):] is true.
  ///
  /// ```dart
  /// final IList<String> numbers = ['one', 'two', 'three', 'four'].lock;
  /// final IList<String> newNumbers = numbers.retainWhere((item) => item.length == 3);
  /// newNumbers.join(', '); // 'one, two'
  /// ```
  @useResult
  ImmutableList<T> retainWhere(bool Function(T element) test) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..retainWhere(test),
      config: config,
    );
  }

  /// Returns an [Iterable] of the objects in this list in reverse order.
  @useResult
  ImmutableList<T> get reversed {
    // TODO: Still need to implement efficiently.
    return ImmutableList.withConfig(
      UnmodifiableFromImmutableList(this).reversed,
      config,
    );
  }

  /// Overwrites objects of `this` with the objects of [iterable], starting
  /// at position [index] in this list.
  ///
  /// ```dart
  /// final IList<String> ilist = ['a', 'b', 'c'].lock;
  /// ilist.setAll(1, ['bee', 'sea']).join(', '); // 'a, bee, sea'
  /// ```
  ///
  /// This operation does not increase the [length] of `this`.
  ///
  /// The [index] must be non-negative and no greater than [length].
  ///
  /// The [iterable] must not have more elements than what can fit from [index]
  /// to [length].
  ///
  /// If `iterable` is based on this list, its values may change *during* the
  /// `setAll` operation.
  @useResult
  ImmutableList<T> setAll(int index, Iterable<T> iterable) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..setAll(index, iterable),
      config: config,
    );
  }

  /// Copies the objects of [iterable], skipping [skipCount] objects first,
  /// into the range [start], inclusive, to [end], exclusive, of the list.
  ///
  /// ```dart
  /// final IList<int> iList1 = [1, 2, 3, 4].lock;
  /// final IList<int> iList2 = [5, 6, 7, 8, 9].lock;
  /// // Copies the 4th and 5th items in iList2 as the 2nd and 3rd items of iList1.
  /// iList1.setRange(1, 3, iList2, 3).join(', '); // '1, 8, 9, 4'
  /// ```
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  /// The [iterable] must have enough objects to fill the range from `start`
  /// to `end` after skipping [skipCount] objects.
  ///
  /// If [iterable] is `this` list, the operation copies the elements
  /// originally in the range from `skipCount` to `skipCount + (end - start)` to
  /// the range `start` to `end`, even if the two ranges overlap.
  ///
  /// If [iterable] depends on this list in some other way, no guarantees are
  /// made.
  ///
  @useResult
  ImmutableList<T> setRange(
    int start,
    int end,
    Iterable<T> iterable, [
    int skipCount = 0,
  ]) {
    // TODO: Still need to implement efficiently.
    return ImmutableList._unsafeFromList(
      toList(growable: true)..setRange(start, end, iterable, skipCount),
      config: config,
    );
  }

  /// Shuffles the elements of this list randomly.
  @useResult
  ImmutableList<T> shuffle([Random? random]) =>
      ImmutableList._unsafeFromList(toList()..shuffle(random), config: config);

  /// Positives predicate results count
  int count(bool Function(T element) p) => where(p).length;

  /// Split list based on predicate p. (takeWhile p, dropWhile p)
  (Iterable<T>, Iterable<T>) span(bool Function(T element) p) {
    final i = indexWhere((e) => !p(e));
    final idx = i < 0 ? length : i;
    return (getRange(0, idx), getRange(idx, length));
  }

  /// Aggregate each element with corresponding index
  Iterable<(int, T)> zipWithIndex() => Iterable.generate(
    length,
    (index) => (index, _delegate[index]),
  ).toIList(config: config);

  /// Aggregate two sources trimming by the shortest source
  Iterable<(T, U)> zip<U>(Iterable<U> otherIterable) {
    final other = otherIterable.toList();
    final minLength = min(length, other.length);
    return Iterable.generate(
      minLength,
      (index) => (_delegate[index], other[index]),
    ).toIList(config: config);
  }

  /// Aggregate two sources based on the longest source.
  /// Missing elements can be completed by passing a [currentFill] and [otherFill] methods or will be at null by default
  Iterable<(T?, U?)> zipAll<U>(
    Iterable<U> otherIterable, {
    T Function(int index)? currentFill,
    U Function(int index)? otherFill,
  }) {
    final other = otherIterable.toList();
    final current = toList(growable: false);
    final maxLength = max(current.length, other.length);

    Object? getOrFill(List<Object?> l, int index, Function? fill) =>
        index < l.length
        ? l[index]
        : fill != null
        ? fill(index)
        : null;

    return Iterable.generate(
      maxLength,
      (index) => (
        getOrFill(current, index, currentFill) as T?,
        getOrFill(other, index, otherFill) as U?,
      ),
    ).toIList(config: config);
  }
}

@visibleForTesting
@immutable
// ignore: must_be_immutable
class ImmutableListImplementation<T extends Object?> extends ImmutableList<T> {
  /// **Safe**. Fast if the [Iterable] is an [ImmutableList].
  ImmutableListImplementation._(Iterable<T>? iterable, {required this.config})
    : _delegate =
          iterable
              is ImmutableList<T> //
          ? iterable._delegate
          : iterable == null
          ? ImmutableListFlatDelegate.empty<T>()
          : ImmutableListFlatDelegate<T>(iterable),
      super._();

  ImmutableListImplementation.unsafe(List<T> list, {required this.config})
    : _delegate = ImmutableListFlatDelegate<T>.unsafe(list),
      super._() {
    if (ImmutableCollection.disallowUnsafeConstructors) {
      throw UnsupportedError("IList.unsafe is disallowed.");
    }
  }

  /// **Unsafe**.
  ImmutableListImplementation._unsafe(this._delegate, {required this.config})
    : super._();

  /// **Unsafe**.
  ImmutableListImplementation._unsafeFromList(
    List<T> list, {
    required this.config,
  }) : _delegate = ImmutableListFlatDelegate<T>.unsafe(list),
       super._();

  /// Returns an empty [ImmutableList], with the given configuration. If a
  /// configuration is not provided, it will use the default configuration.
  ///
  /// Note: If you want to create an empty immutable collection of the same
  /// type and same configuration as a source collection, simply call [clear]
  /// on the source collection.
  factory ImmutableListImplementation._empty({ImmutableListConfig? config}) =>
      ._unsafe(
        ImmutableListFlatDelegate.empty<T>(),
        config: config ?? ImmutableList.defaultConfig,
      );

  /// The list configuration ([ImmutableListConfig]).
  @override
  final ImmutableListConfig config;

  @override
  late ImmutableListDelegate<T> _delegate;

  @override
  int _counter = 0;

  @override
  // HashCode cache. Must be null if hashCode is not cached.
  // ignore: use_late_for_private_fields_and_variables
  int? _hashCode;

  @override
  // ignore: use_late_for_private_fields_and_variables
  Map<Object, Object?>? _cache;

  /// Flushes the list, if necessary. Chainable getter.
  /// If the list is already flushed, don't do anything.
  @override
  ImmutableList<T> get flush {
    if (!isFlushed) {
      // Flushes the original _l because maybe it's used elsewhere.
      // Or maybe it was flushed already, and we can use it as is.
      _delegate = ImmutableListFlatDelegate<T>.unsafe(_delegate.getFlushed);
      _counter = 0;
    }
    return this;
  }
}

/// **Don't use this class**.
@visibleForTesting
extension type const ImmutableListInternals<T extends Object?>(
  ImmutableList<T> _
) implements ImmutableList<T> {
  ImmutableListDelegate<T> get delegate => _._delegate;

  /// To access the private counter, add this to the test file:
  ///
  /// ```dart
  /// extension TestExtension on IList {
  ///   int get counter => InternalsForTestingPurposesIList(this).counter;
  /// }
  /// ```
  int get counter => _._counter;
}
