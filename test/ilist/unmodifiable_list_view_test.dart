// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  test("Simple Empty Initialization", () {
    expect(UnmodifiableFromImmutableList([].lock).isEmpty, isTrue);
    expect(UnmodifiableFromImmutableList(null).isEmpty, isTrue);
  });

  test("[]", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach((UnmodifiableFromImmutableList<int> view) {
      expect(view[0], 1);
      expect(view[1], 2);
      expect(view[2], 3);
    });
  });

  test("length", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(view.length, baseList.length),
    );
  });

  test("lock", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(view.lock, allOf(isA<ImmutableList<int>>(), baseList)),
    );
  });

  test("isEmpty | isNotEmpty", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach((UnmodifiableFromImmutableList<int> view) {
      expect(view.isEmpty, isFalse);
      expect(view.isNotEmpty, isTrue);
    });
  });

  test("[]=", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(() => view[0] = 10, throwsUnsupportedError),
    );
  });

  test("length", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(() => view.length = 10, throwsUnsupportedError),
    );
  });

  test("add", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(() => view.add(4), throwsUnsupportedError),
    );
  });

  test("addAll", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(() => view.addAll([4, 5]), throwsUnsupportedError),
    );
  });

  test("remove", () {
    const List<int> baseList = [1, 2, 3];
    final UnmodifiableFromImmutableList<int> unmodifiableListView =
            UnmodifiableFromImmutableList(baseList.lock),
        unmodifiableListViewFromList = UnmodifiableFromImmutableList.fromList(
          baseList,
        );
    final List<UnmodifiableFromImmutableList<int>> views = [
      unmodifiableListView,
      unmodifiableListViewFromList,
    ];

    views.forEach(
      (UnmodifiableFromImmutableList<int> view) =>
          expect(() => view.remove(3), throwsUnsupportedError),
    );
  });
}
