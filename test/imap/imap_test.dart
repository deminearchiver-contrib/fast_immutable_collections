// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'dart:collection';

import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = false;
  });

  test("Runtime Type", () {
    expect(ImmutableMap(), isA<ImmutableMap>());
    expect(ImmutableMap({}), isA<ImmutableMap>());
    expect(ImmutableMap<String, int>({}), isA<ImmutableMap<String, int>>());
    expect(ImmutableMap({"a": 1}), isA<ImmutableMap<String, int>>());
    expect(
      ImmutableMapImplementation.empty<String, int>(),
      isA<ImmutableMap<String, int>>(),
    );
    expect(const ImmutableMap.empty(), isA<ImmutableMap>());
    expect(
      const ImmutableMap<String, int>.empty(),
      isA<ImmutableMap<String, int>>(),
    );
    const ImmutableMap untypedMap = ImmutableMap.empty();
    expect(untypedMap, isA<ImmutableMap>());
    const ImmutableMap<String, int> typedMap = ImmutableMap.empty();
    expect(typedMap, isA<ImmutableMap<String, int>>());
  });

  test("isEmpty | isNotEmpty", () {
    expect(ImmutableMap().isEmpty, isTrue);
    expect(ImmutableMap({}).isEmpty, isTrue);
    expect(ImmutableMap<String, int>({}).isEmpty, isTrue);
    expect(ImmutableMap({"a": 1}).isEmpty, isFalse);
    expect(ImmutableMapImplementation.empty<String, int>().isEmpty, isTrue);
    expect(const ImmutableMap.empty().isEmpty, isTrue);
    expect(const ImmutableMap<String, int>.empty().isEmpty, isTrue);

    expect(ImmutableMap().isNotEmpty, isFalse);
    expect(ImmutableMap({}).isNotEmpty, isFalse);
    expect(ImmutableMap<String, int>({}).isNotEmpty, isFalse);
    expect(ImmutableMap({"a": 1}).isNotEmpty, isTrue);
    expect(ImmutableMapImplementation.empty<String, int>().isNotEmpty, isFalse);
    expect(const ImmutableMap.empty().isNotEmpty, isFalse);
    expect(const ImmutableMap<String, int>.empty().isNotEmpty, isFalse);
  });

  test("unlock", () {
    final Map<String, int> map = {"a": 1, "b": 2};
    final ImmutableMap<String, int> imap = ImmutableMap(map);
    expect(imap.unlock, map);
    expect(identical(imap.unlock, map), isFalse);
  });

  test("unlockSorted", () {
    final ImmutableMap<String, int> imap = {
      "c": 3,
      "a": 1,
      "b": 2,
    }.lock.withConfig(ImmutableMapConfig(sort: false));

    expect(
      imap.unlockSorted,
      allOf(isA<LinkedHashMap<String, int>>(), {"a": 1, "b": 2, "c": 3}),
    );
  });

  test("unlockView", () {
    final Map<String, int> unmodifiableMapView = {
      "a": 1,
      "b": 2,
    }.lock.unlockView;

    expect(
      unmodifiableMapView,
      allOf(
        isA<Map<String, int>>(),
        isA<UnmodifiableMapFromIMap<String, int>>(),
        {"a": 1, "b": 2},
      ),
    );
  });

  test("unlockLazy", () {
    final Map<String, int> modifiableMapView = {"a": 1, "b": 2}.lock.unlockLazy;

    expect(
      modifiableMapView,
      allOf(
        isA<Map<String, int>>(),
        isA<ModifiableMapFromIMap<String, int>>(),
        {"a": 1, "b": 2},
      ),
    );
  });

  test("fromEntries", () {
    // 1) Regular usage
    const List<MapEntry<String, int>> entries = [
      MapEntry<String, int>("a", 1),
      MapEntry<String, int>("b", 2),
    ];
    final ImmutableMap<String, int> fromEntries = ImmutableMap.fromEntries(
      entries,
    );

    expect(fromEntries["a"], 1);
    expect(fromEntries["b"], 2);

    // 2) Sorting
    var imap1 = ImmutableMap.fromEntries([
      MapEntry("c", 3),
      MapEntry("a", 1),
      MapEntry("b", 2),
    ], config: ImmutableMapConfig(sort: false));

    var imap2 = ImmutableMap.fromEntries([
      MapEntry("c", 3),
      MapEntry("a", 1),
      MapEntry("b", 2),
    ], config: ImmutableMapConfig(sort: true));

    expect(imap1.keys, ["c", "a", "b"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("fromKeys", () {
    // 1) Regular usage
    List<String?> keys = ["a", "b"];
    final ImmutableMap<String?, int> fromKeys = ImmutableMap.fromKeys(
      keys: keys,
      valueMapper: (String? key) => key.hashCode,
    );

    expect(fromKeys["a"], "a".hashCode);
    expect(fromKeys["b"], "b".hashCode);

    // 2) Sorting
    var imap1 = ImmutableMap.fromKeys(
      keys: ["c", "b", "a"],
      valueMapper: (dynamic key) => 1,
      config: ImmutableMapConfig(sort: false),
    );

    var imap2 = ImmutableMap.fromKeys(
      keys: ["c", "b", "a"],
      valueMapper: (dynamic key) => 1,
      config: ImmutableMapConfig(sort: true),
    );

    expect(imap1.keys, ["c", "b", "a"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("fromValues", () {
    // 1) Regular usage
    const List<int> values = [1, 2];
    final ImmutableMap<String, int> fromKeys = ImmutableMap.fromValues(
      values: values,
      keyMapper: (int value) => value.toString(),
    );

    expect(fromKeys["1"], 1);
    expect(fromKeys["2"], 2);

    // 2) Sorting
    var imap1 = ImmutableMap.fromValues(
      keyMapper: (dynamic value) {
        if (value == 1)
          return "a";
        else if (value == 2)
          return "b";
        else if (value == 3)
          return "c";
        else
          throw Exception();
      },
      values: [3, 1, 2],
      config: ImmutableMapConfig(sort: false),
    );

    var imap2 = ImmutableMap.fromValues(
      keyMapper: (dynamic value) {
        if (value == 1)
          return "a";
        else if (value == 2)
          return "b";
        else if (value == 3)
          return "c";
        else
          throw Exception();
      },
      values: [3, 1, 2],
      config: ImmutableMapConfig(sort: true),
    );

    expect(imap1.keys, ["c", "a", "b"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("fromIterable", () {
    // 1) Regular usage
    const Iterable<int> iterable = [1, 2];
    ImmutableMap fromIterable = ImmutableMap.fromIterable(
      iterable,
      keyMapper: (int key) => (key + 1).toString(),
      valueMapper: (dynamic value) => value + 2,
    );

    expect(fromIterable["2"], 3);
    expect(fromIterable["3"], 4);

    // 2) if no mappers are passed, the identity function is used
    fromIterable = ImmutableMap.fromIterable([1, 2]);

    expect(fromIterable[1], 1);
    expect(fromIterable[2], 2);

    // 3) Sorting
    var imap1 = ImmutableMap.fromIterable(
      [3, 1, 2],
      keyMapper: (dynamic value) {
        if (value == 1)
          return "a";
        else if (value == 2)
          return "b";
        else if (value == 3)
          return "c";
        else
          throw Exception();
      },
      valueMapper: (dynamic value) => value,
      config: ImmutableMapConfig(sort: false),
    );

    var imap2 = ImmutableMap.fromIterable(
      [3, 1, 2],
      keyMapper: (dynamic value) {
        if (value == 1)
          return "a";
        else if (value == 2)
          return "b";
        else if (value == 3)
          return "c";
        else
          throw Exception();
      },
      valueMapper: (dynamic value) => value,
      config: ImmutableMapConfig(sort: true),
    );

    expect(imap1.keys, ["c", "a", "b"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("fromIterables", () {
    // 1) Regular usage
    Iterable<String> keys = ["a", "c", "b"];
    Iterable<int> values = [1, 5, 2];

    ImmutableMap<String, int> imap = ImmutableMap.fromIterables(
      keys,
      values,
      config: ImmutableMapConfig(sort: false),
    );
    expect(imap["a"], 1);
    expect(imap["c"], 5);
    expect(imap["b"], 2);
    expect(imap.keys, ["a", "c", "b"]);

    imap = ImmutableMap.fromIterables(
      keys,
      values,
      config: ImmutableMapConfig(sort: true),
    );
    expect(imap["a"], 1);
    expect(imap["c"], 5);
    expect(imap["b"], 2);
    expect(imap.keys, ["a", "b", "c"]);

    // 2) Sorting
    var imap1 = ImmutableMap.fromIterables(
      ["c", "b", "a"],
      [3, 1, 2],
      config: ImmutableMapConfig(sort: false),
    );

    var imap2 = ImmutableMap.fromIterables(
      ["c", "b", "a"],
      [3, 1, 2],
      config: ImmutableMapConfig(sort: true),
    );

    expect(imap1.keys, ["c", "b", "a"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("orNull", () {
    // 1) Null -> Null
    Map<String, int>? map;
    expect(ImmutableMap.orNull(map), isNull);

    // 2) Map -> IMap
    map = {"a": 1, "b": 2, "c": 3};
    expect(ImmutableMap.orNull(map)?.unlock, {"a": 1, "b": 2, "c": 3});

    // 3) Map with Config -> IMap with Config
    ImmutableMap<String, int>? imap = ImmutableMap.orNull(
      map,
      ImmutableMapConfig(isDeepEquals: false),
    );
    expect(imap?.unlock, {"a": 1, "b": 2, "c": 3});
    expect(imap?.config, ImmutableMapConfig(isDeepEquals: false));
  });

  test("empty", () {
    // 1) Regular usage
    var imap = ImmutableMapImplementation.empty();

    expect(imap, isEmpty);
    expect(imap.unlock, {});
    expect(imap.config, ImmutableMapConfig());

    // 2) With another config
    imap = ImmutableMapImplementation.empty(ImmutableMapConfig(sort: true));

    expect(imap.config, ImmutableMapConfig(sort: true));
  });

  test("unsafe", () {
    // 1) Normal usage
    Map<String, int> map = {"a": 1, "b": 2};
    final ImmutableMap<String, int> imap = ImmutableMap.unsafe(
      map,
      config: ImmutableMapConfig(),
    );

    expect(map, {"a": 1, "b": 2});
    expect(imap.unlock, {"a": 1, "b": 2});

    map.addAll({"c": 3});

    expect(map, {"a": 1, "b": 2, "c": 3});
    expect(imap.unlock, {"a": 1, "b": 2, "c": 3});

    // 2) Disallowing it
    ImmutableCollection.disallowUnsafeConstructors = true;
    map = {"a": 1, "b": 2};

    expect(
      () => ImmutableMap.unsafe(map, config: ImmutableMapConfig()),
      throwsUnsupportedError,
    );
  });

  test("isIdentityEquals and IMap.isDeepEquals properties", () {
    final ImmutableMap<String, int> iMap1 = ImmutableMap({"a": 1, "b": 2}),
        iMap2 = ImmutableMap({"a": 1, "b": 2}).withIdentityEquals;

    expect(iMap1.isIdentityEquals, isFalse);
    expect(iMap1.isDeepEquals, isTrue);
    expect(iMap2.isIdentityEquals, isTrue);
    expect(iMap2.isDeepEquals, isFalse);
  });

  test("==", () {
    // 1) IMap with identity-equals compares the map instance, not the items
    var myMap = ImmutableMap({"a": 1, "b": 2}).withIdentityEquals;
    expect(myMap == myMap, isTrue);
    expect(myMap == ImmutableMap({"a": 1, "b": 2}).withIdentityEquals, isFalse);
    expect(myMap == {"a": 1, "b": 2}.lock.withIdentityEquals, isFalse);
    expect(
      myMap == ImmutableMap({"a": 1, "b": 2, "c": 3}).withIdentityEquals,
      isFalse,
    );

    // 2) IMap with deep-equals compares the items, not the map instance
    myMap = ImmutableMap({"a": 1, "b": 2}).withDeepEquals;
    expect(myMap == myMap, isTrue);
    expect(myMap == ImmutableMap({"b": 2}).add("a", 1).withDeepEquals, isTrue);
    expect(myMap == ImmutableMap({"a": 1, "b": 2}).withDeepEquals, isTrue);
    expect(myMap == {"a": 1, "b": 2}.lock.withDeepEquals, isTrue);
    expect(
      myMap == ImmutableMap({"a": 1, "b": 2, "c": 3}).withDeepEquals,
      isFalse,
    );

    myMap = ImmutableMap({"a": 1, "b": 2});
    expect(myMap == myMap, isTrue);
    expect(myMap == ImmutableMap({"a": 1, "b": 2}), isTrue);
    expect(myMap == ImmutableMap({"a": 1, "b": 2, "c": 3}), isFalse);

    // 3) IMap with deep-equals is always different from imap with identity-equals
    expect(
      ImmutableMap({"a": 1, "b": 2}).withDeepEquals ==
          ImmutableMap({"a": 1, "b": 2}).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableMap({"a": 1, "b": 2}).withIdentityEquals ==
          ImmutableMap({"a": 1, "b": 2}).withDeepEquals,
      isFalse,
    );
    expect(
      ImmutableMap({"a": 1, "b": 2}).withIdentityEquals ==
          ImmutableMap({"a": 1, "b": 2}),
      isFalse,
    );
    expect(
      ImmutableMap({"a": 1, "b": 2}) ==
          ImmutableMap({"a": 1, "b": 2}).withIdentityEquals,
      isFalse,
    );
  });

  test("same", () {
    final ImmutableMap<String, int> iMap1 = ImmutableMap({"a": 1, "b": 2});
    expect(iMap1.same(iMap1), isTrue);
    expect(iMap1.same(ImmutableMap({"a": 1, "b": 2})), isFalse);
    expect(iMap1.same(ImmutableMap({"a": 1})), isFalse);
    expect(iMap1.same(ImmutableMap({"b": 2}).add("a", 1)), isFalse);
    expect(
      iMap1.same(ImmutableMap({"a": 1, "b": 2}).withIdentityEquals),
      isFalse,
    );
    expect(iMap1.same(iMap1.remove("c")), isTrue);
  });

  test("equalItemsAndConfig", () {
    final ImmutableMap<String, int> iMap1 = ImmutableMap({"a": 1, "b": 2});
    expect(iMap1.equalItemsAndConfig(iMap1), isTrue);
    expect(iMap1.equalItemsAndConfig(ImmutableMap({"a": 1, "b": 2})), isTrue);
    expect(iMap1.equalItemsAndConfig(ImmutableMap({"a": 1})), isFalse);
    expect(
      iMap1.equalItemsAndConfig(ImmutableMap({"b": 2}).add("a", 1)),
      isTrue,
    );
    expect(
      iMap1.equalItemsAndConfig(
        ImmutableMap({"a": 1, "b": 2}).withIdentityEquals,
      ),
      isFalse,
    );
    expect(iMap1.equalItemsAndConfig(iMap1.remove("c")), isTrue);
  });

  test("equalItems", () {
    // 1) Identity
    final Iterable<MapEntry<String, int>> iterable1 = [
      MapEntry<String, int>("a", 1),
      MapEntry<String, int>("b", 2),
    ];
    expect(ImmutableMap({"a": 1, "b": 2}).equalItems(iterable1), isTrue);

    // 2) The order doesn't matter
    final Iterable<MapEntry<String, int>> iterable4 = [
      MapEntry<String, int>("b", 2),
      MapEntry<String, int>("a", 1),
    ];
    expect(ImmutableMap({"a": 1, "b": 2}).equalItems(iterable4), isTrue);

    // 3) Different items yield false
    final Iterable<MapEntry<String, int>> iterable3 = [
      MapEntry<String, int>("a", 1),
    ];
    expect(ImmutableMap({"a": 1, "b": 2}).equalItems(iterable3), isFalse);
  });

  test("equalItemsToMap", () {
    final ImmutableMap<String, int> imap = ImmutableMap({"a": 1, "b": 2});
    expect(imap.equalItemsToMap({"a": 1, "b": 2}), isTrue);
    expect(imap.equalItemsToMap({"a": 1, "b": 3}), isFalse);
    expect(imap.equalItemsToMap({"a": 1, "c": 2}), isFalse);
    expect(imap.equalItemsToMap({"a": 1, "b": 2, "c": 3}), isFalse);
  });

  test("hashCode", () {
    // 1) deepEquals vs deepEquals
    final ImmutableMap<String, int> iMap1 = ImmutableMap({"a": 1, "b": 2});
    expect(iMap1 == ImmutableMap({"a": 1, "b": 2}), isTrue);
    expect(iMap1 == ImmutableMap({"a": 1, "b": 2, "c": 3}), isFalse);
    expect(iMap1 == ImmutableMap({"b": 2}).add("a", 1), isTrue);
    expect(iMap1.hashCode, ImmutableMap({"a": 1, "b": 2}).hashCode);
    expect(
      iMap1.hashCode,
      isNot(ImmutableMap({"a": 1, "b": 2, "c": 3}).hashCode),
    );
    expect(iMap1.hashCode, ImmutableMap({"b": 2}).add("a", 1).hashCode);

    // 2) identityEquals vs identityEquals
    final ImmutableMap<String, int> iMap1WithIdentity = ImmutableMap({
      "a": 1,
      "b": 2,
    }).withIdentityEquals;
    expect(
      iMap1WithIdentity == ImmutableMap({"a": 1, "b": 2}).withIdentityEquals,
      isFalse,
    );
    expect(
      iMap1WithIdentity ==
          ImmutableMap({"a": 1, "b": 2, "c": 3}).withIdentityEquals,
      isFalse,
    );
    expect(
      iMap1WithIdentity ==
          ImmutableMap({"b": 2}).add("a", 1).withIdentityEquals,
      isFalse,
    );
    expect(
      iMap1WithIdentity.hashCode,
      isNot(ImmutableMap({"a": 1, "b": 2}).withIdentityEquals.hashCode),
    );
    expect(
      iMap1WithIdentity.hashCode,
      isNot(ImmutableMap({"a": 1, "b": 2, "c": 3}).withIdentityEquals.hashCode),
    );
    expect(
      iMap1WithIdentity.hashCode,
      isNot(ImmutableMap({"b": 2}).add("a", 1).withIdentityEquals.hashCode),
    );

    // 3) deepEquals vs identityEquals
    expect(
      ImmutableMap({"a": 1, "b": 2}) ==
          ImmutableMap({"a": 1, "b": 2}).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableMap({"a": 1, "b": 2, "c": 3}) ==
          ImmutableMap({"a": 1, "b": 2, "c": 3}).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableMap({"b": 2}).add("a", 1) ==
          ImmutableMap({"b": 2}).add("a", 1).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableMap({"a": 1, "b": 2}).hashCode,
      isNot(ImmutableMap({"a": 1, "b": 2}).withIdentityEquals.hashCode),
    );
    expect(
      ImmutableMap({"a": 1, "b": 2, "c": 3}).hashCode,
      isNot(ImmutableMap({"a": 1, "b": 2, "c": 3}).withIdentityEquals.hashCode),
    );
    expect(
      ImmutableMap({"b": 2}).add("a", 1).hashCode,
      isNot(ImmutableMap({"b": 2}).add("a", 1).withIdentityEquals.hashCode),
    );

    // 4) When cache is on
    ImmutableCollection.disallowUnsafeConstructors = false;

    Map<String, int> map = {"a": 1, "b": 2};

    final ImmutableMap<String, int> iMapWithCache = ImmutableMap.unsafe(
      map,
      config: ImmutableMapConfig(cacheHashCode: true),
    );

    int hashBefore = iMapWithCache.hashCode;

    map.addAll({"c": 3});

    int hashAfter = iMapWithCache.hashCode;

    expect(hashAfter, hashBefore);

    // 5) When cache is off
    ImmutableCollection.disallowUnsafeConstructors = false;

    map = {"a": 1, "b": 2};

    final ImmutableMap<String, int> iMapWithoutCache = ImmutableMap.unsafe(
      map,
      config: ImmutableMapConfig(cacheHashCode: false),
    );

    hashBefore = iMapWithoutCache.hashCode;

    map.addAll({"c": 3});

    hashAfter = iMapWithoutCache.hashCode;

    expect(hashAfter, isNot(hashBefore));
  });

  test("withConfig", () {
    // 1) Regular usage
    final ImmutableMap<String, int> imap = ImmutableMap({"a": 1, "b": 2});

    expect(imap.isDeepEquals, isTrue);
    expect(imap.config.sort, isFalse);

    final ImmutableMap<String, int> iMapWithCompare = imap.withConfig(
      imap.config.copyWith(sort: true),
    );

    expect(iMapWithCompare.isDeepEquals, isTrue);
    expect(iMapWithCompare.config.sort, isTrue);

    // 2) Sorting
    ImmutableMap<String, int> imap1 = ImmutableMap({
      "c": 3,
      "a": 1,
      "b": 2,
    }).withConfig(ImmutableMapConfig(sort: false));
    ImmutableMap<String, int> imap2 = ImmutableMap({
      "c": 3,
      "a": 1,
      "b": 2,
    }).withConfig(ImmutableMapConfig(sort: true));

    expect(imap1.keys, ["c", "a", "b"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("withConfig factory", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = ImmutableMap.withConfig({
      "a": 1,
      "b": 2,
    }, ImmutableMapConfig(isDeepEquals: false));
    expect(imap.unlock, {"a": 1, "b": 2});
    expect(imap.config, const ImmutableMapConfig(isDeepEquals: false));

    // 2) Sorting
    Map<String, int> map = {"c": 3, "a": 1, "b": 2};
    ImmutableMap<String, int> imap1 = ImmutableMap.withConfig(
      map,
      ImmutableMapConfig(sort: false),
    );
    ImmutableMap<String, int> imap2 = ImmutableMap.withConfig(
      map,
      ImmutableMapConfig(sort: true),
    );

    expect(imap1.keys, ["c", "a", "b"]);
    expect(imap2.keys, ["a", "b", "c"]);
  });

  test("Changing configs", () {
    var imap1 = ImmutableMap.withConfig(
      {"a": 1, "c": 3, "b": 2},
      ImmutableMapConfig(sort: true),
    ).withConfig(ImmutableMapConfig(sort: true));
    expect(imap1.keys, ["a", "b", "c"]);
    expect(imap1.values, [1, 2, 3]);

    var imap2 = ImmutableMap.withConfig(
      {"a": 1, "c": 3, "b": 2},
      ImmutableMapConfig(sort: true),
    ).withConfig(ImmutableMapConfig(sort: false));
    expect(imap2.keys, ["a", "b", "c"]);
    expect(imap2.values, [1, 2, 3]);

    var imap3 = ImmutableMap.withConfig(
      {"a": 1, "c": 3, "b": 2},
      ImmutableMapConfig(sort: false),
    ).withConfig(ImmutableMapConfig(sort: true));
    expect(imap3.keys, ["a", "b", "c"]);
    expect(imap3.values, [1, 2, 3]);

    var imap4 = ImmutableMap.withConfig(
      {"a": 1, "c": 3, "b": 2},
      ImmutableMapConfig(sort: false),
    ).withConfig(ImmutableMapConfig(sort: false));
    expect(imap4.keys, ["a", "c", "b"]);
    expect(imap4.values, [1, 3, 2]);
  });

  test("withConfigFrom", () {
    final ImmutableMap<String, int> iMap1 = ImmutableMap({"a": 1, "b": 2});
    final ImmutableMap<String, int> iMap2 = ImmutableMap.withConfig({
      "a": 1,
      "b": 2,
    }, ImmutableMapConfig(isDeepEquals: false));

    expect(iMap1.isDeepEquals, isTrue);
    expect(iMap1.config.sort, isFalse);

    expect(iMap2.isDeepEquals, isFalse);
    expect(iMap2.config.sort, isFalse);

    final ImmutableMap<String, int> iMap3 = iMap1.withConfigFrom(iMap2);

    expect(iMap3.isDeepEquals, isFalse);
    expect(iMap3.config.sort, isFalse);

    expect(iMap1.unlock, {"a": 1, "b": 2});
    expect(iMap2.unlock, {"a": 1, "b": 2});
    expect(iMap3.unlock, {"a": 1, "b": 2});

    // 3) Sorting
    ImmutableMap<String, int> originalIMap = {"c": 3, "a": 1, "b": 2}.lock;
    ImmutableMap<String, int> originalIMapWithSort = {
      "c": 3,
      "a": 1,
      "b": 2,
    }.lock.withConfig(ImmutableMapConfig(sort: true));
    ImmutableMap<String, int> imapWithSortFromConfig = originalIMap
        .withConfigFrom(originalIMapWithSort);

    expect(originalIMap.keys, ["c", "a", "b"]);
    expect(originalIMapWithSort.keys, ["a", "b", "c"]);
    expect(imapWithSortFromConfig.keys, ["a", "b", "c"]);
  });

  test("default constructor", () {
    final Map<String, int> map = {"a": 1, "b": 2, "c": 3};
    final ImmutableMap<String, int> imap = ImmutableMap(map);

    expect(imap.unlock, map);
    expect(identical(imap.unlock, map), isFalse);
  });

  test("flush", () {
    final ImmutableMap<String, int> imap = {"a": 1, "b": 2, "c": 3}.lock
        .add("d", 4)
        .addMap({"f": 6, "e": 5})
        .add("g", 7)
        .addMap({})
        .addAll(ImmutableMap({"h": 8, "i": 9}));

    expect(imap.isFlushed, isFalse);

    imap.flush;

    expect(imap.isFlushed, isTrue);
    expect(imap.unlock, {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
      "g": 7,
      "h": 8,
      "i": 9,
    });
  });

  test("add", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.add("c", 3);

    expect(newIMap.unlock, {"a": 1, "b": 2, "c": 3});

    // 2) Adding the same item overwrites it
    imap = ImmutableMapImplementation.empty<String, int>().withDeepEquals;
    ImmutableMap<String, int> newMap = imap.add("a", 1);
    newMap = newMap.add("b", 2);
    newMap = newMap.add("a", 3);
    newMap = newMap.add("a", 4);
    expect(newMap, {"a": 4, "b": 2}.lock.withDeepEquals);
    expect(newMap.unlock, {"a": 4, "b": 2});

    // 3) Null checks

    // 3.1) Regular usage
    expect(<String, int>{}.lock.add("a", 1).unlock, {"a": 1});
    expect(<String, int?>{"a": null}.lock.add("b", 1).unlock, {
      "a": null,
      "b": 1,
    });
    expect(<String, int>{"a": 1}.lock.add("b", 10).unlock, {"a": 1, "b": 10});
    expect(
      <String, int?>{"a": null, "b": null, "c": null}.lock.add("z", 10).unlock,
      {"a": null, "b": null, "c": null, "z": 10},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 3,
      }.lock.add("z", 10).unlock,
      {"a": null, "b": 1, "c": null, "d": 3, "z": 10},
    );
    expect({"a": 1, "b": 2, "c": 3}.lock.add("d", 4).unlock, {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
    });

    // 3.2) Adding null
    expect(<String, int?>{"a": null}.lock.add("b", null).unlock, {
      "a": null,
      "b": null,
    });
    expect(
      <String, int?>{
        "a": null,
        "b": null,
        "c": null,
      }.lock.add("d", null).unlock,
      {"a": null, "b": null, "c": null, "d": null},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 3,
      }.lock.add("z", null).unlock,
      {"a": null, "b": 1, "c": null, "d": 3, "z": null},
    );
  });

  test("addEntry", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.addEntry(
      MapEntry<String, int>("c", 3),
    );

    expect(newIMap.unlock, {"a": 1, "b": 2, "c": 3});

    // 2) addEntry to the same entry overwrites it
    imap = ImmutableMapImplementation.empty<String, int>().withDeepEquals;
    ImmutableMap<String, int> newMap = imap.addEntry(
      MapEntry<String, int>("a", 1),
    );
    newMap = newMap.addEntry(MapEntry<String, int>("b", 2));
    newMap = newMap.addEntry(MapEntry<String, int>("a", 3));
    newMap = newMap.addEntry(MapEntry<String, int>("a", 4));
    expect(newMap, {"a": 4, "b": 2}.lock.withDeepEquals);
    expect(newMap.unlock, {"a": 4, "b": 2});

    // 3) Guaranteeing non-repeated additions to the IMap
    imap = {"a": 1, "z": 100}.lock.addEntry(MapEntry("a", 40));

    expect(imap.keys, ["a", "z"]);
    expect(imap.values, [40, 100]);
  });

  test("addAll | set with insertion order", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.addAll(
      {"c": 3, "d": 4}.lock,
    );

    expect(newIMap.unlock, {"a": 1, "b": 2, "c": 3, "d": 4});

    // 2) addAll to the same keys overwrites them.
    imap = ImmutableMapImplementation.empty<String, int>().withDeepEquals;
    ImmutableMap<String, int> newMap = imap.addAll({"a": 1}.lock);
    newMap = newMap.addAll({"b": 2}.lock);
    newMap = newMap.addAll({"a": 3}.lock);
    newMap = newMap.addAll({"a": 4}.lock);
    expect(newMap, {"a": 4, "b": 2}.lock.withDeepEquals);
    expect(newMap.unlock, {"a": 4, "b": 2});

    // 3) Null checks

    // 3.1) Regular usage
    expect(<String, int>{}.lock.addAll({"a": 1, "b": 2}.lock).unlock, {
      "a": 1,
      "b": 2,
    });
    expect(
      <String, int?>{"a": null}.lock.addAll({"b": 1, "c": 2}.lock).unlock,
      {"a": null, "b": 1, "c": 2},
    );
    expect(<String, int>{"a": 1}.lock.addAll({"b": 2, "c": 3}.lock).unlock, {
      "a": 1,
      "b": 2,
      "c": 3,
    });
    expect(
      <String, int?>{
        "a": null,
        "b": null,
        "c": null,
      }.lock.addAll({"d": 1, "e": 2}.lock).unlock,
      {"a": null, "b": null, "c": null, "d": 1, "e": 2},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 3,
      }.lock.addAll({"e": 10, "f": 11}.lock).unlock,
      {"a": null, "b": 1, "c": null, "d": 3, "e": 10, "f": 11},
    );
    expect(
      {
        "a": 1,
        "b": 2,
        "c": 3,
        "d": 4,
      }.lock.addAll({"e": 5, "f": 6}.lock).unlock,
      {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6},
    );

    // 3.2) Adding nulls
    expect(
      <String, int?>{"a": null}.lock.addAll({"b": null, "c": null}.lock).unlock,
      {"a": null, "b": null, "c": null},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": null,
        "c": null,
      }.lock.addAll({"d": null, "e": null}.lock).unlock,
      {"a": null, "b": null, "c": null, "d": null, "e": null},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 3,
      }.lock.addAll({"e": null, "f": null}.lock).unlock,
      {"a": null, "b": 1, "c": null, "d": 3, "e": null, "f": null},
    );

    // 3.3) Adding null and an item
    expect(
      <String, int?>{"a": null}.lock.addAll({"b": null, "c": 1}.lock).unlock,
      {"a": null, "b": null, "c": 1},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": null,
        "c": null,
      }.lock.addAll({"d": null, "e": 1}.lock).unlock,
      {"a": null, "b": null, "c": null, "d": null, "e": 1},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 3,
      }.lock.addAll({"e": null, "f": 1}.lock).unlock,
      {"a": null, "b": 1, "c": null, "d": 3, "e": null, "f": 1},
    );

    // 4) Guaranteeing non-repeated additions to the IMap
    imap = {"a": 1, "z": 100}.lock.addAll({"a": 40}.lock, keepOrder: true);
    expect(imap.keys, ["a", "z"]);
    expect(imap.values, [40, 100]);

    imap = {"a": 1, "z": 100}.lock.addAll({"a": 40}.lock, keepOrder: false);
    expect(imap.keys, ["z", "a"]);
    expect(imap.values, [100, 40]);

    // 5) keepOrder = false
    imap = <String, int>{}.lock
        .addAll({"z": 100, "a": 1}.lock)
        .addAll({"z": 40, "c": 3}.lock, keepOrder: false);
    expect(imap.keys, ["a", "z", "c"]);
    expect(imap.values, [1, 40, 3]);

    // keepOrder = true
    imap = <String, int>{}.lock
        .addAll({"z": 100, "a": 1}.lock)
        .addAll({"z": 40, "c": 3}.lock, keepOrder: true);
    expect(imap.keys, ["z", "a", "c"]);
    expect(imap.values, [40, 1, 3]);
  });

  test("addMap", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.addMap({"c": 3, "d": 4});

    expect(newIMap.unlock, {"a": 1, "b": 2, "c": 3, "d": 4});

    // 2) addMap to the keys overwrites them
    imap = ImmutableMapImplementation.empty<String, int>().withDeepEquals;
    ImmutableMap<String, int> newMap = imap.addMap({"a": 1});
    newMap = newMap.addMap({"b": 2});
    newMap = newMap.addMap({"a": 3});
    newMap = newMap.addMap({"a": 4});
    expect(newMap, {"a": 4, "b": 2}.lock.withDeepEquals);
    expect(newMap.unlock, {"a": 4, "b": 2});

    // 3) Guaranteeing non-repeated additions to the IMap
    imap = {"a": 1, "z": 100}.lock.addMap({"a": 40});

    expect(imap.keys, ["a", "z"]);
    expect(imap.values, [40, 100]);
  });

  test("addEntries", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.addEntries([
      MapEntry<String, int>("c", 3),
      MapEntry<String, int>("d", 4),
    ]);

    expect(newIMap.unlock, {"a": 1, "b": 2, "c": 3, "d": 4});

    // 2) addEntries to the keys overwrites them
    imap = ImmutableMapImplementation.empty<String, int>().withDeepEquals;
    ImmutableMap<String, int> newMap = imap.addEntries([
      MapEntry<String, int>("a", 1),
    ]);
    newMap = newMap.addEntries([MapEntry<String, int>("b", 2)]);
    newMap = newMap.addEntries([MapEntry<String, int>("a", 3)]);
    newMap = newMap.addEntries([MapEntry<String, int>("a", 4)]);
    expect(newMap, {"a": 4, "b": 2}.lock.withDeepEquals);
    expect(newMap.unlock, {"a": 4, "b": 2});

    // 3) Guaranteeing non-repeated additions to the IMap
    imap = {"a": 1, "z": 100}.lock.addEntries([MapEntry("a", 40)]);

    expect(imap.keys, ["a", "z"]);
    expect(imap.values, [40, 100]);
  });

  test("add | sorted set", () {
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .add("z", 100)
        .add("a", 1)
        .add("a", 40)
        .add("c", 3);
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);
  });

  test("addEntry | sorted set", () {
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .addEntry(MapEntry("z", 100))
        .addEntry(MapEntry("a", 1))
        .addEntry(MapEntry("a", 40))
        .addEntry(MapEntry("c", 3));
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);
  });

  test("addAll | sorted set", () {
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .addAll({"z": 100, "a": 1}.lock)
        .addAll({"a": 40, "c": 3}.lock);
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);
  });

  test("addMap | sorted set", () {
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .addMap({"z": 100, "a": 1})
        .addMap({"a": 40, "c": 3});
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);
  });

  test("addEntries | sorted set", () {
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .addEntries([MapEntry("z", 100), MapEntry("a", 1)])
        .addEntries([MapEntry("a", 40), MapEntry("c", 3)]);
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);
  });

  test(
    "Guarantees sorting after adding entries, if sort == true | "
    "and also guarantees that repeated keys get updated with all the last key insertion",
    () {
      ImmutableMap<String, int> imap = <String, int>{}.lock
          .withConfig(const ImmutableMapConfig(sort: true))
          .add("k", 20)
          .addEntry(MapEntry("y", 1000))
          .addAll({"a": 40, "c": 3, "f": 10}.lock)
          .addMap({"g": 200})
          .addEntries([MapEntry("z", 100), MapEntry("a", 1)]);

      expect(imap.config, const ImmutableMapConfig(sort: true));
      expect(imap.keys, ["a", "c", "f", "g", "k", "y", "z"]);
      expect(imap.values, [1, 3, 10, 200, 20, 1000, 100]);
    },
  );

  test("remove", () {
    // 1) Simple
    final ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.remove("b");

    expect(newIMap.unlock, {"a": 1});

    // 2) Multiple times
    final ImmutableMap<String, int> imap1 = {"a": 1, "b": 2, "c": 3}.lock;
    final ImmutableMap<String, int> imap2 = imap1.remove("b");
    final ImmutableMap<String, int> imap3 = imap2.remove("x");
    final ImmutableMap<String, int> imap4 = imap3.remove("a");
    final ImmutableMap<String, int> imap5 = imap4.remove("c");
    final ImmutableMap<String, int> imap6 = imap5.remove("y");

    expect(imap1.unlock, {"a": 1, "b": 2, "c": 3});
    expect(imap2.unlock, {"a": 1, "c": 3});
    expect(imap3.unlock, {"a": 1, "c": 3});
    expect(imap4.unlock, {"c": 3});
    expect(imap5.unlock, {});
    expect(imap6.unlock, {});

    expect(imap1.same(imap2), isFalse);
    expect(imap2.same(imap3), isTrue);
    expect(imap3.same(imap4), isFalse);
    expect(imap4.same(imap5), isFalse);
    expect(imap5.same(imap6), isTrue);

    // 3) Poking around with nulls
    expect(<String, int>{}.lock.remove("a").unlock, <String, int>{});

    expect(<String, int?>{"a": null}.lock.remove("b").unlock, <String, int?>{
      "a": null,
    });

    expect(<String, int>{"a": 1}.lock.remove("a").unlock, <String, int>{});

    expect(
      <String, int?>{"a": null, "b": null, "c": null}.lock.remove("a").unlock,
      <String, int?>{"b": null, "c": null},
    );
    expect(
      <String, int?>{"a": null, "b": null, "c": null}.lock.remove("z").unlock,
      <String, int?>{"a": null, "b": null, "c": null},
    );

    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 1,
      }.lock.remove("a").unlock,
      <String, int?>{"b": 1, "c": null, "d": 1},
    );
    expect(
      <String, int?>{
        "a": null,
        "b": 1,
        "c": null,
        "d": 1,
      }.lock.remove("b").unlock,
      <String, int?>{"a": null, "c": null, "d": 1},
    );
  });

  test("removeWhere", () {
    final ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    final ImmutableMap<String, int> newIMap = imap.removeWhere(
      (String key, int? value) => key == "b",
    );

    expect(newIMap.unlock, {"a": 1});
  });

  test("Chaining add and addAll", () {
    final ImmutableMap<String, int> imap1 = {"a": 1, "b": 2, "c": 3}.lock;
    final ImmutableMap<String, int> imap2 = imap1.add("d", 4);
    final ImmutableMap<String, int> imap3 = imap2.addMap({"e": 5, "f": 6});
    final ImmutableMap<String, int> imap4 = imap3.addAll(
      ImmutableMap({"g": 7, "h": 8}),
    );

    expect(imap1.unlock, {"a": 1, "b": 2, "c": 3});
    expect(imap2.unlock, {"a": 1, "b": 2, "c": 3, "d": 4});
    expect(imap3.unlock, {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6});
    expect(imap4.unlock, {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
      "g": 7,
      "h": 8,
    });

    // Methods are chainable.
    expect(
      imap1
          .add("d", 4)
          .addMap({"e": 5, "f": 6})
          .addAll(ImmutableMap({"g": 7, "h": 8}))
          .unlock,
      {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8},
    );
  });

  test("Ensuring Immutability", () {
    // 1) add

    // 1.1) Changing the passed mutable map doesn't change the IMap
    Map<String, int> original = {"a": 1, "b": 2};
    ImmutableMap<String, int> imap = original.lock;

    expect(imap.unlock, original);

    original.addEntries([MapEntry<String, int>("c", 3)]);
    original.addEntries([MapEntry<String, int>("d", 4)]);

    expect(original, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});

    // 1.2) Changing the IMap also doesn't change the original map
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    ImmutableMap<String, int> iMapNew = imap.add("c", 3);

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});
    expect(iMapNew.unlock, <String, int>{"a": 1, "b": 2, "c": 3});

    // 1.3) If the item being passed is a variable, a pointer to it shouldn't exist inside the IMap
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    int willChange = 4;
    iMapNew = imap.add("c", willChange);

    willChange = 5;

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});
    expect(willChange, 5);
    expect(iMapNew.unlock, <String, int>{"a": 1, "b": 2, "c": 4});

    // 2) addAll

    // 2.1) Changing the passed mutable map doesn't change the IMap
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    original.addAll(<String, int>{"c": 3, "d": 4});

    expect(original, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});

    // 2.2) Changing the passed immutable map doesn't change the IMap
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    iMapNew = imap.addAll(ImmutableMap({"c": 3, "d": 4}));

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});
    expect(iMapNew.unlock, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4});

    // 2.3) If the items being passed are from a variable, it shouldn't have a pointer to the
    // variable
    original = {"a": 1, "b": 2};
    final ImmutableMap<String, int> iMap1 = original.lock;
    final ImmutableMap<String, int> iMap2 = original.lock;

    expect(iMap1.unlock, original);
    expect(iMap2.unlock, original);

    iMapNew = iMap1.addAll(iMap2);
    original.addAll(<String, int>{"c": 3, "d": 4});

    expect(original, <String, int>{"a": 1, "b": 2, "c": 3, "d": 4});
    expect(iMap1.unlock, <String, int>{"a": 1, "b": 2});
    expect(iMap2.unlock, <String, int>{"a": 1, "b": 2});
    expect(iMapNew.unlock, <String, int>{"a": 1, "b": 2});

    // 3) remove

    // 3.1) Changing the passed mutable map doesn't change the IMap
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    original.remove("a");

    expect(original, <String, int>{"b": 2});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});

    // 3.2) Removing from the original IMap doesn't change it
    original = {"a": 1, "b": 2};
    imap = original.lock;

    expect(imap.unlock, original);

    iMapNew = imap.remove("a");

    expect(original, <String, int>{"a": 1, "b": 2});
    expect(imap.unlock, <String, int>{"a": 1, "b": 2});
    expect(iMapNew.unlock, <String, int>{"b": 2});
  });

  test("entries", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };
    imap.entries.forEach(
      (MapEntry<String, int?> entry) =>
          expect(finalMap[entry.key], entry.value),
    );
  });

  test("entry", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    expect(imap.entry("a").key, "a");
    expect(imap.entry("a").value, 1);

    expect(imap.entry("z").key, "z");
    expect(imap.entry("z").value, null);
  });

  test("entryOrNull", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    expect(imap.entryOrNull("a")?.key, "a");
    expect(imap.entryOrNull("a")?.value, 1);

    expect(imap.entryOrNull("z"), isNull);
  });

  test("comparableEntries", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.comparableEntries.toSet(), {
      Entry("a", 1),
      Entry("b", 2),
      Entry("c", 3),
      Entry("d", 4),
      Entry("e", 5),
      Entry("f", 6),
    });
  });

  test("keys", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    const List<String> keys = ["a", "b", "c", "d", "e", "f"];
    expect(imap.keys, keys.toSet());
    expect(imap.keys, ["a", "b", "c", "d", "f", "e"]);

    // Keys is not sorted! If you need sorted, use keyList.
    expect(imap.withConfig(ImmutableMapConfig(sort: true)).keys, [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
    ]);
    expect(
      imap.withConfig(ImmutableMapConfig(sort: true)).keysToImmutableList(),
      ["a", "b", "c", "d", "e", "f"],
    );
  });

  test("values", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    const List<int> values = [1, 2, 3, 4, 5, 6];
    expect(imap.values, values.toSet());
    expect(imap.values, [1, 2, 3, 4, 6, 5]);
  });

  test("entryList", () {
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };

    // 1) Simple usage
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(
      imap.entriesToImmutableList(),
      isA<ImmutableList<MapEntry<String, int>>>(),
    );
    imap.entriesToImmutableList().forEach(
      (MapEntry<String, int?>? entry) =>
          expect(finalMap[entry!.key], entry.value),
    );

    // 2.1) Sorting with compare
    final ImmutableMap<String, int> imap2 = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    final ImmutableList<MapEntry<String, int>> correctEntries = [
      MapEntry<String, int>("a", 1),
      MapEntry<String, int>("b", 2),
      MapEntry<String, int>("c", 3),
      MapEntry<String, int>("d", 4),
      MapEntry<String, int>("e", 5),
      MapEntry<String, int>("f", 6),
    ].lock;
    final orderedEntries = imap2
        .withConfig(ImmutableMapConfig(sort: false))
        .entriesToImmutableList(
          compare: (MapEntry<String, int?>? a, MapEntry<String, int?>? b) =>
              a!.key.compareTo(b!.key),
        );

    for (int i = 0; i < orderedEntries.length; i++) {
      expect(orderedEntries[i].key, correctEntries[i].key);
      expect(orderedEntries[i].value, correctEntries[i].value);
    }

    // 2.2) Sorting with sortKeys
    final orderedEntriesFromConfig = imap2
        .withConfig(ImmutableMapConfig(sort: true))
        .entriesToImmutableList();

    for (int i = 0; i < orderedEntries.length; i++) {
      expect(orderedEntriesFromConfig[i].key, correctEntries[i].key);
      expect(orderedEntriesFromConfig[i].value, correctEntries[i].value);
    }
  });

  test("keyList", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(
      imap.keysToImmutableList(),
      allOf(isA<ImmutableList<String>>(), ["a", "c", "b", "d", "f", "e"]),
    );

    expect(
      imap
          .withConfig(ImmutableMapConfig(sort: false))
          .keysToImmutableList(
            compare: (String? a, String? b) => a!.compareTo(b!),
          ),
      ["a", "b", "c", "d", "e", "f"],
    );
    expect(
      imap.withConfig(ImmutableMapConfig(sort: true)).keysToImmutableList(),
      ["a", "b", "c", "d", "e", "f"],
    );
  });

  test("valueList", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(
      imap.valuesToImmutableList(),
      allOf(isA<ImmutableList<int>>(), [1, 3, 2, 4, 6, 5]),
    );

    expect(
      () => imap.valuesToImmutableList(
        sort: false,
        compare: (int? a, int? b) => a!.compareTo(b!),
      ),
      throwsAssertionError,
    );

    expect(
      imap.valuesToImmutableList(
        sort: true,
        compare: (int? a, int? b) => a!.compareTo(b!),
      ),
      [1, 2, 3, 4, 5, 6],
    );

    expect(imap.valuesToImmutableList(sort: true), [1, 2, 3, 4, 5, 6]);
  });

  test("entrySet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };
    expect(
      imap.entriesToImmutableSet(),
      isA<ImmutableSet<MapEntry<String, int>>>(),
    );
    imap.entriesToImmutableSet().forEach(
      (MapEntry<String, int?>? entry) =>
          expect(finalMap[entry!.key], entry.value),
    );
  });

  test("keySet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<String> keys = ["a", "b", "c", "d", "e", "f"];
    expect(imap.keysToImmutableSet(), isA<ImmutableSet<String>>());
    imap.keysToImmutableSet().forEach(
      (String? key) => expect(keys.contains(key), isTrue),
    );
  });

  test("valueSet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<int> values = [1, 2, 3, 4, 5, 6];
    expect(
      imap.valuesToImmutableSet(),
      allOf(isA<ImmutableSet<int>>(), {1, 2, 3, 4, 5, 6}),
    );
    imap.valuesToImmutableSet().forEach(
      (int? value) => expect(values.contains(value), isTrue),
    );
  });

  test("toEntryList", () {
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };

    // 1) Simple usage
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.entriesToList(), isA<List<MapEntry<String, int>>>());
    imap.entriesToList().forEach(
      (MapEntry<String, int?> entry) =>
          expect(finalMap[entry.key], entry.value),
    );

    // 2.1) Sorting with compare
    final ImmutableMap<String, int> imap2 = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    final List<MapEntry<String, int>> correctEntries = [
      MapEntry<String, int>("a", 1),
      MapEntry<String, int>("b", 2),
      MapEntry<String, int>("c", 3),
      MapEntry<String, int>("d", 4),
      MapEntry<String, int>("e", 5),
      MapEntry<String, int>("f", 6),
    ];
    final orderedEntries = imap2
        .withConfig(ImmutableMapConfig(sort: false))
        .entriesToList(
          compare: (MapEntry<String, int?> a, MapEntry<String, int?> b) =>
              a.key.compareTo(b.key),
        );

    for (int i = 0; i < orderedEntries.length; i++) {
      expect(orderedEntries[i].key, correctEntries[i].key);
      expect(orderedEntries[i].value, correctEntries[i].value);
    }

    // 2.2) Sorting with sortKeys
    final orderedEntriesFromConfig = imap2
        .withConfig(ImmutableMapConfig(sort: true))
        .entriesToList();

    for (int i = 0; i < orderedEntries.length; i++) {
      expect(orderedEntriesFromConfig[i].key, correctEntries[i].key);
      expect(orderedEntriesFromConfig[i].value, correctEntries[i].value);
    }
  });

  test("toKeyList", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(
      imap.keysToList(),
      allOf(isA<List<String>>(), ["a", "c", "b", "d", "f", "e"]),
    );

    expect(
      imap
          .withConfig(ImmutableMapConfig(sort: false))
          .keysToList(compare: (String a, String b) => a.compareTo(b)),
      ["a", "b", "c", "d", "e", "f"],
    );
    expect(imap.withConfig(ImmutableMapConfig(sort: true)).keysToList(), [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
    ]);
  });

  test("toValueList", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(imap.valuesToList(), allOf(isA<List<int>>(), [1, 3, 2, 4, 6, 5]));

    expect(
      () => imap.valuesToList(
        compare: (int? a, int? b) => a!.compareTo(b!),
        sort: false,
      ),
      throwsAssertionError,
    );

    expect(
      imap.valuesToList(
        compare: (int? a, int? b) => a!.compareTo(b!),
        sort: true,
      ),
      [1, 2, 3, 4, 5, 6],
    );

    expect(imap.valuesToList(sort: true), [1, 2, 3, 4, 5, 6]);
  });

  test("toEntrySet", () {
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };

    // 1) Simple usage
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.entriesToSet(), isA<Set<MapEntry<String, int>>>());
    imap.entriesToSet().forEach(
      (MapEntry<String, int?> entry) =>
          expect(finalMap[entry.key], entry.value),
    );

    // 2) When compare = null
    expect(imap.entriesToSet(compare: null), isA<Set<MapEntry<String, int>>>());
    imap
        .entriesToSet(compare: null)
        .forEach(
          (MapEntry<String, int?> entry) =>
              expect(imap[entry.key], entry.value),
        );
  });

  test("toKeySet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(
      imap.keysToSet(),
      allOf(isA<Set<String>>(), {"a", "c", "b", "d", "f", "e"}),
    );
    expect(
      imap.keysToSet(compare: null),
      allOf(isA<Set<String>>(), {"a", "c", "b", "d", "f", "e"}),
    );
  });

  test("toValueSet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(imap.valuesToSet(), allOf(isA<Set<int>>(), {1, 3, 2, 4, 6, 5}));
    expect(
      imap.valuesToSet(compare: null),
      allOf(isA<Set<int>>(), {1, 3, 2, 4, 6, 5}),
    );
  });

  test("iterator", () {
    // 1) Regular usage
    final ImmutableMap<String, int> imap1 = {"a": 1, "b": 2, "d": 4}.lock
        .add("c", 3)
        .addAll(ImmutableMap({"e": 5, "f": 6}))
        .withConfig(ImmutableMapConfig(sort: false));
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "d": 4,
      "c": 3,
      "e": 5,
      "f": 6,
    };

    Iterator<MapEntry<String, int>> iter1 = imap1.iterator;
    final Map<String, int> result = iter1.toMap();

    expect(result, finalMap);

    iter1 = imap1.iterator;

    // Throws StateError before first moveNext().
    expect(() => iter1.current, throwsStateError);

    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("a", 1));
    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("b", 2));
    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("d", 4));
    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("c", 3));
    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("e", 5));
    expect(iter1.moveNext(), isTrue);
    expect(iter1.current.asComparableEntry, Entry<String, int>("f", 6));
    expect(iter1.moveNext(), isFalse);

    // Throws StateError after last moveNext().
    expect(() => iter1.current, throwsStateError);

    // 2) With sorted keys
    final ImmutableMap<String, int> imap2 = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    final Iterator<MapEntry<String, int>> iter2 = imap2.iterator;

    // Throws StateError before first moveNext().
    expect(() => iter2.current, throwsStateError);

    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("a", 1));
    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("b", 2));
    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("c", 3));
    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("d", 4));
    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("e", 5));
    expect(iter2.moveNext(), isTrue);
    expect(iter2.current.asComparableEntry, Entry<String, int>("f", 6));
    expect(iter2.moveNext(), isFalse);

    // Throws StateError after last moveNext().
    expect(() => iter2.current, throwsStateError);
  });

  test("any", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.any((String k, int v) => v == 4), isTrue);
    expect(imap.any((String k, int v) => k == "f"), isTrue);
    expect(imap.any((String k, int v) => v == 100), isFalse);
    expect(imap.any((String k, int v) => k == "z"), isFalse);
  });

  test("anyEntry", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(
      imap.anyEntry((MapEntry<String, int?> entry) => entry.value == 4),
      isTrue,
    );
    expect(
      imap.anyEntry((MapEntry<String, int?> entry) => entry.key == "f"),
      isTrue,
    );
    expect(
      imap.anyEntry((MapEntry<String, int?> entry) => entry.value == 100),
      isFalse,
    );
    expect(
      imap.anyEntry((MapEntry<String, int?> entry) => entry.key == "z"),
      isFalse,
    );
  });

  test("everyEntry", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(
      imap.everyEntry((MapEntry<String, int?> entry) => entry.value! < 7),
      isTrue,
    );
    expect(
      imap.everyEntry((MapEntry<String, int?> entry) => entry.key.length <= 1),
      isTrue,
    );
    expect(
      imap.everyEntry((MapEntry<String, int?> entry) => entry.key == "a"),
      isFalse,
    );
    expect(
      imap.everyEntry((MapEntry<String, int?> entry) => entry.value! < 4),
      isFalse,
    );
  });

  test("cast", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.cast<String, num>(), isA<ImmutableMap<String, num>>());
    ImmutableMap<String, num> casted = imap.cast<String, num>();
    var result = casted["a"];
    expect(result, 1);

    // 2) Error when type can't be cast
    imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    Object? error;
    try {
      ImmutableMap<String, bool> casted = imap.cast<String, bool>();
      casted["a"]; // ignore: unnecessary_statements
    } catch (_error) {
      error = _error;
    }
    expect(error is TypeError, isTrue);
    expect(
      error.toString(),
      "type 'int' is not a subtype of type 'bool?' in type cast",
    );
  });

  test("[]", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap["a"], 1);
    expect(imap["z"], isNull);
  });

  test("get", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.get("a"), 1);
    expect(imap.get("z"), isNull);
  });

  test("contains", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.contains("a", 1), isTrue);
    expect(imap.contains("a", 2), isFalse);
    expect(imap.contains("b", 2), isTrue);
    expect(imap.contains("b", 3), isFalse);
    expect(imap.contains("c", 3), isTrue);
    expect(imap.contains("c", 4), isFalse);
    expect(imap.contains("z", 100), isFalse);
  });

  test("containsKey", () {
    final ImmutableMap<String?, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.containsKey("a"), isTrue);
    expect(imap.containsKey("z"), isFalse);
    expect(imap.containsKey(null), isFalse);
  });

  test("containsValue", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.containsValue(1), isTrue);
    expect(imap.containsValue(100), isFalse);
    expect(imap.containsValue(null), isFalse);
  });

  test("containsEntry", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.containsEntry(MapEntry<String, int>("a", 1)), isTrue);
    expect(imap.containsEntry(MapEntry<String, int>("a", 2)), isFalse);
    expect(imap.containsEntry(MapEntry<String, int>("b", 1)), isFalse);
    expect(imap.containsEntry(MapEntry<String, int>("z", 100)), isFalse);
  });

  test("containsEntry", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.containsEntry(MapEntry<String, int>("a", 1)), isTrue);
    expect(imap.containsEntry(MapEntry<String, int>("a", 2)), isFalse);
    expect(imap.containsEntry(MapEntry<String, int>("b", 1)), isFalse);
    expect(imap.containsEntry(MapEntry<String, int>("z", 100)), isFalse);
  });

  test("toEntryList", () {
    // 1) Insertion Order
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };
    expect(imap.entriesToList(), isA<List<MapEntry<String, int>>>());
    imap.entriesToList().forEach(
      (MapEntry<String, int> entry) => expect(finalMap[entry.key], entry.value),
    );

    final List<Entry<String, int>> correctEntryList = [
      Entry("a", 1),
      Entry("c", 3),
      Entry("b", 2),
      Entry("d", 4),
      Entry("f", 6),
      Entry("e", 5),
    ];
    final List<MapEntry<String, int>> mapEntryList = imap.entriesToList();
    for (int i = 0; i < mapEntryList.length; i++)
      expect(mapEntryList[i].asComparableEntry, correctEntryList[i]);

    // 2) With sort
    final List<Entry<String, int>> correctEntryListSorted = [
      Entry("a", 1),
      Entry("b", 2),
      Entry("c", 3),
      Entry("d", 4),
      Entry("e", 5),
      Entry("f", 6),
    ];
    final List<MapEntry<String, int>> mapEntryListSorted = imap
        .withConfig(ImmutableMapConfig(sort: true))
        .entriesToList();
    for (int i = 0; i < mapEntryListSorted.length; i++)
      expect(
        mapEntryListSorted[i].asComparableEntry,
        correctEntryListSorted[i],
      );
  });

  test("toKeyList", () {
    // 1) Insertion Order
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(imap.keysToList(), ["a", "c", "b", "d", "f", "e"]);

    // 2) With sorting
    expect(imap.withConfig(ImmutableMapConfig(sort: true)).keysToList(), [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
    ]);
  });

  test("toValueList", () {
    // 1) Insertion Order
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "c": 3,
      "b": 2,
    }.lock.add("d", 4).addAll(ImmutableMap({"f": 6, "e": 5}));
    expect(imap.valuesToList(), [1, 3, 2, 4, 6, 5]);

    // 2) With sorting
    expect(imap.valuesToList(sort: true), [1, 2, 3, 4, 5, 6]);
  });

  test("toISet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const Map<String, int> finalMap = {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    };
    expect(imap.entriesToSet(), isA<Set<MapEntry<String, int>>>());
    imap.entriesToSet().forEach(
      (MapEntry<String, int?> entry) =>
          expect(finalMap[entry.key], entry.value),
    );
  });

  test("toKeySet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<String> keys = ["a", "b", "c", "d", "e", "f"];
    expect(imap.keysToSet(), isA<Set<String>>());
    expect(imap.keysToSet(), keys.toSet());
  });

  test("toValueSet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<int> values = [1, 2, 3, 4, 5, 6];
    expect(imap.valuesToSet(), isA<Set<int>>());
    expect(imap.valuesToSet(), values.toSet());
  });

  test("toKeyISet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<String> keys = ["a", "b", "c", "d", "e", "f"];
    expect(imap.keysToImmutableSet(), isA<ImmutableSet<String>>());
    expect(imap.keysToImmutableSet(), keys.toSet());
  });

  test("length", () {
    // 1) Regular usage
    ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    expect(imap.length, 6);

    // 2) When with an empty IMap
    imap = ImmutableMapImplementation.empty();

    expect(imap.length, 0);
    expect(imap.isEmpty, isTrue);
  });

  test("toValueISet", () {
    final ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));
    const List<int> values = [1, 2, 3, 4, 5, 6];
    expect(imap.valuesToImmutableSet(), isA<ImmutableSet<int>>());
    expect(imap.valuesToImmutableSet(), values.toSet());
  });

  test("forEach", () {
    ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    int result = 100;
    imap.forEach((String k, int? v) => result *= 1 + v!);
    expect(result, 504000);
  });

  test("map", () {
    ImmutableMap<String, int> imap = {
      "x": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    // ---

    var imap1 = imap.map<String, int>(
      (String k, int? v) => MapEntry(k, v! + 1),
      config: ImmutableMapConfig(sort: false),
    );
    expect(imap1.keys, ["x", "b", "c", "d", "e", "f"]);
    expect(imap1.values, [2, 3, 4, 5, 6, 7]);

    // ---

    var imap2 = imap.map<String, int>(
      (String k, int? v) => MapEntry(k, v! + 1),
      config: ImmutableMapConfig(sort: true),
    );
    expect(imap2.keys, ["b", "c", "d", "e", "f", "x"]);
    expect(imap2.values, [3, 4, 5, 6, 7, 2]);

    // ---

    var imap3 = imap.map<int, String>(
      (String k, int? v) => MapEntry(-v!, k),
      config: ImmutableMapConfig(sort: false),
    );
    expect(imap3.keys, [-1, -2, -3, -4, -5, -6]);
    expect(imap3.values, ["x", "b", "c", "d", "e", "f"]);

    // ---

    var imap4 = imap.map<int, String>(
      (String k, int? v) => MapEntry(-v!, k),
      config: ImmutableMapConfig(sort: true),
    );
    expect(imap4.keys, [-6, -5, -4, -3, -2, -1]);
    expect(imap4.values, ["f", "e", "d", "c", "b", "x"]);

    // ---

    var imap5 = imap.map<int, String>(
      (String k, int? v) => MapEntry(-v!, k),
      config: ImmutableMapConfig(sort: true),
      ifRemove: (int key, String value) => key == -5 || value == "c",
    );
    expect(imap5.keys, [-6, -4, -2, -1]);
    expect(imap5.values, ["f", "d", "b", "x"]);
  });

  test("mapTo", () {
    ImmutableMap<String, int> imap = {"x": 1, "b": 2, "c": 3}.lock;
    var imap1 = imap.mapTo<String>((String k, int? v) => "$k:$v");
    expect(imap1, ["x:1", "b:2", "c:3"]);
  });

  test("where", () {
    ImmutableMap<String, int> imap = {
      "a": 1,
      "b": 2,
      "c": 3,
    }.lock.add("d", 4).addAll(ImmutableMap({"e": 5, "f": 6}));

    expect(imap.where((String k, int? v) => v! < 0).unlock, <String, int>{});
    expect(
      imap.where((String k, int? v) => k == "a" || k == "b").unlock,
      <String, int>{"a": 1, "b": 2},
    );
    expect(imap.where((String k, int? v) => v! < 5).unlock, <String, int>{
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
    });
    expect(imap.where((String k, int? v) => v! < 100).unlock, <String, int>{
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4,
      "e": 5,
      "f": 6,
    });
  });

  test("toString", () {
    // 1) Global configuration prettyPrint == false
    ImmutableCollection.prettyPrint = false;
    expect({}.lock.toString(), "{}");
    expect({"a": 1}.lock.toString(), "{a: 1}");
    expect({"a": 1, "b": 2, "c": 3}.lock.toString(), "{a: 1, b: 2, c: 3}");

    // 2) Global configuration prettyPrint == true
    ImmutableCollection.prettyPrint = true;
    expect({}.lock.toString(), "{}");
    expect({"a": 1}.lock.toString(), "{a: 1}");
    expect(
      {"a": 1, "b": 2, "c": 3}.lock.toString(),
      "{\n"
      "   a: 1,\n"
      "   b: 2,\n"
      "   c: 3\n"
      "}",
    );

    // 3) Local prettyPrint == false
    ImmutableCollection.prettyPrint = true;
    expect({}.lock.toString(false), "{}");
    expect({"a": 1}.lock.toString(false), "{a: 1}");
    expect({"a": 1, "b": 2, "c": 3}.lock.toString(false), "{a: 1, b: 2, c: 3}");

    // 4) Local prettyPrint == true
    expect({}.lock.toString(true), "{}");
    expect({"a": 1}.lock.toString(true), "{a: 1}");
    expect(
      {"a": 1, "b": 2, "c": 3}.lock.toString(true),
      "{\n"
      "   a: 1,\n"
      "   b: 2,\n"
      "   c: 3\n"
      "}",
    );
  });

  test("clear", () {
    final ImmutableMap<String, int> imap = ImmutableMap.withConfig({
      "a": 1,
      "b": 2,
    }, ImmutableMapConfig(isDeepEquals: false));
    final ImmutableMap<String, int> iMapCleared = imap.clear();
    expect(iMapCleared.unlock, allOf(isA<Map<String, int>>(), {}));
    expect(iMapCleared.config.isDeepEquals, isFalse);
  });

  test("putIfAbsent", () {
    // 1) Regular usage
    ImmutableMap<String, int?> scores = {"Bob": 36}.lock;

    var value = Output<int>();
    scores = scores.putIfAbsent("Bob", () => 3, previousValue: value);
    expect(value.value, 36);

    value = Output<int>();
    scores = scores.putIfAbsent("Rohan", () => 5, previousValue: value);
    expect(value.value, 5);

    value = Output<int>();
    scores = scores.putIfAbsent("Sophia", () => 6, previousValue: value);
    expect(value.value, 6);

    expect(scores["Bob"], 36);
    expect(scores["Rohan"], 5);
    expect(scores["Sophia"], 6);

    // 2) Sorted set
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .putIfAbsent("z", () => 100)
        .putIfAbsent("a", () => 1)
        .putIfAbsent("a", () => 40)
        .putIfAbsent("c", () => 3);
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [1, 3, 100]);
  });

  test("update", () {
    // 1) Existent key
    ImmutableMap<String, int> scores = {"Bob": 36}.lock;

    Output<int> value = Output();
    ImmutableMap<String, int?> updatedScores = scores.update(
      "Bob",
      (int? value) => value! * 2,
      previousValue: value,
    );

    expect(scores.unlock, {"Bob": 36});
    expect(updatedScores.unlock, {"Bob": 72});
    expect(value.value, 36);

    // 2) Nonexistent key
    scores = {"Bob": 36}.lock;

    value = Output();
    updatedScores = scores.update(
      "Joe",
      (int? value) => value! * 2,
      previousValue: value,
      ifAbsent: () => 1,
    );

    expect(scores.unlock, {"Bob": 36});
    expect(updatedScores.unlock, {"Bob": 36, "Joe": 1});
    expect(value.value, null);

    // 3) Return the original map if update a nonexistent key without the ifAbsent parameter
    scores = {"Bob": 36}.lock;

    value = Output();
    expect(
      () => scores.update(
        "Joe",
        (int? value) => value! * 2,
        previousValue: value,
        ifAbsent: (() => throw ArgumentError()),
      ),
      throwsArgumentError,
    );

    value = Output();
    expect(
      scores.update("Joe", (int? value) => value! * 2, previousValue: value),
      scores,
    );
    expect(value.value, null);

    // 4) ifRemove
    scores = {"Bob": 36, "Joe": 10}.lock;

    value = Output();
    final ImmutableMap<String, int?> newScores = scores.update(
      "Joe",
      (int? value) => 2 * value!,
      ifRemove: (String key, int value) => value == 20,
      previousValue: value,
    );
    expect(newScores.unlock, {"Bob": 36});
    expect(value.value, 10);

    // 5) Sorted map
    ImmutableMap<String, int> imap = <String, int>{}.lock
        .withConfig(const ImmutableMapConfig(sort: true))
        .update("z", ((int value) => 0), ifAbsent: () => 100)
        .update("a", ((int value) => 0), ifAbsent: () => 1)
        .update("a", ((int value) => 40), ifAbsent: () => 0)
        .update("c", ((int value) => 0), ifAbsent: () => 3);
    expect(imap.keys, ["a", "c", "z"]);
    expect(imap.values, [40, 3, 100]);

    // 6) Nullable value
    ImmutableMap<String, int?> nullableMap = <String, int?>{'foo': null}.lock;

    nullableMap = nullableMap.update('foo', (_) => 1);

    expect(nullableMap.get('foo'), 1);
  });

  test("update returns same instance", () {
    // 1) Existent key
    ImmutableMap<String, Age> scores = {"Bob": Age(36), "Mary": Age(18)}.lock;

    // Update with same instance (identical).
    ImmutableMap<String, Age> updatedScores1 = scores.update(
      "Bob",
      (Age age) => age,
    );
    expect(identical(scores, updatedScores1), isTrue);

    // Update with equal instance (equals).
    ImmutableMap<String, Age> updatedScores2 = scores.update(
      "Bob",
      (Age age) => Age(age.value),
    );
    expect(identical(scores, updatedScores2), isFalse);
  });

  test("updateAll", () {
    final ImmutableMap<String, int> scores = {"Bob": 36, "Joe": 100}.lock;
    final ImmutableMap<String, int?> updatedScores = scores.updateAll(
      (String key, int? value) => value! * 2,
    );

    expect(updatedScores.unlock, {"Bob": 72, "Joe": 200});
  });

  test("flushFactor", () {
    // 1) Default value
    expect(ImmutableMap.flushFactor, 50);

    // 2) Setter
    ImmutableMap.flushFactor = 200;
    expect(ImmutableMap.flushFactor, 200);

    // 3) Can't be smaller or equal to 0
    expect(() => ImmutableMap.flushFactor = 0, throwsStateError);
    expect(() => ImmutableMap.flushFactor = -100, throwsStateError);
  });
}

class Age {
  final int value;

  Age(this.value);

  @override
  String toString() => 'Age{value: $value}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Age && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
