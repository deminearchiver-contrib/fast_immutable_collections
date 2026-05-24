// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'package:collection/collection.dart';

import 'immutable_set.dart';

/// See also: [FicListExtension]
extension FicSetExtension<T extends Object?> on Set<T> {
  /// Locks the set, returning an *immutable* set ([ImmutableSet]).
  ImmutableSet<T> lock() => ImmutableSet<T>(this);

  /// Locks the set, returning an *immutable* set ([ImmutableSet]).
  ///
  /// **This is unsafe: Use it at your own peril**.
  ///
  /// This constructor is fast, since it makes no defensive copies of the set.
  /// However, you should only use this with a new set you"ve created yourself,
  /// when you are sure no external copies exist. If the original set is modified,
  /// it will break the [ImmutableSet] and any other derived sets in unpredictable ways.
  ///
  /// Note you can optionally disallow unsafe constructors in the global configuration
  /// by doing: `ImmutableCollection.disallowUnsafeConstructors = true` (and then optionally
  /// preventing further configuration changes by calling `lockConfig()`).
  ///
  /// See also: [ImmutableCollection]
  ImmutableSet<T> lockUnsafe() =>
      ImmutableSet<T>.unsafe(this, config: ImmutableSet.defaultConfig);

  /// If the item doesn't exist in the set, add it and return `true`.
  /// Otherwise, if the item already exists in the set, remove it and return `false`.
  bool toggle(T item) {
    final result = contains(item);
    if (result) {
      remove(item);
    } else {
      add(item);
    }
    return !result;
  }

  /// Removes all `null`s from the [Set].
  ///
  /// See also: [whereNotNull] in [FicIterableExtension] for a lazy version.
  ///
  void removeNulls() {
    removeWhere((element) => element == null);
  }

  /// Given this set and [other], returns:
  ///
  /// 1) Items of this set which are NOT in [other] (difference this - other), in this set"s order.
  /// 2) Items of [other] which are NOT in this set (difference other - this), in [other]"s order.
  /// 3) Items of this set which are also in [other], in this set"s order.
  /// 4) Items of this set which are also in [other], in [other]"s order.
  ///
  DiffAndIntersectResult<T, G> diffAndIntersect<G>(
    Set<G> other, {
    bool diffThisMinusOther = true,
    bool diffOtherMinusThis = true,
    bool intersectThisWithOther = true,
    bool intersectOtherWithThis = true,
  }) {
    final diffThisMinusOther0 = diffThisMinusOther ? <T>[] : null;
    final diffOtherMinusThis0 = diffOtherMinusThis ? <G>[] : null;
    final intersectThisWithOther0 = intersectThisWithOther ? <T>[] : null;
    final intersectOtherWithThis0 = intersectOtherWithThis ? <T>[] : null;

    if (diffThisMinusOther || intersectThisWithOther) {
      for (final element in this) {
        if (other.contains(element)) {
          intersectThisWithOther0?.add(element);
        } else {
          diffThisMinusOther0?.add(element);
        }
      }
    }

    if (diffOtherMinusThis || intersectOtherWithThis) {
      for (final element in other) {
        if (contains(element)) {
          intersectOtherWithThis0?.add(element as T);
        } else {
          diffOtherMinusThis0?.add(element);
        }
      }
    }

    return DiffAndIntersectResult(
      diffThisMinusOther: diffThisMinusOther0,
      diffOtherMinusThis: diffOtherMinusThis0,
      intersectThisWithOther: intersectThisWithOther0,
      intersectOtherWithThis: intersectOtherWithThis0,
    );
  }
}

class DiffAndIntersectResult<T extends Object?, G extends Object?> {
  final List<T>? diffThisMinusOther;
  final List<G>? diffOtherMinusThis;
  final List<T>? intersectThisWithOther;
  final List<T>? intersectOtherWithThis;

  DiffAndIntersectResult({
    this.diffThisMinusOther,
    this.diffOtherMinusThis,
    this.intersectThisWithOther,
    this.intersectOtherWithThis,
  });

  @override
  String toString() =>
      "DiffAndIntersectResult{\n"
      "diffThisMinusOther: $diffThisMinusOther,\n"
      "diffOtherMinusThis: $diffOtherMinusThis,\n"
      "intersectThisWithOther: $intersectThisWithOther,\n"
      "intersectOtherWithThis: $intersectOtherWithThis\n"
      "}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiffAndIntersectResult &&
          const ListEquality<Object?>().equals(
            diffThisMinusOther,
            other.diffThisMinusOther,
          ) &&
          const ListEquality<Object?>().equals(
            diffOtherMinusThis,
            other.diffOtherMinusThis,
          ) &&
          const ListEquality<Object?>().equals(
            intersectThisWithOther,
            other.intersectThisWithOther,
          ) &&
          const ListEquality<Object?>().equals(
            intersectOtherWithThis,
            other.intersectOtherWithThis,
          );

  @override
  int get hashCode =>
      const ListEquality<Object?>().hash(diffThisMinusOther) ^
      const ListEquality<Object?>().hash(diffOtherMinusThis) ^
      const ListEquality<Object?>().hash(intersectThisWithOther) ^
      const ListEquality<Object?>().hash(intersectOtherWithThis);
}
