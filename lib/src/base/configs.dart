// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

/// - If [isDeepEquals] is `false`, the [ImmutableList] equals operator (`==`) compares by identity.
/// - If [isDeepEquals] is `true` (the default), the [ImmutableList] equals operator (`==`) compares all
/// items, ordered.
/// - If [cacheHashCode] is `true` (the default), the [ImmutableList] will only calculate the [hashCode]
/// once, when it is asked — initially, internally `null`. Otherwise, it will always recalculate it.
@immutable
class ImmutableListConfig {
  const ImmutableListConfig({
    this.isDeepEquals = true,
    this.cacheHashCode = true,
  });

  /// If `false`, the equals operator (`==`) compares by identity.
  /// If `true` (the default), the equals operator (`==`) compares all items, ordered.
  final bool isDeepEquals;

  /// If `false`, the [hashCode] will be calculated each time it's used.
  /// If `true` (the default), the [hashCode] will be cached.
  /// You should turn the cache off only if may use the immutable list
  /// with mutable data.
  final bool cacheHashCode;

  ImmutableListConfig copyWith({bool? isDeepEquals, bool? cacheHashCode}) {
    final config = ImmutableListConfig(
      isDeepEquals: isDeepEquals ?? this.isDeepEquals,
      cacheHashCode: cacheHashCode ?? this.cacheHashCode,
    );
    return (config == this) ? this : config;
  }

  @override
  String toString() =>
      "ConfigList{"
      "isDeepEquals: $isDeepEquals, "
      "cacheHashCode: $cacheHashCode}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImmutableListConfig &&
          runtimeType == other.runtimeType &&
          isDeepEquals == other.isDeepEquals &&
          cacheHashCode == other.cacheHashCode;

  @override
  int get hashCode => Object.hash(isDeepEquals, cacheHashCode);
}

/// The set configuration.
/// - If [isDeepEquals] is `false`, the [ImmutableSet] equals operator (`==`) compares by identity.
/// - If [isDeepEquals] is `true` (the default), the [ImmutableSet] equals operator (`==`) compares all
/// items, unordered.
/// - If [sort] is false (the default) it will keep the insertion order. Otherwise, some outputs
/// that return lists will be sorted with the item's natural ordering.
/// - If [cacheHashCode] is `true` (the default), the [ImmutableSet] will only calculate the [hashCode]
/// once, when it is asked — initially, internally `null`. Otherwise, it will always recalculate it.
@immutable
class ImmutableSetConfig {
  const ImmutableSetConfig({
    this.isDeepEquals = true,
    this.sort = false,
    this.cacheHashCode = true,
  });

  /// If `false`, the equals operator (`==`) compares by identity.
  /// If `true` (the default), the equals operator (`==`) compares all items, ordered.
  final bool isDeepEquals;

  /// If `false` (the default), will keep insertion order.
  /// If `true`, will sort the list output of items.
  final bool sort;

  /// If `false`, the [hashCode] will be calculated each time it's used.
  /// If `true` (the default), the [hashCode] will be cached.
  /// You should turn the cache off only if may use the immutable set
  /// with mutable data.
  final bool cacheHashCode;

  ImmutableSetConfig copyWith({
    bool? isDeepEquals,
    bool? sort,
    bool? cacheHashCode,
  }) {
    final config = ImmutableSetConfig(
      isDeepEquals: isDeepEquals ?? this.isDeepEquals,
      sort: sort ?? this.sort,
      cacheHashCode: cacheHashCode ?? this.cacheHashCode,
    );
    return (config == this) ? this : config;
  }

  @override
  String toString() =>
      "ConfigSet{"
      "isDeepEquals: $isDeepEquals, "
      "sort: $sort, "
      "cacheHashCode: $cacheHashCode}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImmutableSetConfig &&
          runtimeType == other.runtimeType &&
          isDeepEquals == other.isDeepEquals &&
          sort == other.sort &&
          cacheHashCode == other.cacheHashCode;

  @override
  int get hashCode => Object.hash(isDeepEquals, sort, cacheHashCode);
}

/// - If [isDeepEquals] is `false`, the [ImmutableMap] equals operator (`==`) compares by identity.
/// - If [isDeepEquals] is `true` (the default), the [ImmutableMap] equals operator (`==`) compares all entries, ordered.
/// - If [sort] is `true`, will sort the list output of keys. Otherwise, it will keep the insertion order (the default).
/// - If [cacheHashCode] is `true` (the default), the [ImmutableMap] will only calculate the [hashCode]
/// once, when it is asked — initially, internally `null`. Otherwise, it will always recalculate it.
@immutable
class ImmutableMapConfig {
  const ImmutableMapConfig({
    this.isDeepEquals = true,
    this.sort = false,
    this.cacheHashCode = true,
  });

  /// If `false`, the equals operator (`==`) compares by identity.
  /// If `true` (the default), the equals operator (`==`) compares all items, ordered.
  final bool isDeepEquals;

  /// If `false` (the default), will keep the insertion order.
  /// If `true`, will sort the list output of keys.
  final bool sort;

  /// If `false`, the [hashCode] will be calculated each time it's used.
  /// If `true` (the default), the [hashCode] will be cached.
  /// You should turn the cache off only if may use the immutable map
  /// with mutable data.
  final bool cacheHashCode;

  ImmutableMapConfig copyWith({
    bool? isDeepEquals,
    bool? sort,
    bool? cacheHashCode,
  }) {
    final config = ImmutableMapConfig(
      isDeepEquals: isDeepEquals ?? this.isDeepEquals,
      sort: sort ?? this.sort,
      cacheHashCode: cacheHashCode ?? this.cacheHashCode,
    );
    return (config == this) ? this : config;
  }

  @override
  String toString() =>
      "ConfigMap{"
      "isDeepEquals: $isDeepEquals, "
      "sort: $sort, "
      "cacheHashCode: $cacheHashCode}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImmutableMapConfig &&
          runtimeType == other.runtimeType &&
          isDeepEquals == other.isDeepEquals &&
          sort == other.sort &&
          cacheHashCode == other.cacheHashCode;

  @override
  int get hashCode => Object.hash(isDeepEquals, sort, cacheHashCode);
}

/// - If [isDeepEquals] is `false`, the [ImmutableMap] equals operator (`==`) compares by identity.
/// - If [isDeepEquals] is `true` (the default), the [ImmutableMap] equals operator (`==`) compares all entries, ordered.
/// - If [sortKeys] is `true`, will sort the list output of keys. Otherwise, it will keep the insertion order (the default).
/// - If [cacheHashCode] is `true` (the default), the [IMapOfSets] will only calculate the
/// [hashCode] once, when it is asked — initially, internally `null`. Otherwise, it will always recalculate it.
@immutable
class ImmutableSetMapConfig {
  const ImmutableSetMapConfig({
    this.isDeepEquals = true,
    this.sortKeys = false,
    this.sortValues = false,
    this.removeEmptySets = true,
    this.cacheHashCode = true,
  });

  /// If `false`, the equals operator (`==`) compares by identity.
  /// If `true` (the default), the equals operator (`==`) compares all items, ordered.
  final bool isDeepEquals;

  /// If `true` (the default), will sort the list output of keys.
  final bool sortKeys;

  /// If `true` (the default), will sort the list output of values.
  final bool sortValues;

  /// If `true` (the default), sets which become empty are automatically
  /// removed, together with their keys.
  /// If `false`, empty sets and their keys are kept.
  final bool removeEmptySets;

  /// If `false`, the [hashCode] will be calculated each time it's used.
  /// If `true` (the default), the [hashCode] will be cached.
  /// You should turn the cache off only if may use the immutable map
  /// of sets with mutable data.
  final bool cacheHashCode;

  ImmutableSetMapConfig copyWith({
    bool? isDeepEquals,
    bool? sortKeys,
    bool? sortValues,
    bool? removeEmptySets,
    bool? cacheHashCode,
  }) {
    final config = ImmutableSetMapConfig(
      isDeepEquals: isDeepEquals ?? this.isDeepEquals,
      sortKeys: sortKeys ?? this.sortKeys,
      sortValues: sortValues ?? this.sortValues,
      removeEmptySets: removeEmptySets ?? this.removeEmptySets,
      cacheHashCode: cacheHashCode ?? this.cacheHashCode,
    );
    return (config == this) ? this : config;
  }

  ImmutableMapConfig get asConfigMap => ImmutableMapConfig(
    isDeepEquals: isDeepEquals,
    sort: sortKeys,
    cacheHashCode: cacheHashCode,
  );

  ImmutableSetConfig get asConfigSet => ImmutableSetConfig(
    isDeepEquals: isDeepEquals,
    sort: sortValues,
    cacheHashCode: cacheHashCode,
  );

  @override
  String toString() =>
      "ConfigMapOfSets{"
      "isDeepEquals: $isDeepEquals, "
      "sortKeys: $sortKeys, "
      "sortValues: $sortValues, "
      "removeEmptySets: $removeEmptySets, "
      "cacheHashCode: $cacheHashCode}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImmutableSetMapConfig &&
          runtimeType == other.runtimeType &&
          isDeepEquals == other.isDeepEquals &&
          sortKeys == other.sortKeys &&
          sortValues == other.sortValues &&
          removeEmptySets == other.removeEmptySets &&
          cacheHashCode == other.cacheHashCode;

  @override
  int get hashCode => Object.hash(
    isDeepEquals,
    sortKeys,
    sortValues,
    removeEmptySets,
    cacheHashCode,
  );
}
