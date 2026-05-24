// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  //
  test("Simple Empty Initialization", () {
    expect(ModifiableFromImmutableList([].lock).isEmpty, isTrue);
    expect(ModifiableFromImmutableList(null).isEmpty, isTrue);
  });

  test("[]", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    expect(modifiableListView[0], 1);
    expect(modifiableListView[1], 2);
    expect(modifiableListView[2], 3);
  });

  test("length", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    expect(modifiableListView.length, 3);
  });

  test("lock", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    expect(modifiableListView.lock, isA<ImmutableList<int>>());
    expect(modifiableListView.lock, [1, 2, 3]);
  });

  test("isEmpty | isNotEmpty", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    expect(modifiableListView.isEmpty, isFalse);
    expect(modifiableListView.isNotEmpty, isTrue);
  });

  test("[]= operator", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    modifiableListView[2] = 4;
    expect(modifiableListView.length, 3);
    expect(modifiableListView[2], 4);
  });

  test("length setter", () {
    final ImmutableList<int?> nullableIlist = [null, 1, 2, 3].lock;
    final ModifiableFromImmutableList<int?> modifiableListViewNullable =
        ModifiableFromImmutableList(nullableIlist);

    // Make it smaller.
    modifiableListViewNullable.length = 2;
    expect(modifiableListViewNullable.length, 2);

    // Make it bigger.
    modifiableListViewNullable.length = 4;
    expect(modifiableListViewNullable.length, 4);

    // ---
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int?> modifiableListView =
        ModifiableFromImmutableList(ilist);

    // Make it smaller.
    modifiableListView.length = 2;
    expect(modifiableListView.length, 2);

    // Try to make it bigger, but fails (not nullable)
    expect(() => modifiableListView.length = 4, throwsTypeError);
  });

  test("add", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    modifiableListView.add(4);
    expect(modifiableListView.length, 4);
    expect(modifiableListView.last, 4);
  });

  test("addAll", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    modifiableListView.addAll([4, 5]);
    expect(modifiableListView.length, 5);
    expect(modifiableListView[3], 4);
    expect(modifiableListView[4], 5);
  });

  test("remove", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    final ModifiableFromImmutableList<int> modifiableListView =
        ModifiableFromImmutableList(ilist);
    modifiableListView.remove(2);
    expect(modifiableListView.length, 2);
    expect(modifiableListView[0], 1);
    expect(modifiableListView[1], 3);
  });
}
