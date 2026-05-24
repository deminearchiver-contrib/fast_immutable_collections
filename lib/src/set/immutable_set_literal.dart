part of 'immutable_set.dart';

/// This is an [ImmutableSet] which is always empty.
@visibleForTesting
@immutable
class ImmutableSetEmpty<T extends Object?> extends ImmutableSet<T> {
  /// Creates an empty set. In most cases, you should use `const ISet.empty()`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's always wrong to use an `ISetEmpty()` which is not constant.
  @literal
  const ImmutableSetEmpty._([this.config = const ImmutableSetConfig()])
    : super._();

  @override
  final ImmutableSetConfig config;

  /// An empty set is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a empty set, by definition.
  @override
  ImmutableSetEmpty<T> get flush => this;

  /// An empty set is always empty, by definition
  @override
  bool get isEmpty => true;

  /// An empty set is always empty, by definition
  @override
  bool get isNotEmpty => false;

  /// An empty set does not contain anything, by definition
  @override
  bool contains(covariant T? element) => false;

  /// An empty set is always of length `0`, by definition
  @override
  int get length => 0;

  /// An empty set has no first element, by definition
  @override
  Never get first => throw StateError("No element");

  /// An empty set has no last element, by definition
  @override
  Never get last => throw StateError("No element");

  /// An empty set has no single element, by definition
  @override
  Never get single => throw StateError("No element");

  /// An empty set is always the cleared version of itself, by definition
  @override
  ImmutableSetEmpty<T> clear() => this;

  @override
  int get _counter => 0;

  @override
  ImmutableSetDelegate<T> get _delegate =>
      ImmutableSetFlatDelegate<T>.unsafe({});

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(const SetEquality<Object?>().hash({}), config.hashCode)
        : Object.hash(identityHashCode(_delegate), config.hashCode);
  }

  @override
  set _hashCode(int? value) {}

  @override
  Map<Object, Object?>? get _cache => null;

  @override
  set _cache(Map<Object, Object?>? value) {}

  @override
  bool same(ImmutableSet<T>? other) =>
      (other != null) &&
      (other is ImmutableSetEmpty ||
          (other is ImmutableSetLiteral &&
              (other as ImmutableSetLiteral)._set.isEmpty)) &&
      (config == other.config);
}

/// This is an [ImmutableSet] which can be made constant.
/// Note: Don't ever use it without the "const" keyword, because it will be unsafe.
///
/// The const ISet will always keep insertion order. In other words, you can't make
/// the sort configuration `true`.
@visibleForTesting
@immutable
class ImmutableSetLiteral<T extends Object?> extends ImmutableSet<T> {
  //
  /// To create an empty constant ISet: `const ISetConst({})`.
  /// To create a constant set with items: `const ISetConst({1, 2, 3})`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's always wrong to use an `ISetConst` which is not constant.
  ///
  @literal
  const ImmutableSetLiteral._(
    this._set, {
    // Note: The _set can't be optional. This doesn't work: [this._set = const {}]
    // because when you do this _set will be Set<Never> which is bad.
    this.config = const ImmutableSetConfig(),
  }) : super._();

  final Set<T> _set;

  @override
  final ImmutableSetConfig config;

  /// A constant set is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a constant set, by definition.
  @override
  ImmutableSetLiteral<T> get flush => this;

  @override
  int get _counter => 0;

  @override
  ImmutableSetDelegate<T> get _delegate {
    if (config.sort && _set.isNotEmpty) {
      throw UnsupportedError("Can't use a const ISet unless it's empty.");
    }
    return ImmutableSetFlatDelegate<T>.unsafe(_set);
  }

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(const SetEquality<Object?>().hash(_set), config.hashCode)
        : Object.hash(identityHashCode(_delegate), config.hashCode);
  }

  @override
  set _hashCode(int? value) {}

  @override
  Map<Object, Object?>? get _cache => null;

  @override
  set _cache(Map<Object, Object?>? value) {}

  @override
  bool same(ImmutableSet<T>? other) =>
      (other != null) &&
      (((other is ImmutableSetLiteral) &&
              identical(_set, (other as ImmutableSetLiteral)._set)) ||
          ((other is ImmutableSetEmpty) && _set.isEmpty)) &&
      (config == other.config);
}
