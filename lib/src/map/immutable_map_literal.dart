part of 'immutable_map.dart';

/// This is an [ImmutableMap] which is always empty.
@immutable
final class ImmutableMapEmpty<K extends Object?, V extends Object?>
    extends ImmutableMap<K, V> {
  /// Creates an empty map. In most cases, you should use `const IMap.empty()`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's always wrong to use an `IMapEmpty()` which is not constant.
  @literal
  const ImmutableMapEmpty._([this.config = const ImmutableMapConfig()])
    : super._();

  @override
  final ImmutableMapConfig config;

  /// An empty map is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a empty map, by definition.
  @override
  ImmutableMapEmpty<K, V> get flush => this;

  /// An empty map is always empty, by definition
  @override
  bool get isEmpty => true;

  /// An empty map is always empty, by definition
  @override
  bool get isNotEmpty => false;

  /// An empty map does not contain anything, by definition
  @override
  bool contains(K key, V value) => false;

  /// An empty map does not contain anything, by definition
  @override
  bool containsKey(K? key) => false;

  /// An empty map does not contain anything, by definition
  @override
  bool containsValue(V? value) => false;

  /// An empty map does not contain anything, by definition
  @override
  bool containsEntry(MapEntry<K, V> entry) => false;

  /// An empty map is always of length `0`, by definition
  @override
  int get length => 0;

  /// An empty map is always the cleared version of itself, by definition
  @override
  ImmutableMapEmpty<K, V> clear() => this;

  @override
  int get _counter => 0;

  @override
  ImmutableMapDelegate<K, V> get _delegate =>
      ImmutableMapFlatDelegate<K, V>.unsafe({});

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(
            const MapEquality<Object?, Object?>().hash({}),
            config.hashCode,
          )
        : Object.hash(identityHashCode(_delegate), config.hashCode);
  }

  @override
  set _hashCode(int? value) {}

  @override
  Map<Object, Object?>? get _cache => null;

  @override
  set _cache(Map<Object, Object?>? value) {}

  @override
  bool same(ImmutableMap<K, V>? other) =>
      (other != null) &&
      (other is ImmutableMapEmpty ||
          (other is ImmutableMapLiteral &&
              (other as ImmutableMapLiteral)._map.isEmpty)) &&
      (config == other.config);
}

/// This is an [ImmutableMap] which can be made constant.
/// Note: Don't ever use it without the "const" keyword, because it will be unsafe.
///
@immutable
final class ImmutableMapLiteral<K extends Object?, V extends Object?>
    extends ImmutableMap<K, V> {
  //
  /// To create an empty constant IMap: `const IMapConst({})`.
  /// To create a constant map with entries: `const IMapConst({1:'a', 2:'b', 3:'c'})`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's ALWAYS wrong to use an `IMapConst` which is not constant.
  ///
  @literal
  const ImmutableMapLiteral._(
    this._map, [
    // Note: The _map can't be optional. This doesn't work: [this._map = const {}]
    // because when you do this _map will be Map<Never, Never> which is bad.
    this.config = const ImmutableMapConfig(),
  ]) : super._();

  final Map<K, V> _map;

  @override
  final ImmutableMapConfig config;

  /// A constant map is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a constant map, by definition.
  @override
  ImmutableMapLiteral<K, V> get flush => this;

  @override
  int get _counter => 0;

  @override
  ImmutableMapDelegate<K, V> get _delegate =>
      ImmutableMapFlatDelegate<K, V>.unsafe(_map);

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(
            const MapEquality<Object?, Object?>().hash(_map),
            config.hashCode,
          )
        : Object.hash(identityHashCode(_delegate), config.hashCode);
  }

  @override
  set _hashCode(int? value) {}

  @override
  Map<Object, Object?>? get _cache => null;

  @override
  set _cache(Map<Object, Object?>? value) {}

  @override
  bool same(ImmutableMap<K, V>? other) =>
      (other != null) &&
      (((other is ImmutableMapLiteral) &&
              identical(_map, (other as ImmutableMapLiteral)._map)) ||
          (((other is ImmutableMapEmpty) && _map.isEmpty))) &&
      (config == other.config);
}
