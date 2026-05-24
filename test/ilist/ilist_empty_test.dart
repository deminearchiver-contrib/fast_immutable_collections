// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = false;
  });

  test("Runtime Type", () {
    expect(const ImmutableList.emptyLiteral(), isA<ImmutableListEmpty>());
    expect(const ImmutableList.emptyLiteral(), isA<ImmutableListEmpty>());
    expect(
      const ImmutableList<String>.emptyLiteral(),
      isA<ImmutableListEmpty<String>>(),
    );
    expect(
      const ImmutableList<int>.emptyLiteral(),
      isA<ImmutableListEmpty<int>>(),
    );

    expect(const ImmutableList.emptyLiteral(), isA<ImmutableList>());
    expect(const ImmutableList.emptyLiteral(), isA<ImmutableList>());
    expect(
      const ImmutableList<String>.emptyLiteral(),
      isA<ImmutableList<String>>(),
    );
    expect(const ImmutableList<int>.emptyLiteral(), isA<ImmutableList<int>>());
  });

  test("Make sure the IListEmpty can be modified and later iterated", () {
    // LAddAll
    ImmutableList<String> list = const ImmutableList.emptyLiteral();
    list = list.addAll(["a", "b", "c"]);
    list.forEach((_) {});

    // LAdd
    list = const ImmutableList.emptyLiteral();
    list = list.add("d");
    list.forEach((_) {});
  });

  test("Make sure the internal list is List<int>, and not List<Never>", () {
    const l1 = ImmutableList<int>.emptyLiteral();
    expect(l1.runtimeType.toString(), 'IListEmpty<int>');

    const l2 = ImmutableListLiteral<int>._([1, 2, 3]);
    expect(l2.runtimeType.toString(), 'IListConst<int>');

    final l3 = l1.addAll(l2);
    expect(l3.runtimeType.toString(), 'IListImpl<int>');

    final result = l3.where((int i) => i == 2).toList();
    expect(result, [2]);
  });

  test(".same() is working properly", () {
    expect(
      const ImmutableList.emptyLiteral().same(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().same(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().same(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([]).same(const ImmutableList.emptyLiteral()),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([]).hashCode,
      const ImmutableList.emptyLiteral().hashCode,
    );
  });

  test("equality", () {
    // equalItems
    expect(
      ImmutableList(["a", "b"]).equalItems(const ImmutableList.emptyLiteral()),
      isFalse,
    );
    expect(
      const ImmutableListLiteral._([
        "a",
        "b",
      ]).equalItems(const ImmutableList.emptyLiteral()),
      isFalse,
    );

    expect(
      ImmutableList().equalItems(const ImmutableList.emptyLiteral()),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._(
        [],
      ).equalItems(const ImmutableList.emptyLiteral()),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().equalItems(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().equalItems(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableList([
        "a",
        "b",
      ]).equalItemsAndConfig(const ImmutableList.emptyLiteral()),
      isFalse,
    );
    expect(
      const ImmutableListLiteral._([
        "a",
        "b",
      ]).equalItemsAndConfig(const ImmutableList.emptyLiteral()),
      isFalse,
    );

    expect(
      ImmutableList().equalItemsAndConfig(const ImmutableList.emptyLiteral()),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._(
        [],
      ).equalItemsAndConfig(const ImmutableList.emptyLiteral()),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().equalItemsAndConfig(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );
    expect(
      const ImmutableList.emptyLiteral().equalItemsAndConfig(
        const ImmutableList.emptyLiteral(),
      ),
      isTrue,
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const ImmutableList.emptyLiteral().isEmpty, isTrue);
    expect(const ImmutableList.emptyLiteral().isNotEmpty, isFalse);
  });

  test("contains", () {
    expect(const ImmutableList.emptyLiteral().contains(Object()), isFalse);
    expect(const ImmutableList.emptyLiteral().contains(null), isFalse);
  });

  test("length", () {
    expect(const ImmutableList.emptyLiteral().length, 0);
  });

  test("fist | last | single", () {
    expect(() => const ImmutableList.emptyLiteral().first, throwsStateError);
    expect(() => const ImmutableList.emptyLiteral().last, throwsStateError);
    expect(() => const ImmutableList.emptyLiteral().single, throwsStateError);
  });

  test("reversed", () {
    const list = ImmutableList.emptyLiteral();
    expect(identical(list, list.reversed), isTrue);
  });

  test("clear()", () {
    const list = ImmutableList.emptyLiteral();
    expect(identical(list, list.clear()), isTrue);
  });
}
