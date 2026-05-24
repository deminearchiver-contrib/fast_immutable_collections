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
    expect(const ImmutableSet.literal({}), isA<ImmutableSetLiteral>());
    expect(const ImmutableSet.literal({}), isA<ImmutableSetLiteral>());
    expect(
      const ImmutableSet<String>.literal({}),
      isA<ImmutableSetLiteral<String>>(),
    );
    expect(const ImmutableSet.literal({1}), isA<ImmutableSetLiteral<int>>());
    expect(
      const ImmutableSet<int>.literal({}),
      isA<ImmutableSetLiteral<int>>(),
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(ImmutableSet.literal({}).isEmpty, isTrue);
    expect(ImmutableSet.literal({}).isNotEmpty, isFalse);

    expect(ImmutableSet<String>.literal({}).isEmpty, isTrue);
    expect(ImmutableSet<String>.literal({}).isNotEmpty, isFalse);

    expect(ImmutableSet.literal({1}).isEmpty, isFalse);
    expect(ImmutableSet.literal({1}).isNotEmpty, isTrue);

    expect(ImmutableSet<int>.literal({}).isEmpty, isTrue);
    expect(ImmutableSet<int>.literal({}).isNotEmpty, isFalse);
  });

  test("hashCode", () {
    expect(
      const ImmutableSet.literal({}) == const ImmutableSet.literal({}),
      isTrue,
    );
    expect(ImmutableSet() == ImmutableSet(), isTrue);
    expect(const ImmutableSet.literal({}) == ImmutableSet(), isTrue);
    expect(const ImmutableSet.literal({}) == ImmutableSet({}), isTrue);
    expect(ImmutableSet() == const ImmutableSet.literal({}), isTrue);
    expect(ImmutableSet({}) == const ImmutableSet.literal({}), isTrue);

    expect(
      const ImmutableSet.literal({1, 2}) == const ImmutableSet.literal({1, 2}),
      isTrue,
    );
    expect(ImmutableSet({1, 2}) == ImmutableSet({1, 2}), isTrue);
    expect(const ImmutableSet.literal({1, 2}) == ImmutableSet({1, 2}), isTrue);
    expect(ImmutableSet({1, 2}) == const ImmutableSet.literal({1, 2}), isTrue);

    var a = ImmutableSet<int>(<int>{});
    var b = const ImmutableSet<String>.literal(<String>{});
    expect(a, b);
    expect(a.hashCode, b.hashCode);

    var x = ImmutableSet({1, 2, 3});
    var y = ImmutableSet({1, 2}).add(3);
    expect(x, y);
    expect(x.hashCode, y.hashCode);
  });

  test("withConfig", () {
    // 1) Regular usage
    final ImmutableSet<int> iset = ImmutableSet.literal({1, 2});

    expect(iset.isDeepEquals, isTrue);

    ImmutableSet<int> iSetNewConfig = iset.withConfig(iset.config.copyWith());

    ImmutableSet<int> iSetNewConfigIdentity = iset.withConfig(
      iset.config.copyWith(isDeepEquals: false),
    );

    expect(iSetNewConfig.isDeepEquals, isTrue);
    expect(iSetNewConfigIdentity.isDeepEquals, isFalse);

    // 2) With non-empty set, non-sorted configs.
    const Set<int> nonemptySet = <int>{1, 2, 3};
    expect(
      const ImmutableSet.literal(
        nonemptySet,
        config: ImmutableSetConfig(isDeepEquals: false),
      ),
      [1, 2, 3],
    );

    // 3) With empty set and different configs.
    const Set<int> emptySet = <int>{};
    const sortedEmptyConstISet = ImmutableSet.literal(
      emptySet,
      config: ImmutableSetConfig(sort: true),
    );
    expect(sortedEmptyConstISet, isEmpty);

    // 4) With non-empty set, sorted configs. We can actually create a sorted const ISet,
    // but it will throw an error if we try to use it. Only EMPTY sorted const ISets
    // are allowed.
    const sortedConstISet = ImmutableSet.literal(
      nonemptySet,
      config: ImmutableSetConfig(sort: true),
    );
    expect(() => sortedConstISet, throwsUnsupportedError);
  });

  test("unlock", () {
    const isetConst = ImmutableSet.literal({1, 2, 3});
    expect(isetConst.unlock, {1, 2, 3});
    expect(isetConst.unlock..add(4), [1, 2, 3, 4]);

    expect(isetConst.unlockLazy, {1, 2, 3});
    expect(isetConst.unlockLazy..add(4), [1, 2, 3, 4]);

    expect(isetConst.unlockView, {1, 2, 3});
    expect(() => isetConst.unlockView..add(4), throwsUnsupportedError);
  });

  test("flush", () {
    const isetConst = ImmutableSet.literal({1, 2, 3});
    expect(isetConst.isFlushed, isTrue);
    isetConst.flush;
    expect(isetConst.isFlushed, isTrue);
    expect(isetConst.unlock, {1, 2, 3});
  });

  test("add/addAll, remove/removeAll", () {
    const isetConst = ImmutableSet.literal({1, 2, 3});
    expect(isetConst.add(4), [1, 2, 3, 4]);
    expect(isetConst.addAll([4, 5, 6]), [1, 2, 3, 4, 5, 6]);
    expect(isetConst.remove(2), [1, 3]);
    expect(isetConst.removeAll({1, 2}), [3]);
  });

  test("ISetConst", () {
    //
    // The default constructor will always use the same const {} internals.
    expect(
      const ImmutableSet.literal({}).same(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({}).same(ImmutableSet.literal({})),
      isFalse,
    );
    expect(
      const ImmutableSet.literal({}).same(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(ImmutableSet.literal({}).same(ImmutableSet.literal({})), isFalse);

    // ---

    // Both ISetConst are const. So they are the same.
    expect(
      const ImmutableSet.literal({}).same(const ImmutableSet.literal({})),
      isTrue,
    );

    // One of the ISetConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableSet.literal({}).same(ImmutableSet.literal({})),
      isFalse,
    );
    expect(
      ImmutableSet.literal({}).same(const ImmutableSet.literal({})),
      isFalse,
    );

    // None of the ISetConst are const. So they are NOT the same.
    expect(ImmutableSet.literal({}).same(ImmutableSet.literal({})), isFalse);

    // ---

    // Both ISetConst are const. So they are the same.
    expect(
      const ImmutableSet.literal({
        1,
        2,
        3,
      }).same(const ImmutableSet.literal({1, 2, 3})),
      isTrue,
    );

    // One of the ISetConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableSet.literal({
        1,
        2,
        3,
      }).same(ImmutableSet.literal({1, 2, 3})),
      isFalse,
    );
    expect(
      ImmutableSet.literal({
        1,
        2,
        3,
      }).same(const ImmutableSet.literal({1, 2, 3})),
      isFalse,
    );

    // None of the ISetConst are const. So they are NOT the same.
    expect(
      ImmutableSet.literal({1, 2, 3}).same(ImmutableSet.literal({1, 2, 3})),
      isFalse,
    );
  });

  test("Interaction between ISet and ISetConst", () {
    //
    // Empty.
    expect(ImmutableSet.literal({}).same(ImmutableSet()), isFalse);
    expect(ImmutableSet.literal({}).same(ImmutableSet()), isFalse);
    expect(ImmutableSet().same(ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(ImmutableSet.literal({})), isFalse);
    expect(const ImmutableSet.literal({}).same(ImmutableSet()), isFalse);
    expect(const ImmutableSet.literal({}).same(ImmutableSet()), isFalse);
    expect(ImmutableSet().same(const ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(const ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(const ImmutableSet.literal({})), isFalse);
    expect(ImmutableSet().same(const ImmutableSet.literal({})), isFalse);

    // Not Empty.
    expect(ImmutableSet({1, 2}).same(ImmutableSet.literal({1, 2})), isFalse);
    expect(ImmutableSet.literal({1, 2}).same(ImmutableSet({1, 2})), isFalse);
    expect(
      ImmutableSet({1, 2}).same(const ImmutableSet.literal({1, 2})),
      isFalse,
    );
    expect(
      const ImmutableSet.literal({1, 2}).same(ImmutableSet({1, 2})),
      isFalse,
    );

    // equalItems
    expect(ImmutableSet({}).equalItems(ImmutableSet.literal({})), isTrue);
    expect(ImmutableSet({}).equalItems(const ImmutableSet.literal({})), isTrue);
    expect(ImmutableSet().equalItems(const ImmutableSet.literal({})), isTrue);
    expect(ImmutableSet().equalItems(ImmutableSet.literal({})), isTrue);
    expect(
      ImmutableSet({1, 2}).equalItems(ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet.literal({1, 2}).equalItems(ImmutableSet({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet({1, 2}).equalItems(const ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({1, 2}).equalItems(ImmutableSet({1, 2})),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableSet({}).equalItemsAndConfig(ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet({}).equalItemsAndConfig(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet().equalItemsAndConfig(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet().equalItemsAndConfig(ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet({1, 2}).equalItemsAndConfig(ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet.literal({1, 2}).equalItemsAndConfig(ImmutableSet({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet({
        1,
        2,
      }).equalItemsAndConfig(const ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({
        1,
        2,
      }).equalItemsAndConfig(ImmutableSet({1, 2})),
      isTrue,
    );

    // unorderedEqualItems
    expect(
      ImmutableSet({}).unorderedEqualItems(ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet({}).unorderedEqualItems(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet().unorderedEqualItems(const ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet().unorderedEqualItems(ImmutableSet.literal({})),
      isTrue,
    );
    expect(
      ImmutableSet({1, 2}).unorderedEqualItems(ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet({1, 2}).unorderedEqualItems(ImmutableSet.literal({2, 1})),
      isTrue,
    );
    expect(
      ImmutableSet.literal({1, 2}).unorderedEqualItems(ImmutableSet({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet({
        1,
        2,
      }).unorderedEqualItems(const ImmutableSet.literal({1, 2})),
      isTrue,
    );
    expect(
      ImmutableSet({
        1,
        2,
      }).unorderedEqualItems(const ImmutableSet.literal({2, 1})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({
        1,
        2,
      }).unorderedEqualItems(ImmutableSet({1, 2})),
      isTrue,
    );
    expect(
      const ImmutableSet.literal({
        1,
        2,
      }).unorderedEqualItems(ImmutableSet([2, 1])),
      isTrue,
    );
  });

  test("Make sure the internal set is Set<int>, and not Set<Never>", () {
    var l1 = const ImmutableSet<int>.literal({});
    expect(l1.runtimeType.toString(), 'ISetConst<int>');

    var l2 = ImmutableSet<int>({1, 2, 3});
    expect(l2.runtimeType.toString(), 'ISetImpl<int>');

    var l3 = l1.addAll(l2);
    expect(l3.runtimeType.toString(), 'ISetImpl<int>');

    var result = l3.where((int i) => i == 2).toSet();
    expect(result, [2]);
  });

  test("Test we can cast from ISetConst<Never>, when using FromISetMixin.", () {
    MySet<int> mySet1 = MySet.empty();
    mySet1 = mySet1.add(1);
    expect(mySet1, [1]);

    MySet<int> mySet2 = MySet.empty();
    mySet2 = mySet2.addAll([1, 2, 3]);
    expect(mySet2, [1, 2, 3]);
  });
}

class MySet<A extends num>
    with FromISetMixin<A, MySet<A>>
    implements Iterable<A> {
  final ImmutableSet<A> numbs;

  MySet([Iterable<A>? activities]) : numbs = ImmutableSet(activities);

  const MySet.empty() : numbs = const ImmutableSet.literal({});

  @override
  MySet<A> newInstance(ImmutableSet<A> iSet) => MySet<A>(iSet);

  @override
  ImmutableSet<A> get iterable => numbs;
}
