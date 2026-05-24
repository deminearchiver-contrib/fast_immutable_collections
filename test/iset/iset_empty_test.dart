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
    expect(const ImmutableSet.empty(), isA<ImmutableSetEmpty>());
    expect(const ImmutableSet.empty(), isA<ImmutableSetEmpty>());
    expect(
      const ImmutableSet<String>.empty(),
      isA<ImmutableSetEmpty<String>>(),
    );
    expect(const ImmutableSet<int>.empty(), isA<ImmutableSetEmpty<int>>());

    expect(const ImmutableSet.empty(), isA<ImmutableSet>());
    expect(const ImmutableSet.empty(), isA<ImmutableSet>());
    expect(const ImmutableSet<String>.empty(), isA<ImmutableSet<String>>());
    expect(const ImmutableSet<int>.empty(), isA<ImmutableSet<int>>());
  });

  test("Make sure the ISetEmpty can be modified and later iterated", () {
    // SAddAll
    ImmutableSet<String> set = const ImmutableSet.empty();
    set = set.addAll(["a", "b", "c"]);
    set.forEach((_) {});

    // SAdd
    set = const ImmutableSet.empty();
    set = set.add("d");
    set.forEach((_) {});
  });

  test("Make sure the internal set is Set<int>, and not Set<Never>", () {
    const s1 = ImmutableSet<int>.empty();
    expect(s1.runtimeType.toString(), 'ISetEmpty<int>');

    const s2 = ImmutableSet<int>.literal({1, 2, 3});
    expect(s2.runtimeType.toString(), 'ISetConst<int>');

    final s3 = s1.addAll(s2);
    expect(s3.runtimeType.toString(), 'ISetImpl<int>');

    final result = s3.where((int i) => i == 2).toSet();
    expect(result, [2]);
  });

  test(".same() is working properly", () {
    expect(const ImmutableSet.empty().same(const ImmutableSet.empty()), isTrue);
    expect(const ImmutableSet.empty().same(const ImmutableSet.empty()), isTrue);
    expect(
      const ImmutableSet.empty().same(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({}).same(const ImmutableSet.empty()),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({}).hashCode,
      const ImmutableSet.empty().hashCode,
    );
  });

  test("equality", () {
    // equalItems
    expect(
      ImmutableSet({"a", "b"}).equalItems(const ImmutableSet.empty()),
      isFalse,
    );
    expect(
      const ImmutableSet.literal({
        "a",
        "b",
      }).equalItems(const ImmutableSet.empty()),
      isFalse,
    );

    expect(ImmutableSet().equalItems(const ImmutableSet.empty()), isTrue);
    expect(
      const ImmutableSet.literal({}).equalItems(const ImmutableSet.empty()),
      isTrue,
    );
    expect(
      const ImmutableSet.empty().equalItems(const ImmutableSet.empty()),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableSet({"a", "b"}).equalItemsAndConfig(const ImmutableSet.empty()),
      isFalse,
    );
    expect(
      const ImmutableSet.literal({
        "a",
        "b",
      }).equalItemsAndConfig(const ImmutableSet.empty()),
      isFalse,
    );

    expect(
      ImmutableSet().equalItemsAndConfig(const ImmutableSet.empty()),
      isTrue,
    );
    expect(
      const ImmutableSet.literal(
        {},
      ).equalItemsAndConfig(const ImmutableSet.empty()),
      isTrue,
    );
    expect(
      const ImmutableSet.empty().equalItemsAndConfig(
        const ImmutableSet.empty(),
      ),
      isTrue,
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const ImmutableSet.empty().isEmpty, isTrue);
    expect(const ImmutableSet.empty().isNotEmpty, isFalse);
  });

  test("contains", () {
    expect(const ImmutableSet.empty().contains(Object()), isFalse);
    expect(const ImmutableSet.empty().contains(null), isFalse);
  });

  test("length", () {
    expect(const ImmutableSet.empty().length, 0);
  });

  test("fist | last | single", () {
    expect(() => const ImmutableSet.empty().first, throwsStateError);
    expect(() => const ImmutableSet.empty().last, throwsStateError);
    expect(() => const ImmutableSet.empty().single, throwsStateError);
  });

  test("clear()", () {
    const list = ImmutableSet.empty();
    expect(identical(list, list.clear()), isTrue);
  });
}
