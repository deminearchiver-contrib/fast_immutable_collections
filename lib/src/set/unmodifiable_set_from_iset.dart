// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:collection';

import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

/// The [UnmodifiableSetFromISet] is a relatively safe, unmodifiable [Set] view that is built from
/// an [ImmutableSet] or another [Set]. The construction of the [UnmodifiableSetFromISet] is very fast,
/// since it makes no copies of the given set items, but just uses it directly.
///
/// If you try to use methods that modify the [UnmodifiableSetFromISet], like [add],
/// it will throw an [UnsupportedError].
///
/// If you create it from an [ImmutableSet], it is also very fast to lock the [UnmodifiableSetFromISet]
/// back into an [ImmutableSet].
///
/// <br>
///
/// ## How does it compare to [UnmodifiableSetView] from `package:collection`?
///
/// The only different between an [UnmodifiableSetFromISet] and an [UnmodifiableSetView] is that
/// [UnmodifiableSetFromISet] accepts both a [Set] and an [ImmutableSet]. Note both are views, so they
/// are fast to create, but if you create them from a regular [Set] and then modify that original
/// [Set], you will also be modifying the views. Also note, if you create an
/// [UnmodifiableSetFromISet] from an [ImmutableSet], then it's totally safe because the original [ImmutableSet]
/// can't be modified.
///
/// See also: [ModifiableSetFromISet]
///
@immutable
class UnmodifiableSetFromISet<T extends Object?>
    with SetMixin<T>
    implements Set<T>, CanBeEmpty {
  final ImmutableSet<T>? _iSet;
  final Set<T>? _set;

  /// Create an unmodifiable [Set] view of type [UnmodifiableSetFromISet], from an [iset].
  UnmodifiableSetFromISet(ImmutableSet<T>? iset)
    : _iSet = iset ?? ImmutableSetImplementation<T>.empty(),
      _set = null;

  /// Create an unmodifiable [Set] view of type [UnmodifiableSetFromISet], from another [Set].
  UnmodifiableSetFromISet.fromSet(Set<T> set) : _iSet = null, _set = set;

  @override
  bool add(T value) => throw UnsupportedError("Set is unmodifiable.");

  @override
  bool contains(covariant T? element) =>
      _iSet?.contains(element) ?? _set!.contains(element);

  @override
  T? lookup(covariant T element) =>
      _iSet != null && _iSet.contains(element) ||
          _set != null && _set.contains(element)
      ? element
      : null;

  @override
  bool remove(covariant Object value) =>
      throw UnsupportedError("Set is unmodifiable.");

  @override
  Iterator<T> get iterator => _set?.iterator ?? _iSet!.iterator;

  @override
  Set<T> toSet() => _set ?? _iSet!.toSet();

  @override
  int get length => _iSet?.length ?? _set!.length;

  ImmutableSet<T> get lock => _iSet ?? _set!.lock;
}
