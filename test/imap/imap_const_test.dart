// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
// ignore_for_file: non_const_call_to_literal_constructor
import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = false;
  });

  test("Runtime Type", () {
    expect(const ImmutableMapLiteral._({}), isA<ImmutableMapLiteral>());
    expect(const ImmutableMapLiteral._({}), isA<ImmutableMapLiteral>());
    expect(
      const ImmutableMapLiteral<String, int>._({}),
      isA<ImmutableMapLiteral<String, int>>(),
    );
    expect(
      const ImmutableMapLiteral._({'a': 1}),
      isA<ImmutableMapLiteral<String, int>>(),
    );
    expect(
      const ImmutableMapLiteral<String, int>._({}),
      isA<ImmutableMapLiteral<String, int>>(),
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const ImmutableMapLiteral._({}), isEmpty);
    expect(const ImmutableMapLiteral._({}).isEmpty, isTrue);
    expect(const ImmutableMapLiteral._({}).isNotEmpty, isFalse);

    expect(const ImmutableMapLiteral<String, int>._({}).isEmpty, isTrue);
    expect(const ImmutableMapLiteral<String, int>._({}).isNotEmpty, isFalse);

    expect(const ImmutableMapLiteral._({'a': 1}), isNotEmpty);
    expect(const ImmutableMapLiteral._({'a': 1}).isEmpty, isFalse);
    expect(const ImmutableMapLiteral._({'a': 1}).isNotEmpty, isTrue);

    expect(const ImmutableMapLiteral<String, int>._({}), isEmpty);
    expect(const ImmutableMapLiteral<String, int>._({}).isEmpty, isTrue);
    expect(const ImmutableMapLiteral<String, int>._({}).isNotEmpty, isFalse);
  });

  test("hashCode", () {
    expect(
      const ImmutableMapLiteral._({}) == const ImmutableMapLiteral._({}),
      isTrue,
    );
    expect(ImmutableMap() == ImmutableMap(), isTrue);
    expect(const ImmutableMapLiteral._({}) == ImmutableMap(), isTrue);
    expect(const ImmutableMapLiteral._({}) == ImmutableMap({}), isTrue);
    expect(ImmutableMap() == const ImmutableMapLiteral._({}), isTrue);
    expect(ImmutableMap({}) == const ImmutableMapLiteral._({}), isTrue);

    expect(
      const ImmutableMapLiteral._({'a': 1, 'b': 2}) ==
          const ImmutableMapLiteral._({'a': 1, 'b': 2}),
      isTrue,
    );
    expect(
      ImmutableMap({'a': 1, 'b': 2}) == ImmutableMap({'a': 1, 'b': 2}),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({'a': 1, 'b': 2}) ==
          ImmutableMap({'a': 1, 'b': 2}),
      isTrue,
    );
    expect(
      ImmutableMap({'a': 1, 'b': 2}) ==
          const ImmutableMapLiteral._({'a': 1, 'b': 2}),
      isTrue,
    );

    var a = ImmutableMap<String, int>(<String, int>{});
    var b = const ImmutableMapLiteral<String, int>._(<String, int>{});
    expect(a, b);
    expect(a.hashCode, b.hashCode);

    var x = ImmutableMap({'a': 1, 'b': 2, 'c': 3});
    var y = ImmutableMap({'a': 1, 'b': 2}).add('c', 3);
    expect(x, y);
    expect(x.hashCode, y.hashCode);
  });

  test("withConfig", () {
    // 1) Regular usage
    const ImmutableMap<String, int> imap = ImmutableMapLiteral._({
      'a': 1,
      'b': 2,
    });

    expect(imap.isDeepEquals, isTrue);

    ImmutableMap<String, int> iMapNewConfig = imap.withConfig(
      imap.config.copyWith(),
    );

    ImmutableMap<String, int> iMapNewConfigIdentity = imap.withConfig(
      imap.config.copyWith(isDeepEquals: false),
    );

    expect(iMapNewConfig.isDeepEquals, isTrue);
    expect(iMapNewConfigIdentity.isDeepEquals, isFalse);

    // 2) With empty map and different configs.
    const Map<String, int> emptyMap = <String, int>{};
    expect(
      const ImmutableMapLiteral._(emptyMap, ImmutableMapConfig()),
      <String, int>{}.lock,
    );
    expect(
      const ImmutableMapLiteral._(
        emptyMap,
        ImmutableMapConfig(cacheHashCode: false),
      ),
      <String, int>{}.lock.withConfig(ImmutableMapConfig(cacheHashCode: false)),
    );
    expect(
      const ImmutableMapLiteral._(
        emptyMap,
        ImmutableMapConfig(cacheHashCode: false),
      ),
      isNot(<String, int>{}.lock),
    );

    // 3) With non-empty map and different configs.
    const Map<String, int> nonemptyMap = <String, int>{'a': 1, 'b': 2, 'c': 3};
    expect(
      const ImmutableMapLiteral._(nonemptyMap, ImmutableMapConfig()),
      <String, int>{'a': 1, 'b': 2, 'c': 3}.lock,
    );
    expect(
      const ImmutableMapLiteral._(
        nonemptyMap,
        ImmutableMapConfig(cacheHashCode: false),
      ),
      <String, int>{
        'a': 1,
        'b': 2,
        'c': 3,
      }.lock.withConfig(ImmutableMapConfig(cacheHashCode: false)),
    );
    expect(
      const ImmutableMapLiteral._(
        nonemptyMap,
        ImmutableMapConfig(cacheHashCode: false),
      ),
      isNot(<String, int>{'a': 1, 'b': 2, 'c': 3}.lock),
    );
  });

  test("unlock", () {
    const imapConst = ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3});
    expect(imapConst.unlock, {'a': 1, 'b': 2, 'c': 3});

    Map map = imapConst.unlock;
    expect(map, isA<Map>());
    map['d'] = 4;
    expect(map, {'a': 1, 'b': 2, 'c': 3, 'd': 4});

    expect(imapConst.unlockLazy, {'a': 1, 'b': 2, 'c': 3});
    map = imapConst.unlockLazy;
    expect(map, isA<Map>());
    map['d'] = 4;
    expect(map, {'a': 1, 'b': 2, 'c': 3, 'd': 4});

    expect(imapConst.unlockView, {'a': 1, 'b': 2, 'c': 3});
    expect(() => imapConst.unlockView['d'] = 4, throwsUnsupportedError);
  });

  test("flush", () {
    const imapConst = ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3});
    expect(imapConst.isFlushed, isTrue);
    imapConst.flush;
    expect(imapConst.isFlushed, isTrue);
    expect(imapConst.unlock, {'a': 1, 'b': 2, 'c': 3});
  });

  test("add/addAll, remove/removeAll", () {
    const imapConst = ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3});
    expect(imapConst.add('d', 4), {'a': 1, 'b': 2, 'c': 3, 'd': 4}.lock);
    expect(
      imapConst.addAll({'d': 4, 'e': 5, 'f': 6}.lock),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6}.lock,
    );
    expect(imapConst.remove('b'), {'a': 1, 'c': 3}.lock);
  });

  test("IMapConst", () {
    //
    // The default constructor will always use the same const {} internals.
    expect(
      const ImmutableMapLiteral._({}).same(const ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({}).same(ImmutableMapLiteral._({})),
      isFalse,
    );
    expect(
      const ImmutableMapLiteral._({}).same(const ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(ImmutableMapLiteral._({}).same(ImmutableMapLiteral._({})), isFalse);

    // ---

    // Both IMapConst are const. So they are the same.
    expect(
      const ImmutableMapLiteral._({}).same(const ImmutableMapLiteral._({})),
      isTrue,
    );

    // One of the IMapConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableMapLiteral._({}).same(ImmutableMapLiteral._({})),
      isFalse,
    );
    expect(
      ImmutableMapLiteral._({}).same(const ImmutableMapLiteral._({})),
      isFalse,
    );

    // None of the IMapConst are const. So they are NOT the same.
    expect(ImmutableMapLiteral._({}).same(ImmutableMapLiteral._({})), isFalse);

    // ---

    // Both IMapConst are const. So they are the same.
    expect(
      const ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
        'c': 3,
      }).same(const ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3})),
      isTrue,
    );

    // One of the IMapConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
        'c': 3,
      }).same(ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3})),
      isFalse,
    );
    expect(
      ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
        'c': 3,
      }).same(const ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3})),
      isFalse,
    );

    // None of the IMapConst are const. So they are NOT the same.
    expect(
      ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
        'c': 3,
      }).same(ImmutableMapLiteral._({'a': 1, 'b': 2, 'c': 3})),
      isFalse,
    );
  });

  test("Interaction between IMap and IMapConst", () {
    //
    // Empty.
    expect(ImmutableMapLiteral._({}).same(ImmutableMap()), isFalse);
    expect(ImmutableMapLiteral._({}).same(ImmutableMap()), isFalse);
    expect(ImmutableMap().same(ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(ImmutableMapLiteral._({})), isFalse);
    expect(const ImmutableMapLiteral._({}).same(ImmutableMap()), isFalse);
    expect(const ImmutableMapLiteral._({}).same(ImmutableMap()), isFalse);
    expect(ImmutableMap().same(const ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(const ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(const ImmutableMapLiteral._({})), isFalse);
    expect(ImmutableMap().same(const ImmutableMapLiteral._({})), isFalse);

    // Not Empty.
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).same(ImmutableMapLiteral._({'a': 1, 'b': 2})),
      isFalse,
    );
    expect(
      ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).same(ImmutableMap({'a': 1, 'b': 2})),
      isFalse,
    );
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).same(const ImmutableMapLiteral._({'a': 1, 'b': 2})),
      isFalse,
    );
    expect(
      const ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).same(ImmutableMap({'a': 1, 'b': 2})),
      isFalse,
    );

    // equalItems
    expect(
      ImmutableMap({}).equalItems(ImmutableMapLiteral._({}).entries),
      isTrue,
    );
    expect(
      ImmutableMap({}).equalItems(const ImmutableMapLiteral._({}).entries),
      isTrue,
    );
    expect(
      ImmutableMap().equalItems(const ImmutableMapLiteral._({}).entries),
      isTrue,
    );
    expect(
      ImmutableMap().equalItems(ImmutableMapLiteral._({}).entries),
      isTrue,
    );
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).equalItems(ImmutableMapLiteral._({'a': 1, 'b': 2}).entries),
      isTrue,
    );
    expect(
      ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).equalItems(ImmutableMap({'a': 1, 'b': 2}).entries),
      isTrue,
    );
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).equalItems(const ImmutableMapLiteral._({'a': 1, 'b': 2}).entries),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).equalItems(ImmutableMap({'a': 1, 'b': 2}).entries),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableMap({}).equalItemsAndConfig(ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      ImmutableMap({}).equalItemsAndConfig(const ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      ImmutableMap().equalItemsAndConfig(const ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      ImmutableMap().equalItemsAndConfig(ImmutableMapLiteral._({})),
      isTrue,
    );
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).equalItemsAndConfig(ImmutableMapLiteral._({'a': 1, 'b': 2})),
      isTrue,
    );
    expect(
      ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).equalItemsAndConfig(ImmutableMap({'a': 1, 'b': 2})),
      isTrue,
    );
    expect(
      ImmutableMap({
        'a': 1,
        'b': 2,
      }).equalItemsAndConfig(const ImmutableMapLiteral._({'a': 1, 'b': 2})),
      isTrue,
    );
    expect(
      const ImmutableMapLiteral._({
        'a': 1,
        'b': 2,
      }).equalItemsAndConfig(ImmutableMap({'a': 1, 'b': 2})),
      isTrue,
    );
  });

  test(
    "Make sure the internal map is Map<String, int>, and not Map<Never>",
    () {
      var l1 = const ImmutableMapLiteral<String, int>._({});
      expect(l1.runtimeType.toString(), 'IMapConst<String, int>');

      var l2 = ImmutableMap<String, int>({'a': 1, 'b': 2, 'c': 3});
      expect(l2.runtimeType.toString(), 'IMapImpl<String, int>');

      var l3 = l1.addAll(l2);
      expect(l3.runtimeType.toString(), 'IMapImpl<String, int>');

      var result = l3.where((String key, int value) => value == 2);
      expect(result, {'b': 2}.lock);
    },
  );
}
