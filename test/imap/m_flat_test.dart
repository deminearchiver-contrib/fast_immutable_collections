// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:collection/collection.dart';
import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  test("Runtime type", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat, isA<ImmutableMapFlatDelegate<String, int>>());
  });

  test("unlock", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat.unlock, isA<Map<String, int>>());
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2, "c": 3});
    expect(mFlat.unlock, originalMap);
  });

  test("isEmpty | isNotEmpty", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat.isEmpty, isFalse);
    expect(mFlat.isNotEmpty, isTrue);
  });

  test("length", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat.length, 3);
  });

  test("cast", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    final mFlatAsNum = mFlat.cast<String, num>(ImmutableMap.defaultConfig);
    expect(mFlatAsNum, isA<Map<String, num>>());
  });

  test("empty", () {
    final ImmutableMapDelegate<String, int?> empty =
        ImmutableMapFlatDelegate.empty();

    expect(empty.unlock, <String, int>{});
    expect(empty.isEmpty, isTrue);
    expect(empty.isNotEmpty, isFalse);
  });

  test("deepMapHashCode", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat.deepMapHashcode(), MapEquality().hash(originalMap));
  });

  test("deepMapEquals", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);
    expect(mFlat.deepMapEquals(null), isFalse);
    expect(
      mFlat.deepMapEquals(ImmutableMapFlatDelegate<String, int>({})),
      isFalse,
    );
    expect(
      mFlat.deepMapEquals(
        ImmutableMapFlatDelegate<String, int>({"a": 1, "b": 2, "c": 3}),
      ),
      isTrue,
    );
    expect(
      mFlat.deepMapEquals(
        ImmutableMapFlatDelegate<String, int>({"a": 1, "b": 2, "c": 4}),
      ),
      isFalse,
    );
  });

  test("deepMapEqualsToIterable", () {
    const Map<String, int> originalMap = {"a": 1, "b": 2, "c": 3};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate(originalMap);

    final Iterable<MapEntry<String, int>> entries1 = [
          MapEntry<String, int>("b", 2),
          MapEntry<String, int>("a", 1),
          MapEntry<String, int>("c", 3),
        ],
        entries2 = [
          MapEntry<String, int>("a", 1),
          MapEntry<String, int>("b", 2),
        ];

    expect(mFlat.deepMapEqualsToIterable(null), isFalse);
    expect(mFlat.deepMapEqualsToIterable(entries1), isTrue);
    expect(mFlat.deepMapEqualsToIterable(entries2), isFalse);
  });

  test("from", () {
    // 1) Regular usage
    final Map<String, int> original = {"a": 1, "c": 3, "b": 2};
    final ImmutableMapFlatDelegate<String, int> mFlat1 =
        ImmutableMapFlatDelegate.unsafe(original);

    expect(mFlat1.keys.toList(), ["a", "c", "b"]);

    final ImmutableMapFlatDelegate<String, int?> mFlat =
        ImmutableMapFlatDelegate.from(mFlat1);

    expect(mFlat.keys, ["a", "c", "b"]);
  });

  test("unsafe", () {
    final Map<String, int> original = {"a": 1, "c": 3, "b": 2};
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate.unsafe(original);

    expect(mFlat.unlock, original);

    original.addAll({"d": 4});

    expect(original, {"a": 1, "c": 3, "b": 2, "d": 4});
    expect(mFlat.unlock, {"a": 1, "c": 3, "b": 2, "d": 4});
    expect(mFlat.keys.toList(), ["a", "c", "b", "d"]);
  });

  test("entries", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    mFlat.entries.forEach(
      (MapEntry<String, int?> entry) => expect(mFlat[entry.key], entry.value),
    );
  });

  test("keys", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.keys.toSet(), ImmutableList(["a", "b", "c", "d"]).toSet());
  });

  test("values", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.values.toSet(), ImmutableList([1, 2, 3, 4]).toSet());
  });

  test("any", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.any((String key, int? value) => key == "a"), isTrue);
    expect(mFlat.any((String key, int? value) => key == "z"), isFalse);
    expect(mFlat.any((String key, int? value) => value == 4), isTrue);
    expect(mFlat.any((String key, int? value) => value == 100), isFalse);
  });

  test("contains", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.contains("a", 1), isTrue);
    expect(mFlat.contains("a", 2), isFalse);
    expect(mFlat.contains("b", 1), isFalse);
  });

  test("contains", () {
    expect(
      ImmutableMapFlatDelegate(<String, int?>{
        "a": 1,
        "b": 2,
        "c": 3,
        "d": 4,
      }).contains("a", null),
      isFalse,
    );
    expect(
      ImmutableMapFlatDelegate({
        "a": 1,
        "b": 2,
        "c": 3,
        "d": null,
      }).contains("d", null),
      isTrue,
    );
  });

  test("containsKey", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.containsKey("a"), isTrue);
    expect(mFlat.containsKey("z"), isFalse);
  });

  test("containsValue", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat.containsValue(1), isTrue);
    expect(mFlat.containsValue(100), isFalse);
  });

  test("[]", () {
    final ImmutableMapFlatDelegate<String, int> mFlat =
        ImmutableMapFlatDelegate({"a": 1, "b": 2, "c": 3, "d": 4});
    expect(mFlat["a"], 1);
    expect(mFlat["z"], isNull);
  });

  test("Ensuring Immutability", () {
    // 1) add

    // 1.1) Changing the passed mutable map doesn't change the MAdd
    Map<String, int> original = {"a": 1, "b": 2};
    ImmutableMapFlatDelegate<String, int> mFlat = ImmutableMapFlatDelegate(
      original,
    );

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    original.addAll({"c": 3, "d": 4, "e": 5});

    expect(original, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4, "e": 5});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    // 1.2) Adding to the original MFlat doesn't change it
    original = {"a": 1, "b": 2};
    mFlat = ImmutableMapFlatDelegate(original);

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    ImmutableMapDelegate<String, int?> m = mFlat.add(key: "c", value: 3);

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});
    expect(m.unlock, <String, int>{"a": 1, "b": 2, "c": 3});

    // 1.3) If the item being passed is a variable, a pointer to it shouldn't exist inside MAdd
    original = {"a": 1, "b": 2};
    mFlat = ImmutableMapFlatDelegate(original);

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    int willChange = 4;
    m = mFlat.add(key: "c", value: willChange);

    willChange = 5;

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});
    expect(willChange, 5);
    const Map<String, int> finalMap = <String, int>{"a": 1, "b": 2, "c": 4};
    m.unlock.forEach((String key, int? value) => expect(m[key], finalMap[key]));

    // 2) addAll

    // 2.1) Changing the passed immutable map doesn't change the original MFlat
    original = {"a": 1, "b": 2};
    mFlat = ImmutableMapFlatDelegate(original);

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    m = mFlat.addAll(<String, int>{"c": 3, "d": 4}.lock);

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});
    expect(m.unlock, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4});

    // 2.2) If the items being passed are from a variable, it shouldn't have a pointer to the
    // variable
    original = {"a": 1, "b": 2};
    final ImmutableMapFlatDelegate<String, int> mFlat1 =
            ImmutableMapFlatDelegate(original),
        mFlat2 = ImmutableMapFlatDelegate(original);

    expect(mFlat1.unlock, <String, int>{"a": 1, "b": 2});
    expect(mFlat2.unlock, <String, int>{"a": 1, "b": 2});

    m = mFlat1.addAll(ImmutableMap(mFlat2.unlock));
    original.addAll({"z": 5});

    expect(original, <String, int>{"a": 1, "b": 2, "z": 5});
    expect(mFlat1.unlock, <String, int>{"a": 1, "b": 2});
    expect(mFlat2.unlock, <String, int>{"a": 1, "b": 2});
    expect(m.unlock, <String, int>{"a": 1, "b": 2});

    // 3) remove

    // 3.1) Changing the passed mutable map doesn't change the MFlat
    original = {"a": 1, "b": 2};
    mFlat = ImmutableMapFlatDelegate(original);

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    original.remove("b");

    expect(original, <String, int>{"a": 1});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    // 3.2) Removing from the original MFlat doesn't change it
    original = {"a": 1, "b": 2};
    mFlat = ImmutableMapFlatDelegate(original);

    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});

    m = mFlat.remove("b");

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(mFlat.unlock, <String, int>{"a": 1, "b": 2});
    expect(m.unlock, <String, int>{"a": 1});
  });
}
