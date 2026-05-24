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
    expect(const ImmutableMap.empty(), isA<ImmutableMapEmpty>());
    expect(const ImmutableMap.empty(), isA<ImmutableMapEmpty>());
    expect(
      const ImmutableMap<String, String>.empty(),
      isA<ImmutableMapEmpty<String, String>>(),
    );
    expect(
      const ImmutableMap<int, String>.empty(),
      isA<ImmutableMap<int, String>>(),
    );

    expect(const ImmutableMap.empty(), isA<ImmutableMap>());
    expect(const ImmutableMap.empty(), isA<ImmutableMap>());
    expect(
      const ImmutableMap<String, String>.empty(),
      isA<ImmutableMap<String, String>>(),
    );
    expect(
      const ImmutableMap<int, String>.empty(),
      isA<ImmutableMap<int, String>>(),
    );
  });

  test("Make sure the IMapEmpty can be modified and later iterated", () {
    // MAddAll
    ImmutableMap<String, int> map = const ImmutableMap.empty();
    map = map.addEntries([
      const MapEntry("a", 1),
      const MapEntry("b", 2),
      const MapEntry("c", 3),
    ]);
    map.forEach((_, __) {});

    // MAdd
    map = const ImmutableMap.empty();
    map = map.add("d", 4);
    map.forEach((_, __) {});

    // MReplace
    map = const ImmutableMap.empty();
    map = map.add("d", 42);
    map.forEach((_, __) {});
  });

  test(
    "Make sure the internal map is Map<int, String>, and not Map<Never>",
    () {
      const m1 = ImmutableMap<String, int>.empty();
      expect(m1.runtimeType.toString(), 'IMapEmpty<String, int>');

      const m2 = ImmutableMapLiteral<String, int>._({'a': 1, 'b': 2, 'c': 3});
      expect(m2.runtimeType.toString(), 'IMapConst<String, int>');

      final m3 = m1.addAll(m2);
      expect(m3.runtimeType.toString(), 'IMapImpl<String, int>');

      final result = m3.where((String key, int value) => value == 2);
      expect(result, {'b': 2}.lock);
    },
  );

  test(".same() is working properly", () {
    expect(const ImmutableMap.empty().same(const ImmutableMap.empty()), isTrue);
    expect(const ImmutableMap.empty().same(const ImmutableMap.empty()), isTrue);
    expect(
      const ImmutableMap.empty().same(const ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({}).same(const ImmutableMap.empty()),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({}).hashCode,
      const ImmutableMap.empty().hashCode,
    );
  });

  test("equality", () {
    // equalItems
    expect(
      ImmutableMap({
        1: "a",
        2: "b",
      }).equalItems(const ImmutableMap.empty().entries),
      isFalse,
    );
    expect(
      const ImmutableMapLiteral._({
        1: "a",
        2: "b",
      }).equalItems(const ImmutableMap.empty().entries),
      isFalse,
    );

    expect(
      ImmutableMap().equalItems(const ImmutableMap.empty().entries),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._(
        {},
      ).equalItems(const ImmutableMap.empty().entries),
      isTrue,
    );
    expect(
      const ImmutableMap.empty().equalItems(const ImmutableMap.empty().entries),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableMap({
        1: "a",
        2: "b",
      }).equalItemsAndConfig(const ImmutableMap.empty()),
      isFalse,
    );
    expect(
      const ImmutableMapLiteral._({
        1: "a",
        2: "b",
      }).equalItemsAndConfig(const ImmutableMap.empty()),
      isFalse,
    );

    expect(
      ImmutableMap().equalItemsAndConfig(const ImmutableMap.empty()),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._(
        {},
      ).equalItemsAndConfig(const ImmutableMap.empty()),
      isTrue,
    );
    expect(
      const ImmutableMap.empty().equalItemsAndConfig(
        const ImmutableMap.empty(),
      ),
      isTrue,
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const ImmutableMap.empty().isEmpty, isTrue);
    expect(const ImmutableMap.empty().isNotEmpty, isFalse);
  });

  test("contains | -Key | -Value | -Entry", () {
    expect(const ImmutableMap.empty().contains(Object(), Object()), isFalse);
    expect(const ImmutableMap.empty().contains(null, null), isFalse);

    expect(const ImmutableMap.empty().containsKey(Object()), isFalse);
    expect(const ImmutableMap.empty().containsKey(null), isFalse);

    expect(const ImmutableMap.empty().containsValue(Object()), isFalse);
    expect(const ImmutableMap.empty().containsValue(null), isFalse);

    expect(
      const ImmutableMap.empty().containsEntry(
        const MapEntry(Object(), Object()),
      ),
      isFalse,
    );
    expect(
      const ImmutableMap.empty().containsEntry(const MapEntry(null, null)),
      isFalse,
    );
  });

  test("length", () {
    expect(const ImmutableMap.empty().length, 0);
  });

  test("clear()", () {
    const list = ImmutableMap.empty();
    expect(identical(list, list.clear()), isTrue);
  });
}
