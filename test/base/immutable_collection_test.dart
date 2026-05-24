// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = true;
    ImmutableCollection.prettyPrint = true;
  });

  test("areSameImmutableCollection()", () {
    // 1) If both are null, then true
    expect(areSameImmutableCollection(null, null), isTrue);

    // 2) If one of them is not null, then false
    expect(areSameImmutableCollection(ImmutableList(), null), isFalse);
    expect(areSameImmutableCollection(null, ImmutableList()), isFalse);

    // 3) If none of them is null, then use .same()

    // 3.1) IList
    ImmutableList<int> iList1 = ImmutableList([1, 2]),
        iList2 = ImmutableList([1, 2]);
    ImmutableList<int> iList3 = iList1.remove(3);

    expect(areSameImmutableCollection(iList1, iList2), isFalse);
    expect(areSameImmutableCollection(iList1, iList3), isTrue);

    // 3.2) ISet
    ImmutableSet<int> iset1 = ImmutableSet([1, 2]),
        iSet2 = ImmutableSet([1, 2]);
    ImmutableSet<int> iset3 = iset1.remove(3);

    expect(areSameImmutableCollection(iset1, iSet2), isFalse);
    expect(areSameImmutableCollection(iset1, iset3), isTrue);

    // 3.3) IMap
    ImmutableMap<String, int> imap1 = ImmutableMap({"a": 1, "b": 2}),
        imap2 = ImmutableMap({"a": 1, "b": 2});
    ImmutableMap<String, int> imap3 = imap1.remove("c");

    expect(areSameImmutableCollection(imap1, imap2), isFalse);
    expect(areSameImmutableCollection(imap1, imap3), isTrue);

    // 3.4) IMapOfSets
    IMapOfSets<String, int> imapOfSets1 = IMapOfSets({
          "a": {1},
          "b": {1, 2},
        }),
        imapOfSets2 = IMapOfSets({
          "a": {1},
          "b": {1, 2},
        });
    IMapOfSets<String, int> imapOfSets3 = imapOfSets1.removeSet("c");

    expect(areSameImmutableCollection(imapOfSets1, imapOfSets2), isFalse);
    expect(areSameImmutableCollection(imapOfSets1, imapOfSets3), isTrue);
  });

  test("areSameImmutableCollection | Different Collections", () {
    ImmutableList<int> ilistA = ImmutableList([1, 2]);
    ImmutableSet<int> isetA = ImmutableSet([1, 2]);
    expect(areSameImmutableCollection(ilistA, isetA), isFalse);
  });

  test(
    "areSameImmutableCollection | "
    "Trying to verify if Dart implicitly checks for the type of the items inside the "
    "[ImmutableCollection]. If it does, then the print inside the 3rd `if` shouldn't be executed.",
    () {
      ImmutableList<int> iListA = ImmutableList([1, 2]);
      ImmutableList<String> iListB = ImmutableList(["a", "b"]);

      expect(
        areSameImmutableCollection(iListA, iListB),
        isFalse,
      ); // throws an error
    },
  );

  test("areImmutableCollectionsWithEqualItems()", () {
    // 1) If both are null, then true
    expect(areImmutableCollectionsWithEqualItems(null, null), isTrue);

    // 2) If one of them is not null, then false
    expect(
      areImmutableCollectionsWithEqualItems(ImmutableList(), null),
      isFalse,
    );
    expect(
      areImmutableCollectionsWithEqualItems(null, ImmutableList()),
      isFalse,
    );

    // 3) If none of them is null, then use .same()
    ImmutableList<int> iList1 = ImmutableList([1, 2]);
    ImmutableList<int> iList2 = ImmutableList([1]).add(2);
    ImmutableList<int> iList3 = iList1.remove(3);
    ImmutableList<int> iList4 = ImmutableList([1, 3]);
    ImmutableSet<int> iSet1 = ImmutableSet([1, 2]);

    expect(areImmutableCollectionsWithEqualItems(iList1, iList2), isTrue);
    expect(areImmutableCollectionsWithEqualItems(iList1, iList3), isTrue);
    expect(areImmutableCollectionsWithEqualItems(iList1, iList4), isFalse);

    expect(
      areImmutableCollectionsWithEqualItems(
        // ignore: unnecessary_cast
        iList1 as ImmutableCollection,
        // ignore: unnecessary_cast
        iSet1 as ImmutableCollection,
      ),
      isFalse,
    );
  });

  test("FicIteratorExtension.toIterable", () {
    const List<int> list = [1, 2, 3];
    final Iterable<int> iterable = list.iterator.toIterable();
    expect(iterable, [1, 2, 3]);
  });

  test("FicIteratorExtension.toList", () {
    const List<int> list = [1, 2, 3];
    final List<int> mutableList = list.iterator.toList();
    final List<int> unmodifiableList = list.iterator.toList(growable: false);

    mutableList.add(4);
    expect(mutableList, [1, 2, 3, 4]);

    expect(unmodifiableList, [1, 2, 3]);
    expect(() => unmodifiableList.add(4), throwsUnsupportedError);
  });

  test("FicIteratorExtension.toSet", () {
    const List<int> list = [1, 2, 3];
    final Set<int> mutableSet = list.iterator.toSet();

    expect(mutableSet, {1, 2, 3});
  });

  test("FicMapIteratorExtension.toIterable", () {
    const List<MapEntry<String, int>> entryList = [
      MapEntry("a", 1),
      MapEntry("b", 2),
      MapEntry("c", 3),
    ];
    final Iterator<MapEntry<String, int>> iterator = entryList.iterator;
    final Iterable<MapEntry<String, int>> iterable = iterator.toIterable();

    expect(iterable.contains(const MapEntry("a", 1)), isTrue);
    expect(iterable.contains(const MapEntry("b", 2)), isTrue);
    expect(iterable.contains(const MapEntry("c", 3)), isTrue);
    expect(iterable.contains(const MapEntry("d", 4)), isFalse);
    expect(iterable.contains(null), isFalse);
  });

  test("FicMapIteratorExtension.toMap", () {
    const List<MapEntry<String, int>> entryList = [
      MapEntry("a", 1),
      MapEntry("b", 2),
      MapEntry("c", 3),
    ];
    final Iterator<MapEntry<String, int>> iterator = entryList.iterator;
    final Map<String, int> map = iterator.toMap();
    expect(map, {"a": 1, "b": 2, "c": 3});
  });

  test("List.toIList() / List.toISet()", () {
    const List<int> list = [1, 2, 3, 3];
    final ImmutableList<int> ilist = list.toIList();
    final ImmutableSet<int> iset = list.toISet();

    expect(ilist, [1, 2, 3, 3]);
    expect(iset, {1, 2, 3});
  });

  test("Set.toIList() / Set.toISet()", () {
    const Set<int> set = {1, 2, 3};
    final ImmutableList<int> ilist = set.toIList();
    final ImmutableSet<int> iset = set.toISet();

    expect(ilist, [1, 2, 3]);
    expect(iset, [1, 2, 3]);
  });

  test("BooleanExtension.compareTo", () {
    // 1) Zero
    expect(true.compareTo(true), 0);
    expect(false.compareTo(false), 0);

    // 2) Greater than zero
    expect(true.compareTo(false), greaterThan(0));
    expect(true.compareTo(false), 1);

    // 3) Less than zero
    expect(false.compareTo(true), lessThan(0));
    expect(false.compareTo(true), -1);
  });

  test("ImmutableCollection.disallowUnsafeConstructors", () {
    // 1) Is initially false
    expect(ImmutableCollection.disallowUnsafeConstructors, isFalse);

    // 2) Changing the default to true
    expect(ImmutableCollection.disallowUnsafeConstructors, isFalse);
    ImmutableCollection.disallowUnsafeConstructors = true;
    expect(ImmutableCollection.disallowUnsafeConstructors, isTrue);
  });

  test("ImmutableCollection.autoFlush", () {
    // 1) default
    expect(ImmutableCollection.autoFlush, isTrue);

    // 2) setter
    expect(ImmutableCollection.autoFlush, isTrue);

    ImmutableCollection.autoFlush = false;

    expect(ImmutableCollection.autoFlush, isFalse);

    ImmutableCollection.autoFlush = true;

    expect(ImmutableCollection.autoFlush, isTrue);
  });

  test("ImmutableCollection.prettyPrint", () {
    // 1) default
    expect(ImmutableCollection.prettyPrint, isTrue);

    // 2) setter
    expect(ImmutableCollection.prettyPrint, isTrue);

    ImmutableCollection.prettyPrint = false;

    expect(ImmutableCollection.prettyPrint, isFalse);

    ImmutableCollection.prettyPrint = true;

    expect(ImmutableCollection.prettyPrint, isTrue);
  });

  test("FicIteratorExtension.toIterable()", () {
    final Iterable<int> iter1 = [1, 2, 3].iterator.toIterable();
    expect(iter1, [1, 2, 3]);

    final Iterable<int> iter2 = <int>[].iterator.toIterable();
    expect(iter2, isEmpty);
  });
}
