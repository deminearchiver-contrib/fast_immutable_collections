// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
// ignore_for_file: non_const_call_to_literal_constructor
import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = false;
  });

  test("Runtime Type", () {
    expect(const ImmutableListLiteral._([]), isA<ImmutableListLiteral>());
    expect(const ImmutableListLiteral._([]), isA<ImmutableListLiteral>());
    expect(
      const ImmutableListLiteral<String>._([]),
      isA<ImmutableListLiteral<String>>(),
    );
    expect(const ImmutableListLiteral._([1]), isA<ImmutableListLiteral<int>>());
    expect(
      const ImmutableListLiteral<int>._([]),
      isA<ImmutableListLiteral<int>>(),
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const ImmutableListLiteral._([]), isEmpty);
    expect(const ImmutableListLiteral._([]).isEmpty, isTrue);
    expect(const ImmutableListLiteral._([]).isNotEmpty, isFalse);

    expect(const ImmutableListLiteral<String>._([]).isEmpty, isTrue);
    expect(const ImmutableListLiteral<String>._([]).isNotEmpty, isFalse);

    expect(const ImmutableListLiteral._([1]), isNotEmpty);
    expect(const ImmutableListLiteral._([1]).isEmpty, isFalse);
    expect(const ImmutableListLiteral._([1]).isNotEmpty, isTrue);

    expect(const ImmutableListLiteral<int>._([]), isEmpty);
    expect(const ImmutableListLiteral<int>._([]).isEmpty, isTrue);
    expect(const ImmutableListLiteral<int>._([]).isNotEmpty, isFalse);
  });

  test("hashCode", () {
    expect(
      const ImmutableListLiteral._([]) == const ImmutableListLiteral._([]),
      isTrue,
    );
    expect(ImmutableList() == ImmutableList(), isTrue);
    expect(const ImmutableListLiteral._([]) == ImmutableList(), isTrue);
    expect(const ImmutableListLiteral._([]) == ImmutableList([]), isTrue);
    expect(ImmutableList() == const ImmutableListLiteral._([]), isTrue);
    expect(ImmutableList([]) == const ImmutableListLiteral._([]), isTrue);

    expect(
      const ImmutableListLiteral._([1, 2]) ==
          const ImmutableListLiteral._([1, 2]),
      isTrue,
    );
    expect(ImmutableList([1, 2]) == ImmutableList([1, 2]), isTrue);
    expect(
      const ImmutableListLiteral._([1, 2]) == ImmutableList([1, 2]),
      isTrue,
    );
    expect(
      ImmutableList([1, 2]) == const ImmutableListLiteral._([1, 2]),
      isTrue,
    );

    var a = ImmutableList<int>(<int>[]);
    var b = const ImmutableListLiteral<String>._(<String>[]);
    expect(a, b);
    expect(a.hashCode, b.hashCode);

    var x = ImmutableList([1, 2, 3]);
    var y = ImmutableList([1, 2]).add(3);
    expect(x, y);
    expect(x.hashCode, y.hashCode);
  });

  test("withConfig", () {
    // 1) Regular usage
    const ImmutableList<int> ilist = ImmutableListLiteral._([1, 2]);

    expect(ilist.isDeepEquals, isTrue);

    ImmutableList<int> iListNewConfig = ilist.withConfig(
      ilist.config.copyWith(),
    );

    ImmutableList<int> iListNewConfigIdentity = ilist.withConfig(
      ilist.config.copyWith(isDeepEquals: false),
    );

    expect(iListNewConfig.isDeepEquals, isTrue);
    expect(iListNewConfigIdentity.isDeepEquals, isFalse);

    // 2) With empty list and different configs.
    const List<int> emptyList = <int>[];
    expect(
      const ImmutableListLiteral._(
        emptyList,
        config: ImmutableListConfig(cacheHashCode: false),
      ),
      [],
    );

    // 3) With non-empty list and different configs.
    const List<int> nonemptyList = <int>[1, 2, 3];
    expect(
      const ImmutableListLiteral._(
        nonemptyList,
        config: ImmutableListConfig(cacheHashCode: false),
      ),
      [1, 2, 3],
    );
  });

  test("unlock", () {
    const ilistConst = ImmutableListLiteral._([1, 2, 3]);
    expect(ilistConst.unlock, [1, 2, 3]);
    expect(ilistConst.unlock..add(4), [1, 2, 3, 4]);

    expect(ilistConst.unlockLazy, [1, 2, 3]);
    expect(ilistConst.unlockLazy..add(4), [1, 2, 3, 4]);

    expect(ilistConst.unlockView, [1, 2, 3]);
    expect(() => ilistConst.unlockView..add(4), throwsUnsupportedError);
  });

  test("flush", () {
    const ilistConst = ImmutableListLiteral._([1, 2, 3]);
    expect(ilistConst.isFlushed, isTrue);
    ilistConst.flush;
    expect(ilistConst.isFlushed, isTrue);
    expect(ilistConst.unlock, [1, 2, 3]);
  });

  test("add/addAll, remove/removeAll", () {
    const ilistConst = ImmutableListLiteral._([1, 2, 3]);
    expect(ilistConst.add(4), [1, 2, 3, 4]);
    expect(ilistConst.addAll([4, 5, 6]), [1, 2, 3, 4, 5, 6]);
    expect(ilistConst.remove(2), [1, 3]);
    expect(ilistConst.removeAll([1, 2]), [3]);
  });

  test("IListConst", () {
    //
    // The default constructor will always use the same const [] internals.
    expect(
      const ImmutableListLiteral._([]).same(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([]).same(ImmutableListLiteral._([])),
      isFalse,
    );
    expect(
      const ImmutableListLiteral._([]).same(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableListLiteral._([]).same(ImmutableListLiteral._([])),
      isFalse,
    );

    // ---

    // Both IListConst are const. So they are the same.
    expect(
      const ImmutableListLiteral._([]).same(const ImmutableListLiteral._([])),
      isTrue,
    );

    // One of the IListConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableListLiteral._([]).same(ImmutableListLiteral._([])),
      isFalse,
    );
    expect(
      ImmutableListLiteral._([]).same(const ImmutableListLiteral._([])),
      isFalse,
    );

    // None of the IListConst are const. So they are NOT the same.
    expect(
      ImmutableListLiteral._([]).same(ImmutableListLiteral._([])),
      isFalse,
    );

    // ---

    // Both IListConst are const. So they are the same.
    expect(
      const ImmutableListLiteral._([
        1,
        2,
        3,
      ]).same(const ImmutableListLiteral._([1, 2, 3])),
      isTrue,
    );

    // One of the IListConst is const, the other is not. So they are NOT the same.
    expect(
      const ImmutableListLiteral._([
        1,
        2,
        3,
      ]).same(ImmutableListLiteral._([1, 2, 3])),
      isFalse,
    );
    expect(
      ImmutableListLiteral._([
        1,
        2,
        3,
      ]).same(const ImmutableListLiteral._([1, 2, 3])),
      isFalse,
    );

    // None of the IListConst are const. So they are NOT the same.
    expect(
      ImmutableListLiteral._([1, 2, 3]).same(ImmutableListLiteral._([1, 2, 3])),
      isFalse,
    );
  });

  test("Interaction between IList and IListConst", () {
    //
    // Empty.
    expect(ImmutableListLiteral._([]).same(ImmutableList()), isFalse);
    expect(ImmutableListLiteral._([]).same(ImmutableList()), isFalse);
    expect(ImmutableList().same(ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(ImmutableListLiteral._([])), isFalse);
    expect(const ImmutableListLiteral._([]).same(ImmutableList()), isFalse);
    expect(const ImmutableListLiteral._([]).same(ImmutableList()), isFalse);
    expect(ImmutableList().same(const ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(const ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(const ImmutableListLiteral._([])), isFalse);
    expect(ImmutableList().same(const ImmutableListLiteral._([])), isFalse);

    // Not Empty.
    expect(ImmutableList([1, 2]).same(ImmutableListLiteral._([1, 2])), isFalse);
    expect(ImmutableListLiteral._([1, 2]).same(ImmutableList([1, 2])), isFalse);
    expect(
      ImmutableList([1, 2]).same(const ImmutableListLiteral._([1, 2])),
      isFalse,
    );
    expect(
      const ImmutableListLiteral._([1, 2]).same(ImmutableList([1, 2])),
      isFalse,
    );

    // equalItems
    expect(ImmutableList([]).equalItems(ImmutableListLiteral._([])), isTrue);
    expect(
      ImmutableList([]).equalItems(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList().equalItems(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(ImmutableList().equalItems(ImmutableListLiteral._([])), isTrue);
    expect(
      ImmutableList([1, 2]).equalItems(ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      ImmutableListLiteral._([1, 2]).equalItems(ImmutableList([1, 2])),
      isTrue,
    );
    expect(
      ImmutableList([1, 2]).equalItems(const ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([1, 2]).equalItems(ImmutableList([1, 2])),
      isTrue,
    );

    // equalItemsAndConfig
    expect(
      ImmutableList([]).equalItemsAndConfig(ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList([]).equalItemsAndConfig(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList().equalItemsAndConfig(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList().equalItemsAndConfig(ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList([1, 2]).equalItemsAndConfig(ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      ImmutableListLiteral._([1, 2]).equalItemsAndConfig(ImmutableList([1, 2])),
      isTrue,
    );
    expect(
      ImmutableList([
        1,
        2,
      ]).equalItemsAndConfig(const ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([
        1,
        2,
      ]).equalItemsAndConfig(ImmutableList([1, 2])),
      isTrue,
    );

    // unorderedEqualItems
    expect(
      ImmutableList([]).unorderedEqualItems(ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList([]).unorderedEqualItems(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList().unorderedEqualItems(const ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList().unorderedEqualItems(ImmutableListLiteral._([])),
      isTrue,
    );
    expect(
      ImmutableList([1, 2]).unorderedEqualItems(ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      ImmutableList([1, 2]).unorderedEqualItems(ImmutableListLiteral._([2, 1])),
      isTrue,
    );
    expect(
      ImmutableListLiteral._([1, 2]).unorderedEqualItems(ImmutableList([1, 2])),
      isTrue,
    );
    expect(
      ImmutableList([
        1,
        2,
      ]).unorderedEqualItems(const ImmutableListLiteral._([1, 2])),
      isTrue,
    );
    expect(
      ImmutableList([
        1,
        2,
      ]).unorderedEqualItems(const ImmutableListLiteral._([2, 1])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([
        1,
        2,
      ]).unorderedEqualItems(ImmutableList([1, 2])),
      isTrue,
    );
    expect(
      const ImmutableListLiteral._([
        1,
        2,
      ]).unorderedEqualItems(ImmutableList([2, 1])),
      isTrue,
    );
  });

  test("Make sure the internal list is List<int>, and not List<Never>", () {
    var l1 = const ImmutableListLiteral<int>._([]);
    expect(l1.runtimeType.toString(), 'IListConst<int>');

    var l2 = ImmutableList<int>([1, 2, 3]);
    expect(l2.runtimeType.toString(), 'IListImpl<int>');

    var l3 = l1.addAll(l2);
    expect(l3.runtimeType.toString(), 'IListImpl<int>');

    var result = l3.where((int i) => i == 2).toList();
    expect(result, [2]);
  });

  test(
    "Test we can cast from IListConst<Never>, when using FromIListMixin.",
    () {
      MyList<int> myList1 = MyList.empty();
      myList1 = myList1.add(1);
      expect(myList1, [1]);

      MyList<int> myList2 = MyList.empty();
      myList2 = myList2.addAll([1, 2, 3]);
      expect(myList2, [1, 2, 3]);
    },
  );
}

class MyList<A extends num>
    with FromImmutableListMixin<A, MyList<A>>
    implements Iterable<A> {
  final ImmutableList<A> numbs;

  MyList([Iterable<A>? activities]) : numbs = ImmutableList(activities);

  const MyList.empty() : numbs = const ImmutableListLiteral._([]);

  @override
  MyList<A> newInstance(ImmutableList<A> ilist) => MyList<A>(ilist);

  @override
  ImmutableList<A> get iterable => numbs;
}
