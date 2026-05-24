// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'dart:collection';

import 'package:fic/src/fic.dart';
import 'package:meta/meta.dart';

/// The [UnmodifiableFromImmutableList] is a relatively safe, unmodifiable [List] view that is built
/// from an [ImmutableList] or another [List]. The construction of the [UnmodifiableFromImmutableList] is very
/// fast, since it makes no copies of the given list items, but just uses it directly.
///
/// If you try to use methods that modify the [UnmodifiableFromImmutableList], like [add],
/// it will throw an [UnsupportedError].
///
/// If you create it from an [ImmutableList], it is also very fast to lock the [UnmodifiableFromImmutableList]
/// back into an [ImmutableList].
///
/// <br>
///
/// ## How does it compare to Dart's native [List.unmodifiable] and [UnmodifiableListView]?
///
/// [List.unmodifiable] is slow, but it's always safe, because *it is not a view*, and
/// actually creates a new list. On the other hand, both [UnmodifiableFromImmutableList] and
/// [UnmodifiableListView] are fast, but if you create them from a regular [List] and then modify
/// that original [List], you will also be modifying the views. Also note, if you create an
/// [UnmodifiableFromImmutableList] from an [ImmutableList], then it's totally safe because the original [ImmutableList]
/// can't be modified.
///
/// The only different between an [UnmodifiableFromImmutableList] and an [UnmodifiableListView] is that
/// [UnmodifiableFromImmutableList] accepts both a [List] and an [ImmutableList].
///
/// See also: [ModifiableFromImmutableList]
///
@immutable
class UnmodifiableFromImmutableList<T extends Object?>
    with ListMixin<T>
    implements List<T>, CanBeEmpty {
  /// Create an unmodifiable [List] view of type [UnmodifiableFromImmutableList], from an [ilist].
  UnmodifiableFromImmutableList(ImmutableList<T>? ilist)
    : _iList = (ilist != null) ? ilist : ImmutableList<T>(),
      _list = null;

  /// Create an unmodifiable [List] view of type [UnmodifiableFromImmutableList], from another [List].
  UnmodifiableFromImmutableList.fromList(List<T> list)
    : _iList = null,
      _list = list;

  final ImmutableList<T>? _iList;
  final List<T>? _list;

  @override
  T operator [](int index) {
    return (_iList != null) ? _iList[index] : _list![index];
  }

  @override
  void operator []=(int index, T? value) =>
      throw UnsupportedError("List in unmodifiable.");

  @override
  int get length => (_iList != null) ? _iList.length : _list!.length;

  @override
  set length(int newLength) => throw UnsupportedError("List in unmodifiable.");

  @override
  void add(T? element) => throw UnsupportedError("List in unmodifiable.");

  @override
  void addAll(Iterable<T> iterable) =>
      throw UnsupportedError("List in unmodifiable.");

  /// Locks the list, returning an *immutable* list ([ImmutableList]).
  ImmutableList<T?>? lock() => (_iList != null) ? _iList : _list!.lock();
}
