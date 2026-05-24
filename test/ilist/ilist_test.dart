// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'dart:collection';
import 'dart:math';

import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  setUp(() {
    ImmutableCollection.resetAllConfigurations();
    ImmutableCollection.autoFlush = false;
  });

  test("Runtime Type", () {
    expect(ImmutableList(), isA<ImmutableList>());
    expect(ImmutableList([]), isA<ImmutableList>());
    expect(ImmutableList<String>([]), isA<ImmutableList<String>>());
    expect(ImmutableList([1]), isA<ImmutableList<int>>());
    expect(ImmutableList<int>(), isA<ImmutableList<int>>());
    expect([].lock, isA<ImmutableList>());
    expect(const ImmutableList.emptyLiteral(), isA<ImmutableList>());
    expect(const ImmutableList<int>.emptyLiteral(), isA<ImmutableList<int>>());
    const ImmutableList untypedList = ImmutableList.emptyLiteral();
    expect(untypedList, isA<ImmutableList>());
    const ImmutableList<int> typedList = ImmutableList.emptyLiteral();
    expect(typedList, isA<ImmutableList<int>>());
  });

  test("isEmpty | isNotEmpty", () {
    expect(ImmutableList().isEmpty, isTrue);
    expect(ImmutableList().isNotEmpty, isFalse);

    expect(ImmutableList([]).isEmpty, isTrue);
    expect(ImmutableList([]).isNotEmpty, isFalse);

    expect(ImmutableList<String>([]).isEmpty, isTrue);
    expect(ImmutableList<String>([]).isNotEmpty, isFalse);

    expect(ImmutableList([1]).isEmpty, isFalse);
    expect(ImmutableList([1]).isNotEmpty, isTrue);

    expect(ImmutableList<int>().isEmpty, isTrue);
    expect(ImmutableList<int>().isNotEmpty, isFalse);

    expect([].lock.isEmpty, isTrue);
    expect([].lock.isNotEmpty, isFalse);

    expect(const ImmutableList.emptyLiteral().isEmpty, isTrue);
    expect(const ImmutableList.emptyLiteral().isNotEmpty, isFalse);

    expect(const ImmutableList<String>.emptyLiteral().isEmpty, isTrue);
    expect(const ImmutableList<String>.emptyLiteral().isNotEmpty, isFalse);
  });

  test("Ensuring Immutability", () {
    // 1) add

    // 1.1) Changing the passed mutable list doesn't change the IList
    List<int> original = [1, 2];
    ImmutableList<int> ilist = original.lock;

    expect(ilist, original);

    original.add(3);
    original.add(4);

    expect(original, <int>[1, 2, 3, 4]);
    expect(ilist.unlock, <int>[1, 2]);

    // 1.2) Changing the IList also doesn't change the original list
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, original);

    ImmutableList<int?> iListNew = ilist.add(3);

    expect(original, <int>[1, 2]);
    expect(ilist, <int>[1, 2]);
    expect(iListNew, <int>[1, 2, 3]);

    // 1.3) If the item being passed is a variable, a pointer to it shouldn't exist inside IList
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, original);

    int willChange = 4;
    iListNew = ilist.add(willChange);

    willChange = 5;

    expect(original, <int>[1, 2]);
    expect(ilist, <int>[1, 2]);
    expect(willChange, 5);
    expect(iListNew, <int>[1, 2, 4]);

    // 2) addAll

    // 2.1) Changing the passed mutable list doesn't change the IList
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, <int>[1, 2]);

    original.addAll(<int>[3, 4]);

    expect(original, <int>[1, 2, 3, 4]);
    expect(ilist, <int>[1, 2]);

    // 2.2) Changing the passed immutable list doesn't change the IList
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, <int>[1, 2]);

    iListNew = ilist.addAll(<int>[3, 4]);

    expect(original, <int>[1, 2]);
    expect(ilist, <int>[1, 2]);
    expect(iListNew, <int>[1, 2, 3, 4]);

    // 2.3) If the items being passed are from a variable, it shouldn't have a pointer to the
    // variable
    original = [1, 2];
    final ImmutableList<int?> iList1 = original.lock;
    final ImmutableList<int> iList2 = original.lock;

    expect(iList1, original);
    expect(iList2, original);

    iListNew = iList1.addAll(iList2);
    original.add(3);

    expect(original, <int>[1, 2, 3]);
    expect(iList1, <int>[1, 2]);
    expect(iList2, <int>[1, 2]);
    expect(iListNew, <int>[1, 2, 1, 2]);

    // 3) remove

    // 3.1) Changing the passed mutable list doesn't change the IList
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, [1, 2]);

    original.remove(2);

    expect(original, <int>[1]);
    expect(ilist, <int>[1, 2]);

    // 3.2) Removing from the original IList doesn't change it
    original = [1, 2];
    ilist = original.lock;

    expect(ilist, <int>[1, 2]);

    iListNew = ilist.remove(1);

    expect(original, <int>[1, 2]);
    expect(ilist, <int>[1, 2]);
    expect(iListNew, <int>[2]);
  });

  test("==", () {
    // 1) Simple usage
    ImmutableList<int?> ilist = ImmutableList([1, 2]);
    expect(ilist == ilist, isTrue);
    expect(ilist == ImmutableList([1, 2]), isTrue);
    expect(ilist == ImmutableList([1]), isFalse);
    expect(ilist == ImmutableList(([2, 1])), isFalse);
    expect(ilist == ImmutableList([1, 2]).withIdentityEquals, isFalse);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);

    // 2) identity-equals compares the list instance, not the items
    ilist = ImmutableList([1, 2]).withIdentityEquals;
    expect(ilist == ilist, isTrue);
    expect(ilist == ImmutableList([1, 2]).withIdentityEquals, isFalse);
    expect(ilist == ImmutableList([2, 1]).withIdentityEquals, isFalse);
    expect(ilist == [1, 2].lock, isFalse);
    expect(ilist == ImmutableList([1, 2, 3]).withIdentityEquals, isFalse);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    // 3) deep-equals compares the items, not necessarily the list instance
    ilist = ImmutableList([1, 2]);
    expect(ilist == ImmutableList([1, 2]), isTrue);
    expect(ilist == ImmutableList([2, 1]), isFalse);
    expect(ilist == [1, 2].lock.withDeepEquals, isTrue);
    expect(ilist == ImmutableList([1, 2, 3]), isFalse);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    // 4) deep-equals is always different from ilist with identity-equals
    ilist = ImmutableList([1, 2]);
    expect(ilist.withDeepEquals == ilist.withIdentityEquals, isFalse);
    expect(ilist.withIdentityEquals == ilist.withDeepEquals, isFalse);
    expect(ilist.withDeepEquals == ilist, isTrue);
    expect(ilist == ilist.withDeepEquals, isTrue);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    // 5) isIdentityEquals and isDeepEquals properties
    ilist = ImmutableList([1, 2]);
    expect(ilist.isIdentityEquals, isFalse);
    expect(ilist.isDeepEquals, isTrue);
    expect(ilist.withIdentityEquals.isIdentityEquals, isTrue);
    expect(ilist.withIdentityEquals.isDeepEquals, isFalse);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    // 6) Additional null checks
    ilist = ImmutableList<int>([]);
    expect(ilist == ImmutableList<int>([]), isTrue);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    ilist = ImmutableList<int?>([null]);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isTrue);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    ilist = ImmutableList<int>([1]);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isTrue);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    ilist = ImmutableList<int?>([null, null, null]);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isTrue);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isFalse);

    ilist = ImmutableList<int?>([null, 1, null, 2]);
    expect(ilist == ImmutableList<int>([]), isFalse);
    expect(ilist == ImmutableList<int?>([null]), isFalse);
    expect(ilist == ImmutableList<int>([1]), isFalse);
    expect(ilist == ImmutableList<int?>([null, null, null]), isFalse);
    expect(ilist == ImmutableList<int?>([null, 1, null, 2]), isTrue);
  });

  test("same", () {
    // 1) Regular usage
    ImmutableList<int?> ilist = ImmutableList([1, 2]);
    expect(ilist.same(ilist), isTrue);
    expect(ilist.same(ImmutableList([1, 2])), isFalse);
    expect(ilist.same(ImmutableList([1])), isFalse);
    expect(ilist.same(ImmutableList([2, 1])), isFalse);
    expect(ilist.same(ImmutableList([1, 2]).withIdentityEquals), isFalse);
    expect(
      ilist.same(
        ImmutableList([
          1,
          2,
        ]).withConfig(ImmutableListConfig(cacheHashCode: false)),
      ),
      isFalse,
    );
    expect(ilist.same(ilist.remove(3)), isTrue);
    expect(ilist.same(ImmutableList<int>([])), isFalse);
    expect(ilist.same(ImmutableList<int?>([null])), isFalse);
    expect(ilist.same(ImmutableList<int>([1])), isFalse);
    expect(ilist.same(ImmutableList<int?>([null, null, null])), isFalse);
    expect(ilist.same(ImmutableList<int?>([null, 1, null, 2])), isFalse);

    // 2) Nulls and other checks
  });

  test("equalItemsAndConfig", () {
    final ImmutableList<int> ilist = ImmutableList([1, 2]);
    expect(ilist.equalItemsAndConfig(ilist), isTrue);
    expect(ilist.equalItemsAndConfig(ImmutableList([1, 2])), isTrue);
    expect(ilist.equalItemsAndConfig(ImmutableList([1])), isFalse);
    expect(ilist.equalItemsAndConfig(ImmutableList([2, 1])), isFalse);
    expect(
      ilist.equalItemsAndConfig(ImmutableList([1, 2]).withIdentityEquals),
      isFalse,
    );
    expect(ilist.equalItemsAndConfig(ilist.remove(3)), isTrue);
  });

  test("equalItems", () {
    final ImmutableList<int> ilist = ImmutableList([1, 2]);

    // 1) Regular usage
    expect(ilist.equalItems(ImmutableSet([1, 2])), isTrue);
    expect(
      ilist.equalItems(
        {}
          ..add(1)
          ..add(2),
      ),
      isTrue,
    );
    expect(
      () => ilist.equalItems(
        HashSet()
          ..add(1)
          ..add(2),
      ),
      throwsStateError,
    );

    // 2) Identity
    expect(ilist.equalItems(ilist), isTrue);

    // 3) If IList, will only be equal if in order and the same items
    expect(ilist.equalItems(ImmutableList([2, 1])), isFalse);
    expect(ilist.equalItems(ImmutableList([1, 2])), isTrue);

    // 4) Other Checks
    expect(ilist.equalItems(ImmutableList([1])), isFalse);
    expect(ilist.equalItems(ImmutableList([1, 2, 3])), isFalse);
    expect(ilist.equalItems(ImmutableList([])), isFalse);

    // 5) If Iterable, will only be equal if in order and the same items
    expect(ilist.equalItems({"a": 1}.values), isFalse);
    expect(ilist.equalItems({"a": 2, "b": 1}.values), isFalse);
    expect(ilist.equalItems({"a": 1, "b": 2}.values), isTrue);
  });

  test("unorderedEqualItems", () {
    final ImmutableList<int> ilist = ImmutableList([1, 2]);

    // 1) Identity
    expect(ilist.unorderedEqualItems(ilist), isTrue);

    // 2) If Iterable, then compares each item with no specific order
    expect(ilist.unorderedEqualItems(ImmutableList([1])), isFalse);
    expect(ilist.unorderedEqualItems(ImmutableList([2, 1])), isTrue);
    expect(ilist.unorderedEqualItems(ilist), isTrue);
    expect(ilist.unorderedEqualItems({1}), isFalse);
    expect(ilist.unorderedEqualItems({1, 2}), isTrue);
  });

  test("hashCode", () {
    // 1) deepEquals vs deepEquals
    final ImmutableList<int> ilist = ImmutableList([1, 2]);
    expect(ilist == ImmutableList([1, 2]), isTrue);
    expect(ilist == ImmutableList([1, 2, 3]), isFalse);
    expect(ilist == ImmutableList([2, 1]), isFalse);
    expect(ilist.hashCode, ImmutableList([1, 2]).hashCode);
    expect(ilist.hashCode, isNot(ImmutableList([1, 2, 3]).hashCode));
    expect(ilist.hashCode, isNot(ImmutableList([2, 1]).hashCode));

    // 2) identityEquals vs identityEquals
    final ImmutableList<int> iListWithIdentityEquals = ImmutableList([
      1,
      2,
    ]).withIdentityEquals;
    expect(
      iListWithIdentityEquals == ImmutableList([1, 2]).withIdentityEquals,
      isFalse,
    );
    expect(
      iListWithIdentityEquals == ImmutableList([1, 2, 3]).withIdentityEquals,
      isFalse,
    );
    expect(
      iListWithIdentityEquals == ImmutableList([2, 1]).withIdentityEquals,
      isFalse,
    );
    expect(
      iListWithIdentityEquals.hashCode,
      isNot(ImmutableList([1, 2]).withIdentityEquals.hashCode),
    );
    expect(
      iListWithIdentityEquals.hashCode,
      isNot(ImmutableList([1, 2, 3]).withIdentityEquals.hashCode),
    );
    expect(
      iListWithIdentityEquals.hashCode,
      isNot(ImmutableList([2, 1]).withIdentityEquals.hashCode),
    );

    // 3) deepEquals vs identityEquals
    expect(
      ImmutableList([1, 2]) == ImmutableList([1, 2]).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableList([1, 2]) == ImmutableList([1, 2]).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableList([1, 2, 3]) == ImmutableList([1, 2, 3]).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableList([2, 1]) == ImmutableList([2, 1]).withIdentityEquals,
      isFalse,
    );
    expect(
      ImmutableList([1, 2]).hashCode,
      isNot(ImmutableList([1, 2]).withIdentityEquals.hashCode),
    );
    expect(
      ImmutableList([1, 2]).hashCode,
      isNot(ImmutableList([1, 2]).withIdentityEquals.hashCode),
    );
    expect(
      ImmutableList([1, 2, 3]).hashCode,
      isNot(ImmutableList([1, 2, 3]).withIdentityEquals.hashCode),
    );
    expect(
      ImmutableList([2, 1]).hashCode,
      isNot(ImmutableList([2, 1]).withIdentityEquals.hashCode),
    );

    // 4) When cache is on
    List<int> list = [1, 2, 3];

    final ImmutableList<int> iListWithCache = ImmutableList.unsafe(
      list,
      config: ImmutableListConfig(cacheHashCode: true),
    );

    int hashBefore = iListWithCache.hashCode;

    list.add(4);

    int hashAfter = iListWithCache.hashCode;

    expect(hashAfter, hashBefore);

    // 5) When cache is off
    list = [1, 2, 3];

    final ImmutableList<int> iListWithoutCache = ImmutableList.unsafe(
      list,
      config: ImmutableListConfig(cacheHashCode: false),
    );

    hashBefore = iListWithoutCache.hashCode;

    list.add(4);

    hashAfter = iListWithoutCache.hashCode;

    expect(hashAfter, isNot(hashBefore));
  });

  test("withConfig", () {
    // 1) Regular usage
    final ImmutableList<int> ilist = ImmutableList([1, 2]);

    expect(ilist.isDeepEquals, isTrue);

    ImmutableList<int> iListNewConfig = ilist.withConfig(
      ilist.config.copyWith(),
    );

    ImmutableList<int> iListNewConfigIdentity = ilist.withConfig(
      ilist.config.copyWith(isDeepEquals: false),
    );

    expect(iListNewConfig.isDeepEquals, isTrue);
    expect(iListNewConfigIdentity.isDeepEquals, isFalse);

    // 2) With empty list and different configs
    final ImmutableList<int> emptyIList = <int>[].lock;
    expect(
      ImmutableList.withConfig(
        emptyIList,
        const ImmutableListConfig(cacheHashCode: false),
      ),
      [],
    );

    // 3) With non-empty list and different configs
    final ImmutableList<int> nonemptyIList = <int>[1, 2, 3].lock;
    expect(
      ImmutableList.withConfig(
        nonemptyIList,
        const ImmutableListConfig(cacheHashCode: false),
      ),
      [1, 2, 3],
    );
  });

  test("withConfigFrom", () {
    final ImmutableList<int> ilist = ImmutableList([1, 2]);

    expect(ilist.isDeepEquals, isTrue);

    final ImmutableList<int> iListWithNoDeepEquals = ilist.withConfig(
      ImmutableListConfig(isDeepEquals: false),
    );

    expect(iListWithNoDeepEquals.isDeepEquals, isFalse);

    final ImmutableList<int> iListWithConfig = ilist.withConfigFrom(
      iListWithNoDeepEquals,
    );

    expect(iListWithConfig.isDeepEquals, isFalse);
  });

  test("default factory constructor", () {
    expect(ImmutableList([1, 2, 3]).unlock, [1, 2, 3]);
    expect(identical(ImmutableList([1, 2, 3]).unlock, [1, 2, 3]), isFalse);
  });

  test("unlock", () {
    expect([1, 2, 3].lock.unlock, [1, 2, 3]);
    expect(identical([1, 2, 3].lock.unlock, [1, 2, 3]), isFalse);
  });

  test("fromISet", () {
    expect(ImmutableList.fromISet({1, 2, 3}.lock, config: null), [1, 2, 3]);
  });

  test("orNull", () {
    // 1) Null -> Null
    Iterable<int>? iter;
    expect(ImmutableList.orNull(iter), isNull);

    // 2) Iterable -> IList
    iter = [1, 2, 3];
    expect(
      ImmutableList.orNull(iter),
      allOf(isA<ImmutableList<int>>(), [1, 2, 3]),
    );

    // 3) Iterable with Config -> IList with Config
    ImmutableList<int>? ilist = ImmutableList.orNull(
      iter,
      ImmutableListConfig(isDeepEquals: false),
    );
    expect(ilist, [1, 2, 3]);
    expect(ilist?.config, ImmutableListConfig(isDeepEquals: false));
  });

  test("unsafe", () {
    // 1) Regular usage
    final List<int> list = [1, 2, 3];
    final ImmutableList<int> ilist = ImmutableList.unsafe(
      list,
      config: ImmutableListConfig(),
    );

    expect(list, [1, 2, 3]);
    expect(ilist, [1, 2, 3]);

    list.add(4);

    expect(list, [1, 2, 3, 4]);
    expect(ilist, [1, 2, 3, 4]);

    // 3) Disallowing it
    ImmutableCollection.disallowUnsafeConstructors = true;
    expect(
      () => ImmutableList.unsafe([1, 2, 3], config: ImmutableListConfig()),
      throwsUnsupportedError,
    );
  });

  test("flush", () {
    final ImmutableList<int> ilist = [
      1,
      2,
      3,
    ].lock.add(4).addAll([5, 6]).add(7).addAll([]).addAll([8, 9]);

    expect(ilist.isFlushed, isFalse);

    ilist.flush;

    expect(ilist.isFlushed, isTrue);
    expect(ilist.unlock, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  });

  test("Indirectly testing IteratorFlat, IteratorAdd, and IteratorAddAll.", () {
    // IteratorFlat
    [null, 1].lock.unlock;

    // IteratorAdd
    [null, 1].lock.add(1).add(null).add(2).unlock;

    // IteratorAddAll
    [null, 1].lock
        .add(1)
        .addAll([null])
        .addAll([2, 3])
        .addAll([null, null])
        .addAll([1, null])
        .addAll([null, 1])
        .unlock;
  });

  test("add", () {
    // 1) Regular usage
    expect(<int>[].lock.add(1), [1]);
    expect(<int?>[null].lock.add(1), [null, 1]);
    expect(<int>[1].lock.add(10), [1, 10]);
    expect(<int?>[null, null, null].lock.add(10), [null, null, null, 10]);
    expect(<int?>[null, 1, null, 3].lock.add(10), [null, 1, null, 3, 10]);
    expect([1, 2, 3].lock.add(4), [1, 2, 3, 4]);

    // 2) Adding null
    expect(<int?>[null].lock.add(null), [null, null]);
    expect(<int?>[null, null, null].lock.add(null), [null, null, null, null]);
    expect(<int?>[null, 1, null, 3].lock.add(null), [null, 1, null, 3, null]);
  });

  test("addAll", () {
    // 1) Regular Usage
    expect(<int>[].lock.addAll([1, 2]), [1, 2]);
    expect(<int?>[null].lock.addAll([1, 2]), [null, 1, 2]);
    expect(<int>[1].lock.addAll([2, 3]), [1, 2, 3]);
    expect(<int?>[null, null, null].lock.addAll([1, 2]), [
      null,
      null,
      null,
      1,
      2,
    ]);
    expect(<int?>[null, 1, null, 3].lock.addAll([10, 11]), [
      null,
      1,
      null,
      3,
      10,
      11,
    ]);
    expect([1, 2, 3, 4].lock.addAll([5, 6]), [1, 2, 3, 4, 5, 6]);

    // 2) Adding nulls
    expect(<int?>[null].lock.addAll([null, null]), [null, null, null]);
    expect(<int?>[null, null, null].lock.addAll([null, null]), [
      null,
      null,
      null,
      null,
      null,
    ]);
    expect(<int?>[null, 1, null, 3].lock.addAll([null, null]), [
      null,
      1,
      null,
      3,
      null,
      null,
    ]);

    // 3) Adding null and an item
    expect(<int?>[null].lock.addAll([null, 1]), [null, null, 1]);
    expect(<int?>[null, null, null].lock.addAll([null, 1]), [
      null,
      null,
      null,
      null,
      1,
    ]);
    expect(<int?>[null, 1, null, 3].lock.addAll([null, 1]), [
      null,
      1,
      null,
      3,
      null,
      1,
    ]);
  });

  test("add and addAll at the same time", () {
    expect([1, 2, 3].lock.add(10).addAll([20, 30]).unlock, [
      1,
      2,
      3,
      10,
      20,
      30,
    ]);
  });

  test("+", () {
    // 1) Regular Usage
    expect(<int>[].lock + [1, 2], [1, 2]);
    expect(<int?>[null].lock + [1, 2], [null, 1, 2]);
    expect(<int>[1].lock + [2, 3], [1, 2, 3]);
    expect(<int?>[null, null, null].lock + [1, 2], [null, null, null, 1, 2]);
    expect(<int?>[null, 1, null, 3].lock + [10, 11], [
      null,
      1,
      null,
      3,
      10,
      11,
    ]);
    expect([1, 2, 3, 4].lock + [5, 6], [1, 2, 3, 4, 5, 6]);

    // 2) Adding nulls
    expect(<int?>[null].lock + [null, null], [null, null, null]);
    expect(<int?>[null, null, null].lock + [null, null], [
      null,
      null,
      null,
      null,
      null,
    ]);
    expect(<int?>[null, 1, null, 3].lock + [null, null], [
      null,
      1,
      null,
      3,
      null,
      null,
    ]);

    // 3) Adding null and an item
    expect(<int?>[null].lock + [null, 1], [null, null, 1]);
    expect(<int?>[null, null, null].lock + [null, 1], [
      null,
      null,
      null,
      null,
      1,
    ]);
    expect(<int?>[null, 1, null, 3].lock + [null, 1], [
      null,
      1,
      null,
      3,
      null,
      1,
    ]);
  });

  test("updateById", () {
    // This is way more thoroughly tested under the original implementation,
    // which is under [IterableExtension].
    ImmutableList<int> ilist = [1, 2, 1, 3].lock;

    ImmutableList<int> updatedIList = ilist.updateById([
      3,
      10,
    ], (int item) => item * 10);

    expect(updatedIList, [1, 2, 1, 3, 10]);
  });

  test("remove", () {
    // 1) Regular Usage
    final ImmutableList<int> ilist1 = [1, 2, 3].lock;

    final ImmutableList<int> ilist2 = ilist1.remove(2);
    expect(ilist2.unlock, [1, 3]);

    final ImmutableList<int> ilist3 = ilist2.remove(5);
    expect(ilist3.unlock, [1, 3]);

    final ImmutableList<int> ilist4 = ilist3.remove(1);
    expect(ilist4.unlock, [3]);

    final ImmutableList<int> ilist5 = ilist4.remove(3);
    expect(ilist5.unlock, []);

    final ImmutableList<int> ilist6 = ilist5.remove(7);
    expect(ilist6.unlock, []);

    expect(ilist1, [1, 2, 3]);
    expect(ilist2, [1, 3]);
    expect(ilist3, [1, 3]);
    expect(ilist4, [3]);
    expect(ilist5, []);
    expect(ilist6, []);
    expect(identical(ilist1, ilist2), isFalse);

    // 2) Poking around with nulls
    expect(<int>[].lock.remove(1), <int>[]);

    expect(<int?>[null].lock.remove(null), <int>[]);
    expect(<int?>[null].lock.remove(1), <int?>[null]);

    expect(<int>[1].lock.remove(1), <int>[]);

    expect(<int?>[null, null, null].lock.remove(null), <int?>[null, null]);
    expect(<int?>[null, null, null].lock.remove(1), <int?>[null, null, null]);

    expect(<int?>[null, 1, null, 1].lock.remove(null), <int?>[1, null, 1]);
    expect(<int?>[null, 1, null, 1].lock.remove(1), <int?>[null, null, 1]);
  });

  test("maxLength", () {
    final ImmutableList<int> ilist1 = [1, 2, 3, 4, 5].lock;
    final ImmutableList<int> ilist2 = [5, 3, 5, 8, 12, 18, 32, 2, 1, 9].lock;

    // 1) Regular Usage
    expect(ilist1.maxLength(2), [1, 2]);
    expect(ilist1.maxLength(3), [1, 2, 3]);
    expect(ilist1.maxLength(1), [1]);
    expect(ilist1.maxLength(0), []);
    expect(ilist1.maxLength(ilist1.length), [1, 2, 3, 4, 5]);

    // 2) Invalid Argument
    expect(() => ilist1.maxLength(-1), throwsArgumentError);
    expect(() => ilist1.maxLength(-100), throwsArgumentError);
    expect(ilist1.maxLength(100), [1, 2, 3, 4, 5]);

    // 3) Priority
    expect(ilist2.maxLength(3), [5, 3, 5]);
    expect(
      ilist2.maxLength(100, priority: (int? a, int? b) => a!.compareTo(b!)),
      [5, 3, 5, 8, 12, 18, 32, 2, 1, 9],
    );
    expect(
      ilist2.maxLength(3, priority: (int? a, int? b) => a!.compareTo(b!)),
      [3, 2, 1],
    );
    expect(
      ilist2.maxLength(4, priority: (int? a, int? b) => a!.compareTo(b!)),
      [5, 3, 2, 1],
    );
    expect(
      ilist2.maxLength(5, priority: (int? a, int? b) => a!.compareTo(b!)),
      [5, 3, 5, 2, 1],
    );
    expect(
      ilist2.maxLength(6, priority: (int? a, int? b) => a!.compareTo(b!)),
      [5, 3, 5, 8, 2, 1],
    );
  });

  test("toggle", () {
    ImmutableList<int> ilist = [1, 2, 3, 4, 5].lock;

    // 1) Toggle existing item
    expect(ilist.contains(4), isTrue);
    ilist = ilist.toggle(4);
    expect(ilist.contains(4), isFalse);
    ilist = ilist.toggle(4);
    expect(ilist.contains(4), isTrue);

    // 2) Toggle NON-existing item
    expect(ilist.contains(6), isFalse);
    ilist = ilist.toggle(6);
    expect(ilist.contains(6), isTrue);
    ilist = ilist.toggle(6);
    expect(ilist.contains(6), isFalse);

    // 3) Nulls and other checks
    expect(<int>[].lock.toggle(1), [1]);

    expect(<int?>[null].lock.toggle(1), [null, 1]);
    expect(<int?>[null].lock.toggle(null), []);

    expect(<int>[1].lock.toggle(1), <int>[]);

    expect(<int?>[null, null, null].lock.toggle(1), <int?>[
      null,
      null,
      null,
      1,
    ]);
    expect(<int?>[null, null, null].lock.toggle(null), <int?>[null, null]);

    expect(<int?>[null, 1, null, 1].lock.toggle(1), <int?>[null, null, 1]);
    expect(<int?>[null, 1, null, 1].lock.toggle(null), <int?>[1, null, 1]);
  });

  test("[]", () {
    final ImmutableList<String> ilist = ["a", "b", "c"].lock;
    expect(ilist[0], "a");
    expect(ilist[1], "b");
    expect(ilist[2], "c");
    expect(() => ilist[3], throwsA(isA<RangeError>()));
    expect(() => ilist[100], throwsA(isA<RangeError>()));
    expect(() => ilist[-1], throwsA(isA<RangeError>()));
    expect(() => ilist[-100], throwsA(isA<RangeError>()));
  });

  test("any", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.any((int? v) => v == 4), isTrue);
    expect(ilist.any((int? v) => v == 100), isFalse);
  });

  test("cast", () {
    const TypeMatcher<TypeError> isTypeError = TypeMatcher<TypeError>();
    final Matcher throwsTypeError = throwsA(isTypeError);

    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.cast<num>(), allOf(isA<Iterable<num>>(), [1, 2, 3, 4, 5, 6]));
    expect(() => ilist.cast<String>(), throwsTypeError);
  });

  test("contains", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.contains(2), isTrue);
    expect(ilist.contains(4), isTrue);
    expect(ilist.contains(5), isTrue);
    expect(ilist.contains(100), isFalse);
    expect(ilist.contains(-1), isFalse);
    expect(ilist.contains(-100), isFalse);
    expect(ilist.contains(null), isFalse);
  });

  test("elementAt, get, getOrNull, getAndMap", () {
    var ilist = ["a", "b", "c", "d", "e", "f"].lock;

    // elementAt
    expect(ilist.elementAt(0), "a");
    expect(ilist.elementAt(1), "b");
    expect(ilist.elementAt(2), "c");
    expect(ilist.elementAt(3), "d");
    expect(ilist.elementAt(4), "e");
    expect(ilist.elementAt(5), "f");
    expect(() => ilist.elementAt(6), throwsRangeError);
    expect(() => ilist.elementAt(-1), throwsRangeError);

    // getOrNull
    expect(ilist.getOrNull(0), "a");
    expect(ilist.getOrNull(5), "f");
    expect(ilist.getOrNull(6), null);
    expect(ilist.getOrNull(-1), null);

    // get
    expect(ilist.get(0), "a");
    expect(ilist.get(5), "f");
    expect(() => ilist.get(6), throwsRangeError);
    expect(() => ilist.get(-1), throwsRangeError);

    // get with orElse
    expect(ilist.get(0, orElse: (index) => index.toString()), "a");
    expect(ilist.get(5, orElse: (index) => index.toString()), "f");
    expect(ilist.get(6, orElse: (index) => index.toString()), "6");
    expect(ilist.get(-1, orElse: (index) => index.toString()), "-1");

    // getAndMap
    expect(
      ilist.getAndMap(0, (idx, inRange, value) => "$idx|$inRange|$value"),
      "0|true|a",
    );
    expect(
      ilist.getAndMap(5, (idx, inRange, value) => "$idx|$inRange|$value"),
      "5|true|f",
    );
    expect(
      ilist.getAndMap(6, (idx, inRange, value) => "$idx|$inRange|$value"),
      "6|false|null",
    );
    expect(
      ilist.getAndMap(-1, (idx, inRange, value) => "$idx|$inRange|$value"),
      "-1|false|null",
    );
  });

  test("every", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.every((int? v) => v! > 0), isTrue);
    expect(ilist.every((int? v) => v! < 0), isFalse);
    expect(ilist.every((int? v) => v != 4), isFalse);
  });

  test("expand", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(
      ilist.expand((int v) => [v, v]),
      allOf(isA<Iterable<int>>(), [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6].lock),
    );
    expect(
      ilist.expand((int v) => <int>[]),
      allOf(isA<Iterable<int>>(), <int>[].lock),
    );
  });

  test("inRange", () {
    final ImmutableList<int> ilist = [1, 2, 3].lock;
    expect(ilist.inRange(-100), isFalse);
    expect(ilist.inRange(-1), isFalse);
    expect(ilist.inRange(0), isTrue);
    expect(ilist.inRange(1), isTrue);
    expect(ilist.inRange(2), isTrue);
    expect(ilist.inRange(3), isFalse);
    expect(ilist.inRange(100), isFalse);
  });

  test("length, first, last, single", () {
    // 1) Regular usage
    var ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.length, 6);
    expect(ilist.first, 1);
    expect(ilist.last, 6);

    expect([10].lock.single, 10);
    expect(() => ilist.single, throwsStateError);

    // 2) Flush optimization for length: When length is zero and the underlying _l is not LFlat
    ImmutableCollection.autoFlush = false;
    ilist = [1, 2, 3].lock.addAll([4, 5]).removeAll([1, 2, 3, 4, 5]);

    expect(ilist.length, 0);
  });

  test("firstWhere", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.firstWhere((int? v) => v! > 1, orElse: () => 100), 2);
    expect(ilist.firstWhere((int? v) => v! > 4, orElse: () => 100), 5);
    expect(ilist.firstWhere((int? v) => v! > 5, orElse: () => 100), 6);
    expect(ilist.firstWhere((int? v) => v! > 6, orElse: () => 100), 100);
  });

  test("fold", () {
    expect(
      [1, 2, 3, 4, 5, 6].lock.fold(100, (int p, int e) => p * (1 + e)),
      504000,
    );
  });

  test("scan", () {
    // Basic addition
    expect([1, 2, -8, 24, -5, 6].lock.scan(10, (int p, int e) => p + e), [
      10,
      10 + 1,
      10 + 1 + 2,
      10 + 1 + 2 - 8,
      10 + 1 + 2 - 8 + 24,
      10 + 1 + 2 - 8 + 24 - 5,
      10 + 1 + 2 - 8 + 24 - 5 + 6,
    ]);

    // Empty list returns only initial value
    expect(<int>[].lock.scan(10, (p, e) => p + e), [10]);

    // Single element list
    expect([5].lock.scan(0, (p, e) => p + e), [0, 5]);

    // Multiplication instead of addition
    expect([2, 3, 4].lock.scan(1, (p, e) => p * e), [1, 2, 6, 24]);

    // String concatenation
    expect(['a', 'b', 'c'].lock.scan('', (p, e) => p + e), [
      '',
      'a',
      'ab',
      'abc',
    ]);

    // Type transformation (accumulator type differs from element type)
    expect([1, 2, 3].lock.scan<String>('', (p, e) => '$p$e'), [
      '',
      '1',
      '12',
      '123',
    ]);

    // Verify return type is IList
    final result = [1, 2].lock.scan(0, (p, e) => p + e);
    expect(result, isA<ImmutableList<int>>());
  });

  test("followedBy", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.followedBy([7, 8]), [1, 2, 3, 4, 5, 6, 7, 8]);
    expect(ilist.followedBy([7, 8].lock), [1, 2, 3, 4, 5, 6, 7, 8]);
    expect(ilist.followedBy(<int>[].lock.add(7).addAll([8, 9])), [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
    ]);
  });

  test("forEach", () {
    int result = 100;
    [1, 2, 3, 4, 5, 6].lock.forEach((int v) => result *= 1 + v);
    expect(result, 504000);
  });

  test("join", () {
    expect([1, 2, 3, 4, 5, 6].lock.join(","), "1,2,3,4,5,6");
    expect([].lock.join(","), "");
  });

  test("lastWhere", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.lastWhere((int? v) => v! < 2, orElse: () => 100), 1);
    expect(ilist.lastWhere((int? v) => v! < 5, orElse: () => 100), 4);
    expect(ilist.lastWhere((int? v) => v! < 6, orElse: () => 100), 5);
    expect(ilist.lastWhere((int? v) => v! < 7, orElse: () => 100), 6);
    expect(ilist.lastWhere((int? v) => v! < 50, orElse: () => 100), 6);
    expect(ilist.lastWhere((int? v) => v! < 1, orElse: () => 100), 100);
  });

  test("map", () {
    expect([1, 2, 3].lock.map((int v) => v + 1), [2, 3, 4]);
    expect([1, 2, 3, 4, 5, 6].lock.map((int v) => v + 1), [2, 3, 4, 5, 6, 7]);
  });

  test("reduce", () {
    // 1) Regular usage
    expect([1, 2, 3, 4, 5, 6].lock.reduce((int p, int e) => p * (1 + e)), 2520);
    expect([5].lock.reduce((int p, int e) => p * (1 + e)), 5);

    // 2) State Exception
    expect(
      () => ImmutableList().reduce(
        (dynamic p, dynamic e) => p * (1 + (e as num)),
      ),
      throwsStateError,
    );
  });

  test("singleWhere", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;

    // 1) Regular usage
    expect(ilist.singleWhere((int? v) => v == 4, orElse: () => 100), 4);
    expect(ilist.singleWhere((int? v) => v == 50, orElse: () => 100), 100);

    // 2) State Exception
    expect(
      () => ilist.singleWhere((int? v) => v! < 4, orElse: () => 100),
      throwsStateError,
    );
  });

  test("skip", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.skip(1), [2, 3, 4, 5, 6]);
    expect(ilist.skip(3), [4, 5, 6]);
    expect(ilist.skip(5), [6]);
    expect(ilist.skip(10), <int>[]);
    expect(() => ilist.skip(-1), throwsRangeError);
  });

  test("skipWhile", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.skipWhile((int? v) => v! < 3), [3, 4, 5, 6]);
    expect(ilist.skipWhile((int? v) => v! < 5), [5, 6]);
    expect(ilist.skipWhile((int? v) => v! < 6), [6]);
    expect(ilist.skipWhile((int? v) => v! < 100), []);
  });

  test("take", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.take(0), []);
    expect(ilist.take(1), [1]);
    expect(ilist.take(3), [1, 2, 3]);
    expect(ilist.take(5), [1, 2, 3, 4, 5]);
    expect(ilist.take(10), [1, 2, 3, 4, 5, 6]);
    expect(() => ilist.take(-1), throwsRangeError);
    expect(() => ilist.take(-100), throwsRangeError);
  });

  test("takeWhile", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.takeWhile((int? v) => v! < 3), [1, 2]);
    expect(ilist.takeWhile((int? v) => v! < 5), [1, 2, 3, 4]);
    expect(ilist.takeWhile((int? v) => v! < 6), [1, 2, 3, 4, 5]);
    expect(ilist.takeWhile((int? v) => v! < 100), [1, 2, 3, 4, 5, 6]);
  });

  test("toList", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;

    // 1) Regular usage
    expect(ilist.toList()..add(7), [1, 2, 3, 4, 5, 6, 7]);
    expect(ilist.unlock, [1, 2, 3, 4, 5, 6]);

    // 2) Unsupported Exception
    expect(() => ilist.toList(growable: false)..add(7), throwsUnsupportedError);
  });

  test("toSet", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;
    expect(ilist.toSet()..add(7), {1, 2, 3, 4, 5, 6, 7});
    expect(ilist.add(6).toSet(), {1, 2, 3, 4, 5, 6});
    expect(ilist.unlock, [1, 2, 3, 4, 5, 6]);
  });

  test("where", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;

    expect(ilist.where((int? v) => v! < 0), []);
    expect(ilist.where((int? v) => v! < 3), [1, 2]);
    expect(ilist.where((int? v) => v! < 5), [1, 2, 3, 4]);
    expect(ilist.where((int? v) => v! < 100), [1, 2, 3, 4, 5, 6]);
  });

  test("where NOT", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6].lock;

    expect(ilist.whereNot((int? v) => v! < 0), [1, 2, 3, 4, 5, 6]);
    expect(ilist.whereNot((int? v) => v! < 3), [3, 4, 5, 6]);
    expect(ilist.whereNot((int? v) => v! < 5), [5, 6]);
    expect(ilist.whereNot((int? v) => v! < 100), []);
  });

  test("whereType", () {
    expect(<num>[1, 2, 1.5].lock.whereType<double>(), [1.5]);
  });

  test("iterator", () {
    final Iterator<int> iter = [1, 2, 3, 4, 5, 6].lock.iterator;

    // Throws StateError before first moveNext().
    expect(() => iter.current, throwsStateError);

    expect(iter.moveNext(), isTrue);
    expect(iter.current, 1);
    expect(iter.moveNext(), isTrue);
    expect(iter.current, 2);
    expect(iter.moveNext(), isTrue);
    expect(iter.current, 3);
    expect(iter.moveNext(), isTrue);
    expect(iter.current, 4);
    expect(iter.moveNext(), isTrue);
    expect(iter.current, 5);
    expect(iter.moveNext(), isTrue);
    expect(iter.current, 6);
    expect(iter.moveNext(), isFalse);

    // Throws StateError after last moveNext().
    expect(() => iter.current, throwsStateError);
  });

  test("toString", () {
    // 1) Global configuration prettyPrint == false.
    ImmutableCollection.prettyPrint = false;
    expect([].lock.toString(), "[]");
    expect([1].lock.toString(), "[1]");
    expect([1, 2, 3].lock.toString(), "[1, 2, 3]");

    // ---

    // 2) Global configuration prettyPrint == true.
    ImmutableCollection.prettyPrint = true;
    expect([].lock.toString(), "[]");
    expect([1].lock.toString(), "[1]");
    expect(
      [1, 2, 3].lock.toString(),
      "[\n"
      "   1,\n"
      "   2,\n"
      "   3\n"
      "]",
    );

    // ---

    // 3) Local prettyPrint == false.
    ImmutableCollection.prettyPrint = true;
    expect([].lock.toString(false), "[]");
    expect([1].lock.toString(false), "[1]");
    expect([1, 2, 3].lock.toString(false), "[1, 2, 3]");

    // ---

    // 4) Local prettyPrint == true.
    ImmutableCollection.prettyPrint = false;
    expect([].lock.toString(true), "[]");
    expect([1].lock.toString(true), "[1]");
    expect(
      [1, 2, 3].lock.toString(true),
      "[\n"
      "   1,\n"
      "   2,\n"
      "   3\n"
      "]",
    );
  });

  test("unlockView", () {
    final List<int> unmodifiableListView = [1, 2, 3].lock.unlockView;

    expect(
      unmodifiableListView,
      allOf(isA<List<int>>(), isA<UnmodifiableFromImmutableList<int>>(), [
        1,
        2,
        3,
      ]),
    );
  });

  test("unlockLazy", () {
    final List<int> modifiableListView = [1, 2, 3].lock.unlockLazy;

    expect(
      modifiableListView,
      allOf(isA<List<int>>(), isA<ModifiableFromImmutableList<int>>(), [
        1,
        2,
        3,
      ]),
    );
  });

  test("firstOrNull", () {
    expect(<int>[].lock.firstOrNull, isNull);
    expect(<int>[1, 2].lock.firstOrNull, 1);
  });

  test("lastOrNull", () {
    expect(<int>[].lock.lastOrNull, isNull);
    expect(<int>[1, 2].lock.lastOrNull, 2);
  });

  test("singleOrNull", () {
    expect(<int>[].lock.singleOrNull, isNull);
    expect(<int>[1, 2].lock.singleOrNull, isNull);
    expect(<int>[1].lock.singleOrNull, 1);
  });

  test("firstOr", () {
    expect(<int>[].lock.firstOr(10), 10);
    expect(<int>[1, 2].lock.firstOr(10), 1);
  });

  test("lastOr()", () {
    expect(<int>[].lock.lastOr(10), 10);
    expect(<int>[1, 2].lock.lastOr(10), 2);
  });

  test("singleOr", () {
    expect(<int>[].lock.singleOr(10), 10);
    expect(<int>[1, 2].lock.singleOr(10), 10);
    expect(<int>[1].lock.singleOr(10), 1);
  });

  test("sort", () {
    expect([10, 2, 4, 6, 5].lock.sort(), [2, 4, 5, 6, 10]);
    expect([10, 2, 4, 6, 5].lock.sort((int a, int b) => -a.compareTo(b)), [
      10,
      6,
      5,
      4,
      2,
    ]);
  });

  test("sortOrdered", () {
    expect(
      [10, 2, 4, 6, 5].lock.sortOrdered((int a, int b) => a.compareTo(b)),
      [2, 4, 5, 6, 10],
    );
  });

  test("sortLike", () {
    expect([10, 2, 4, 6, 5].lock.sortLike(const [4, 2]), [4, 2, 10, 6, 5]);
  });

  test("asMap", () {
    expect(
      ["hel", "lo", "there"].lock.asMap(),
      isA<ImmutableMap<int, String>>(),
    );
    expect(["hel", "lo", "there"].lock.asMap().unlock, {
      0: "hel",
      1: "lo",
      2: "there",
    });
  });

  test("clear", () {
    final ImmutableList<int> ilist = ImmutableList.withConfig([
      1,
      2,
      3,
    ], ImmutableListConfig(isDeepEquals: false));

    final ImmutableList<int> iListCleared = ilist.clear();

    expect(iListCleared, allOf(isA<ImmutableList<int>>(), []));
    expect(iListCleared.config.isDeepEquals, isFalse);
  });

  test("indexOf", () {
    var ilist = ["do", "re", "mi", "re"].lock;

    // 1) Regular usage
    expect(ilist.indexOf("re"), 1);
    expect(ilist.indexOf("re", 2), 3);
    expect(ilist.indexOf("fa"), -1);

    // 2) Argument error
    expect(() => ilist.indexOf("re", -1), throwsArgumentError);
    expect(() => ilist.indexOf("re", 4), throwsArgumentError);

    // 3) Zero length
    var emptyList = [].lock;
    expect(emptyList.indexOf("do"), -1);
    expect(() => emptyList.indexOf("do", 1), throwsArgumentError);
    expect(() => emptyList.indexOf("do", 2), throwsArgumentError);
    expect(() => emptyList.indexOf("do", -1), throwsArgumentError);
  });

  test("indexWhere", () {
    final ImmutableList<String> ilist = ["do", "re", "mi", "re"].lock;

    // 1) Start can't be negative or bigger than the length
    expect(
      () => ilist.indexWhere((String? element) => true, -1),
      throwsArgumentError,
    );
    expect(
      () => ilist.indexWhere((String? element) => true, ilist.length + 1),
      throwsArgumentError,
    );

    // 2) Regular usage
    expect(ilist.indexWhere((String? element) => element == "re"), 1);
    expect(ilist.indexWhere((String? element) => element == "re", 2), 3);
    expect(ilist.indexWhere((String? element) => element == "fa"), -1);

    // 3) Empty list or list with a single item
    var emptyIlist = ImmutableList<String>();
    expect(emptyIlist.indexWhere((String? element) => element == "x"), -1);

    emptyIlist = ["do"].lock;
    expect(emptyIlist.indexWhere((String? element) => element == "x"), -1);
    expect(emptyIlist.indexWhere((String? element) => element == "do"), 0);
  });

  test("lastIndexOf", () {
    // 1) Regular Usage
    ImmutableList<String> ilist = ["do", "re", "mi", "re"].lock;
    expect(ilist.lastIndexOf("re", 2), 1);
    expect(ilist.lastIndexOf("re"), 3);
    expect(ilist.lastIndexOf("fa"), -1);

    // 2) Start cannot be smaller than zero
    ilist = ["do", "re", "mi", "re"].lock;
    expect(() => ilist.lastIndexOf("do", -1), throwsArgumentError);
  });

  test("lastIndexWhere", () {
    // 1) Regular usage
    ImmutableList<String> ilist = ["do", "re", "mi", "re"].lock;
    expect(ilist.lastIndexWhere((String? note) => note!.startsWith("r")), 3);
    expect(ilist.lastIndexWhere((String? note) => note!.startsWith("r"), 2), 1);
    expect(ilist.lastIndexWhere((String? note) => note!.startsWith("k")), -1);

    // 2) Start cannot be smaller than zero
    ilist = ["do", "re", "mi", "re"].lock;
    expect(
      () => ilist.lastIndexWhere((String? element) => false, -1),
      throwsArgumentError,
    );
  });

  test("replaceFirst", () {
    var ilist = ["do", "re", "mi", "re"].lock;
    expect(ilist.replaceFirst(from: "re", to: "x"), ["do", "x", "mi", "re"]);
    expect(ilist.replaceFirst(from: "fa", to: "x"), ["do", "re", "mi", "re"]);
  });

  test("replaceAll", () {
    var ilist = ["do", "re", "mi", "re"].lock;
    expect(ilist.replaceAll(from: "re", to: "x"), ["do", "x", "mi", "x"]);
    expect(ilist.replaceAll(from: "fa", to: "x"), ["do", "re", "mi", "re"]);
  });

  test("replaceFirstWhere", () {
    var ilist = ["do", "re", "mi", "re"].lock;

    // 1) Regular usage
    expect(ilist.replaceFirstWhere((String item) => item == "re", (_) => "x"), [
      "do",
      "x",
      "mi",
      "re",
    ]);
    expect(ilist.replaceFirstWhere((String item) => item == "fa", (_) => "x"), [
      "do",
      "re",
      "mi",
      "re",
    ]);

    // 2) addIfNotFound
    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "y",
        (_) => "x",
        addIfNotFound: true,
      ),
      ["do", "re", "mi", "re", "x"],
    );
    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "y",
        (_) => "x",
        addIfNotFound: false,
      ),
      ["do", "re", "mi", "re"],
    );

    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "y",
        (String? item) => (item == null) ? "1" : item + "2",
        addIfNotFound: true,
      ),
      ["do", "re", "mi", "re", "1"],
    );

    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "y",
        (String? item) => (item == null) ? "1" : item + "2",
        addIfNotFound: false,
      ),
      ["do", "re", "mi", "re"],
    );

    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "re",
        (String? item) => (item == null) ? "1" : item + "2",
        addIfNotFound: true,
      ),
      ["do", "re2", "mi", "re"],
    );

    expect(
      ilist.replaceFirstWhere(
        (String item) => item == "re",
        (String? item) => (item == null) ? "1" : item + "2",
        addIfNotFound: false,
      ),
      ["do", "re2", "mi", "re"],
    );
  });

  test("replaceAllWhere", () {
    var ilist = ["do", "re", "mi", "re"].lock;

    expect(ilist.replaceAllWhere((String? item) => item == "re", "x"), [
      "do",
      "x",
      "mi",
      "x",
    ]);
    expect(ilist.replaceAllWhere((String? item) => item == "fa", "x"), [
      "do",
      "re",
      "mi",
      "re",
    ]);
  });

  test("replaceRange", () {
    expect(["a", "b", "c", "d", "e"].lock.replaceRange(1, 4, ["f", "g"]), [
      "a",
      "f",
      "g",
      "e",
    ]);
  });

  test("fillRange", () {
    expect(List<int?>.filled(3, null).lock.fillRange(0, 2, 1), [1, 1, null]);
    expect(List<int?>.filled(3, null).lock, [null, null, null]);
  });

  test("getRange", () {
    final ImmutableList<String> colors = [
      "red",
      "green",
      "blue",
      "orange",
      "pink",
    ].lock;
    final Iterable<String?> range = colors.getRange(1, 4);
    expect(range, ["green", "blue", "orange"]);
    expect(colors, ["red", "green", "blue", "orange", "pink"]);
  });

  test("setRange", () {
    expect([1, 2, 3, 4].lock.setRange(1, 3, [5, 6, 7, 8, 9].lock, 3), [
      1,
      8,
      9,
      4,
    ]);
  });

  test("replace", () {
    expect(["do", "re", "mi", "re"].lock.replace(2, "fa"), [
      "do",
      "re",
      "fa",
      "re",
    ]);
  });

  test("replaceBy", () {
    expect(
      ["do", "re", "mi", "re"].lock.replaceBy(2, (String text) => "|$text|"),
      ["do", "re", "|mi|", "re"],
    );
  });

  test("insert", () {
    expect(["do", "re", "mi", "re"].lock.insert(2, "fa"), [
      "do",
      "re",
      "fa",
      "mi",
      "re",
    ]);
  });

  test("insertAll", () {
    expect(["do", "re", "mi", "re"].lock.insertAll(3, ["fa", "fo", "fu"]), [
      "do",
      "re",
      "mi",
      "fa",
      "fo",
      "fu",
      "re",
    ]);
  });

  test("removeAt", () {
    expect(["do", "re", "mi", "re"].lock.removeAt(2).$1, ["do", "re", "re"]);

    final Output<String> item = Output();
    expect(["do", "re", "mi", "re"].lock.removeAt(1, item), ["do", "mi", "re"]);
    expect(item.value, "re");
  });

  test("removeLast", () {
    final ImmutableList<String> ilist = ["do", "re", "mi", "re"].lock;
    expect(ilist.removeLast(), ["do", "re", "mi"]);
    final Output<String> item = Output();
    expect(ilist.removeLast(item), ["do", "re", "mi"]);
    expect(item.value, "re");
  });

  test("removeRange", () {
    expect(["do", "re", "mi", "re"].lock.removeRange(1, 3), ["do", "re"]);
  });

  test("removeWhere", () {
    expect(
      [
        "one",
        "two",
        "three",
        "four",
      ].lock.removeWhere((String item) => item.length == 3),
      ["three", "four"],
    );
  });

  test("removeAll", () {
    expect([1, 2, 3, 3, 4, 5, 5].lock.removeAll([3, 5]), [1, 2, 4]);
  });

  test("removeMany", () {
    expect(
      ["head", "shoulders", "knees", "head", "toes"].lock.removeMany("head"),
      ["shoulders", "knees", "toes"],
    );
  });

  test("removeNulls", () {
    expect([1, 2, null, 4, null].lock.removeNulls(), [1, 2, 4]);
  });

  test("removeDuplicates", () {
    expect([1, 2, 3, 3, 4, 5, 5].lock.removeDuplicates(), [1, 2, 3, 4, 5]);
  });

  test("removeNullsAndDuplicates", () {
    expect([1, 2, 3, null, 3, 4, null, 5, 5].lock.removeNullsAndDuplicates(), [
      1,
      2,
      3,
      4,
      5,
    ]);
  });

  test("put", () {
    final ImmutableList<int> ilist = [1, 2, 4, 5].lock;

    final ImmutableList<int?> completeIList = ilist.put(2, 3);

    expect(ilist, [1, 2, 4, 5]);
    expect(completeIList, [1, 2, 3, 5]);
  });

  test("IList.process()", () {
    var original = ["do", "re", "mi", "re"].lock;

    // 2) Check all items are tested.
    // Check convert is called for all items that test true.
    int testCount = 0;
    int convertCount = 0;
    var converted = original.process(
      test: (ImmutableList<String?> ilist, int index, String? item) {
        testCount++;
        expect(identical(item, ilist[index]), isTrue);
        return true;
      },
      convert: (ImmutableList<String?> ilist, int index, String? item) {
        convertCount++;
        expect(identical(item, ilist[index]), isTrue);
        return ["x"];
      },
    );
    expect(converted, ["x", "x", "x", "x"]);
    expect(testCount, 4);
    expect(convertCount, 4);

    // 3) Convert only items which tested true.
    converted = original.process(
      test: (_, __, String? item) => item == "re",
      convert: (_, __, String? item) => [item! + item],
    );
    expect(converted, ["do", "rere", "mi", "rere"]);

    // 4) No items satisfy the test.
    converted = original.process(
      test: (_, __, String? item) => item == "fa",
      convert: (_, __, String? item) => [item! + item],
    );
    expect(identical(converted, original), isTrue);

    // 5) Items satisfy the test, but convert returns null.
    converted = original.process(
      test: (_, __, String? item) => true,
      convert: (_, __, String? item) => null,
    );
    expect(identical(converted, original), isTrue);

    // 6) Items satisfy the test, but convert returns the item in a list.
    converted = original.process(
      test: (_, __, String item) => true,
      convert: (_, __, String item) => [item],
    );
    expect(identical(converted, original), isTrue);

    // 7) Convert returns empty.
    converted = original.process(
      test: (_, __, String? item) => item == "re",
      convert: (_, __, String? item) => const [],
    );
    expect(converted, ["do", "mi"]);

    // 8) Convert returns multiple items.
    converted = original.process(
      test: (_, __, String? item) => item == "re",
      convert: (_, __, String? item) => ["re1", "re1", "re3"],
    );
    expect(converted, ["do", "re1", "re1", "re3", "mi", "re1", "re1", "re3"]);

    // 9) If no test is provided, apply to all items.
    converted = original.process(
      convert: (_, __, String? item) => [item! + item],
    );
    expect(converted, ["dodo", "rere", "mimi", "rere"]);
  });

  test("sublist", () {
    final ImmutableList<String> colors = [
      "red",
      "green",
      "blue",
      "orange",
      "pink",
    ].lock;
    expect(colors.sublist(1, 3), ["green", "blue"]);
    expect(colors.sublist(1), ["green", "blue", "orange", "pink"]);
    expect(colors, ["red", "green", "blue", "orange", "pink"]);
  });

  test("retainWhere", () {
    final ImmutableList<String> numbers = ["one", "two", "three", "four"].lock;
    expect(numbers.retainWhere((String? item) => item!.length == 3), [
      "one",
      "two",
    ]);
    expect(numbers, ["one", "two", "three", "four"]);
  });

  test("reversed", () {
    expect(["do", "re", "mi", "re"].lock.reversed, ["re", "mi", "re", "do"]);
  });

  test("setAll", () {
    final ImmutableList<String> ilist = ["a", "b", "c"].lock;
    expect(ilist.setAll(1, ["bee", "sea"]), ["a", "bee", "sea"]);
    expect(ilist, ["a", "b", "c"]);
  });

  test("shuffle", () {
    final ImmutableList<int> ilist = [1, 2, 3, 4, 5, 6, 7, 8, 9].lock;
    expect(ilist.shuffle(Random(0)), [1, 5, 3, 9, 6, 8, 7, 2, 4]);
    expect(ilist.shuffle(Random(1)), [5, 6, 3, 9, 1, 8, 2, 4, 7]);
    expect(ilist.shuffle(Random(2)), [1, 8, 9, 6, 7, 3, 5, 2, 4]);
  });

  test("whereMoveToTheEnd and whereMoveToTheFront", () {
    final ImmutableList<int> numbs = [
      1,
      5,
      20,
      21,
      19,
      16,
      54,
      50,
      23,
      55,
      18,
      20,
      15,
    ].lock;

    // 1) Even numbers to the end.
    expect(numbs.whereMoveToTheEnd((int? n) => n! % 2 == 0), [
      1,
      5,
      21,
      19,
      23,
      55,
      15,
      20,
      16,
      54,
      50,
      18,
      20,
    ]);

    // 2) Even numbers to the start.
    expect(numbs.whereMoveToTheStart((int? n) => n! % 2 == 0), [
      20,
      16,
      54,
      50,
      18,
      20,
      1,
      5,
      21,
      19,
      23,
      55,
      15,
    ]);
  });

  test("flushFactor", () {
    // 1) Default value
    expect(ImmutableList.flushFactor, 500);

    // 2) Setter
    ImmutableList.flushFactor = 100;
    expect(ImmutableList.flushFactor, 100);

    // 3) Can't be smaller than or equal to 0
    expect(() => ImmutableList.flushFactor = 0, throwsStateError);
    expect(() => ImmutableList.flushFactor = -100, throwsStateError);
  });

  test("iter (to get a simple Iterable)", () {
    //
    var list = <int?>[1, 2, 3, 4, 5, 6, 7];
    var ilist = list.lock;

    // -------------

    // 1) List methods that return an Iterable do lazy processing.

    int count1 = 0;

    var iterableFromList = list
        .where((x) {
          count1++;
          return x != null;
        })
        .take(3);

    // Only 3 (not 7) because we're doing it lazily.
    iterableFromList.join();
    expect(count1, 3);

    // Now it's 6 (= 3+3) because we did it lazily AGAIN.
    iterableFromList.join();
    expect(count1, 6);

    // -------------

    // 2) IList methods that return an Iterable do lazy processing.

    int count2 = 0;

    var iterableFromIList = ilist
        .where((x) {
          count2++;
          return x != null;
        })
        .take(3);

    // Only 3 (not 7) because we're doing it lazily.
    iterableFromIList.join();
    expect(count2, 3);

    // Now it's 6 (= 3+3) because we did it lazily AGAIN.
    iterableFromIList.join();
    expect(count2, 6);

    // -------------
  });

  test("Reuse ILists only if they have the exact same generic type.", () {
    //
    // Reuse? No!
    final ImmutableList<int> ilist1 = [1, 2].lock;
    final ImmutableList<num> ilist2 = ImmutableList<num>(ilist1);
    expect(ilist1.runtimeType.toString().endsWith("<int>"), isTrue);
    expect(ilist2.runtimeType.toString().endsWith("<num>"), isTrue);
    expect(identical(ilist1, ilist2), isFalse);

    // Reuse? Yes!
    ImmutableList<num> ilist3 = <num>[1, 2].lock;
    ImmutableList<num> ilist4 = ImmutableList<num>(ilist3);
    expect(identical(ilist3, ilist4), isTrue);

    // Reuse? Yes!
    ImmutableList<int> ilist5 = [1, 2].lock;
    ImmutableList<int> ilist6 = ImmutableList<int>(ilist5);
    expect(identical(ilist5, ilist6), isTrue);

    // Reuse? Yes!
    ImmutableList<int> ilist7 = [1, 2].lock;
    ImmutableList<int> ilist8 = ImmutableList(ilist7);
    expect(identical(ilist7, ilist8), isTrue);
  });

  test("head, tail, init", () {
    final ilist = ["a", "b", "c", "d", "e", "f"].lock;

    expect(ilist.head, "a");
    expect(ilist.tail, ["b", "c", "d", "e", "f"].lock);
    expect(ilist.init, ["a", "b", "c", "d", "e"].lock);
  });

  test("heads, tails, inits", () {
    final ilist = ["a", "b", "c", "d", "e", "f"].lock;

    expect(
      ilist.tails(),
      [
        ["a", "b", "c", "d", "e", "f"].lock,
        ["b", "c", "d", "e", "f"].lock,
        ["c", "d", "e", "f"].lock,
        ["d", "e", "f"].lock,
        ["e", "f"].lock,
        ["f"].lock,
        [].lock,
      ].lock,
    );

    expect(
      ilist.inits(),
      [
        ["a", "b", "c", "d", "e", "f"].lock,
        ["a", "b", "c", "d", "e"].lock,
        ["a", "b", "c", "d"].lock,
        ["a", "b", "c"].lock,
        ["a", "b"].lock,
        ["a"].lock,
        [].lock,
      ].lock,
    );
  });

  test("span", () {
    final ilist = [0, 2, 4, 6, 7, 8, 9, 2].lock;

    final evenSpan = ilist.span((e) => e % 2 == 0);
    expect(evenSpan.$1.toImmutableList(), [0, 2, 4, 6]);
    expect(evenSpan.$2.toImmutableList(), [7, 8, 9, 2]);
  });

  test("Zip with Index", () {
    //
    final ilist1 = ['red', 'green', 'blue', 'alpha'].lock;
    final indexZipped = ilist1.zipWithIndex();
    expect(
      indexZipped,
      ImmutableList([(0, 'red'), (1, 'green'), (2, 'blue'), (3, 'alpha')]),
    );
  });

  test(
    "Zip with another source of same or different length ignoring the longer Iterable",
    () {
      //
      final countries = ['France', 'Germany', 'Brazil', 'Japan'].lock;
      final capitals = ['Paris', 'Berlin', 'Brasilia', 'Tokyo'].lock;

      final Iterable<(String, String)> zipped = countries.zip(capitals);
      expect(
        zipped,
        ImmutableList([
          ('France', 'Paris'),
          ('Germany', 'Berlin'),
          ('Brazil', 'Brasilia'),
          ('Japan', 'Tokyo'),
        ]),
      );

      // Ignore Brazil Japan
      final Iterable<(String, String)> subIn = countries
          .take(2)
          .toImmutableList()
          .zip(capitals);
      expect(
        subIn,
        ImmutableList([('France', 'Paris'), ('Germany', 'Berlin')]),
      );

      // Ignore Brazil Japan
      final Iterable<(String, String)> subOut = countries.zip(capitals.take(2));
      expect(
        subOut,
        ImmutableList([('France', 'Paris'), ('Germany', 'Berlin')]),
      );

      // different type
      final Iterable<(String, int)> zippedWithInt = countries.zip([
        10,
        20,
        30,
        40,
      ]);
      expect(
        zippedWithInt,
        ImmutableList([
          ('France', 10),
          ('Germany', 20),
          ('Brazil', 30),
          ('Japan', 40),
        ]),
      );
    },
  );

  test(
    "ZipAll with another source replacing with fill method value if available or else null",
    () {
      //
      final countries = <String?>['France', 'Germany', 'Brazil', 'Japan'].lock;
      final capitals = <String?>['Paris', 'Berlin', 'Brasilia', 'Tokyo'].lock;

      expect(
        countries.zipAll(capitals),
        ImmutableList([
          ('France', 'Paris'),
          ('Germany', 'Berlin'),
          ('Brazil', 'Brasilia'),
          ('Japan', 'Tokyo'),
        ]),
      );

      expect(
        countries.zipAll(capitals.take(2)),
        ImmutableList([
          ('France', 'Paris'),
          ('Germany', 'Berlin'),
          ('Brazil', null),
          ('Japan', null),
        ]),
      );

      expect(
        countries
            .take(2)
            .toImmutableList()
            .zipAll(capitals, currentFill: (idx) => 'Country $idx'),
        ImmutableList([
          ('France', 'Paris'),
          ('Germany', 'Berlin'),
          ('Country 2', 'Brasilia'),
          ('Country 3', 'Tokyo'),
        ]),
      );

      expect(
        countries.zipAll([100, 200], otherFill: (idx) => (idx + 1) * 100),
        ImmutableList([
          ('France', 100),
          ('Germany', 200),
          ('Brazil', 300),
          ('Japan', 400),
        ]),
      );

      final unzipped = countries.zipAll(capitals).unzip();
      expect(unzipped.$1.toImmutableList(), countries);
      expect(unzipped.$2.toImmutableList(), capitals);
    },
  );

  test("Iterate apply ops n times to create a list", () {
    expect(ImmutableList.iterate<int>(1, 5, (e) => e + 2), [1, 3, 5, 7, 9]);
  });

  test("Iterate apply ops while Predicate succeed", () {
    expect(ImmutableList.iterateWhile<int>(1, (e) => e < 9, (e) => e + 2), [
      1,
      3,
      5,
      7,
      9,
    ]);
  });

  test("Split at specified index", () {
    final base = [1, 2, 3, 4, 5, 6, 7, 8, 9].lock;
    final split = base.splitAt(4);

    expect(split.$1.toImmutableList(), base.sublist(0, 4));
    expect(split.$2.toImmutableList(), base.sublist(4));
  });

  test("Count on predicates", () {
    expect([1, 3, 5, 7, 9].lock.count((e) => e % 2 == 0), 0);
    expect([2, 4, 6, 8, 10, 11].lock.count((e) => e % 2 == 0), 5);
    expect([1, 3, 5, 7, 9].lock.count((e) => e == 5), 1);
  });

  test("LengthCompare", () {
    expect([1, 3, 5, 7, 9].lock.lengthCompare([9, 8, 7, 6, 5]), true);
    expect([1, 3, 5].lock.lengthCompare([9, 8, 7, 6, 5]), false);
    expect([1, 3, 5, 7, 9].lock.lengthCompare([9, 6, 5]), false);
  });

  test("Corresponds", () {
    expect(
      [1, 2, 3, 4, 5].lock.corresponds([2, 4, 6, 8, 10], (a, b) => a * 2 == b),
      true,
    );
    expect(
      [1, 2, 3, 4, 5].lock.corresponds([2, 4, 60, 8, 10], (a, b) => a * 2 == b),
      false,
    );
    expect(
      [1, 2, 3, 4, 5].lock.corresponds([2, 4, 6, 8], (a, b) => a * 2 == b),
      false,
    );
    expect(
      [1, 2, 3, 4].lock.corresponds([2, 4, 6, 8, 10], (a, b) => a * 2 == b),
      false,
    );
  });

  test("Tabulate", () {
    expect(ImmutableList.tabulate(5, (at) => 'i$at'), [
      'i0',
      'i1',
      'i2',
      'i3',
      'i4',
    ]);

    expect(ImmutableList.tabulate2(3, 2, (at0, at1) => 'i$at0|j$at1'), [
      ['i0|j0', 'i0|j1'],
      ['i1|j0', 'i1|j1'],
      ['i2|j0', 'i2|j1'],
    ]);

    expect(
      ImmutableList.tabulate3(
        3,
        3,
        3,
        (at0, at1, at2) => at0 == at1 && at0 == at2 ? 'X' : 'O',
      ),
      [
        [
          ['X', 'O', 'O'],
          ['O', 'O', 'O'],
          ['O', 'O', 'O'],
        ],
        [
          ['O', 'O', 'O'],
          ['O', 'X', 'O'],
          ['O', 'O', 'O'],
        ],
        [
          ['O', 'O', 'O'],
          ['O', 'O', 'O'],
          ['O', 'O', 'X'],
        ],
      ],
    );

    final by4 = ImmutableList.tabulate4(
      4,
      4,
      4,
      4,
      (at0, at1, at2, at3) =>
          at0 == at1 && at0 == at2 && at0 == at3 ? 'X' : 'O',
    );

    expect(by4.first.first.first.first, 'X');
    expect(by4.last.last.last.last, 'X');

    final by5 = ImmutableList.tabulate5(
      5,
      5,
      5,
      5,
      5,
      (at0, at1, at2, at3, at4) =>
          at0 == at1 && at0 == at2 && at0 == at3 && at0 == at4 ? 'X' : 'O',
    );

    expect(by5.first.first.first.first.first, 'X');
    expect(by5.last.last.last.last.last, 'X');
  });
}
