// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

import 'package:collection/collection.dart';

/// This works for any object, not only map entries, but `MapEntry` gets special
/// treatment. We consider two map-entries equal when their respective key and
/// values are equal.
class MapEntryEquality<E extends Object?> implements Equality<E> {
  const MapEntryEquality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (identical(e1, e2)) return true;
    return e1 is MapEntry && e2 is MapEntry
        ? e1.key == e2.key && e1.value == e2.value
        : e1 == e2;
  }

  @override
  int hash(Object? e) =>
      (e is MapEntry) ? Object.hash(e.key, e.value) : e.hashCode;

  @override
  bool isValidKey(Object? o) => true;
}
