part of 'immutable_list.dart';

/// This is an [ImmutableList] which is always empty.
@visibleForTesting
@immutable
final class ImmutableListEmpty<T extends Object?> extends ImmutableList<T> {
  /// Creates an empty list. In most cases, you should use `const IList.empty()`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's always wrong to use an `IListEmpty()` which is not constant.
  @literal
  const ImmutableListEmpty._({this.config = const ImmutableListConfig()})
    : super._();

  @override
  final ImmutableListConfig config;

  /// An empty list is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a empty list, by definition.
  @override
  ImmutableListEmpty<T> get flush => this;

  /// An empty list is always empty, by definition
  @override
  bool get isEmpty => true;

  /// An empty list is always empty, by definition
  @override
  bool get isNotEmpty => false;

  /// An empty list does not contain anything, by definition
  @override
  bool contains(covariant T? element) => false;

  /// An empty list is always of length `0`, by definition
  @override
  int get length => 0;

  /// An empty list has no first element, by definition
  @override
  Never get first => throw StateError("No element");

  /// An empty list has no last element, by definition
  @override
  Never get last => throw StateError("No element");

  /// An empty list has no single element, by definition
  @override
  Never get single => throw StateError("No element");

  /// An empty list is always the reversed version of itself, by definition
  @override
  ImmutableListEmpty<T> get reversed => this;

  /// An empty list is always the cleared version of itself, by definition
  @override
  ImmutableListEmpty<T> clear() => this;

  @override
  int get _counter => 0;

  @override
  ImmutableListDelegate<T> get _delegate =>
      ImmutableListFlatDelegate<T>.unsafe([]);

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(const ListEquality<dynamic>().hash([]), config.hashCode)
        : Object.hash(identityHashCode(_delegate), config.hashCode);
  }

  @override
  set _hashCode(int? value) {}

  @override
  Map<Object, Object?>? get _cache => null;

  @override
  set _cache(Map<Object, Object?>? value) {}

  @override
  bool same(ImmutableList<T>? other) =>
      (other != null) &&
      (other is ImmutableListEmpty ||
          (other is ImmutableListLiteral &&
              (other as ImmutableListLiteral)._list.isEmpty)) &&
      (config == other.config);
}

/// This is an [ImmutableList] which can be made constant.
/// Note: Don't ever use it without the "const" keyword, because it will be unsafe.
@visibleForTesting
@immutable
final class ImmutableListLiteral<T extends Object?> extends ImmutableList<T> {
  //
  /// To create an empty constant IList: `const IListConst([])`.
  /// To create a constant list with items: `const IListConst([1, 2, 3])`.
  ///
  /// IMPORTANT: You must always use the `const` keyword.
  /// It's always wrong to use an `IListConst` which is not constant.
  ///
  @literal
  const ImmutableListLiteral._(
    this._list, {
    this.config = const ImmutableListConfig(),
  }) : super._();

  final List<T> _list;

  @override
  final ImmutableListConfig config;

  /// A constant list is always flushed, by definition.
  @override
  bool get isFlushed => true;

  /// Nothing happens when you flush a constant list, by definition.
  @override
  ImmutableListLiteral<T> get flush => this;

  @override
  int get _counter => 0;

  @override
  ImmutableListDelegate<T> get _delegate =>
      ImmutableListFlatDelegate<T>.unsafe(_list);

  /// Hash codes must be the same for objects that are equal to each other
  /// according to operator ==.
  @override
  int? get _hashCode {
    return isDeepEquals
        ? Object.hash(
            const ListEquality<dynamic>().hash(_list),
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
  bool same(ImmutableList<T>? other) =>
      (other != null) &&
      (((other is ImmutableListLiteral) &&
              identical(_list, (other as ImmutableListLiteral)._list)) ||
          ((other is ImmutableListEmpty) && _list.isEmpty)) &&
      (config == other.config);
}
