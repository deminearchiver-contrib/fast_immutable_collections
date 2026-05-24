// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  test("lock", () {
    // 1) Typical example
    ImmutableMap<String, int> imap = {"a": 1, "b": 2}.lock;
    expect(imap, isA<ImmutableMap<String, int>>());
    expect(imap.unlock, {"a": 1, "b": 2});
    expect(imap["a"], 1);
    expect(imap["b"], 2);

    // 2) Other Checks
    imap = {"a": 1}.lock;
    expect(imap, isA<ImmutableMap<String, int>>());
    expect(imap.isEmpty, isFalse);
    expect(imap.isNotEmpty, isTrue);

    ImmutableMap<String?, int> imapKeyNullable = {null: 1}.lock;
    expect(imapKeyNullable, isA<ImmutableMap<String?, int>>());
    expect(imapKeyNullable.isEmpty, isFalse);
    expect(imapKeyNullable.isNotEmpty, isTrue);

    ImmutableMap<String, int?> imapValueNullable = {"a": null}.lock;
    expect(imapValueNullable, isA<ImmutableMap<String, int?>>());
    expect(imapValueNullable.isEmpty, isFalse);
    expect(imapValueNullable.isNotEmpty, isTrue);

    ImmutableMap<String?, int?> imapKeyValueNullable = {null: null}.lock;
    expect(imapKeyValueNullable, isA<ImmutableMap<String?, int?>>());
    expect(imapKeyValueNullable.isEmpty, isFalse);
    expect(imapKeyValueNullable.isNotEmpty, isTrue);

    imap = <String, int>{}.lock;
    expect(imap, isA<ImmutableMap<String, int>>());
  });

  test("lockUnsafe", () {
    final Map<String, int> map = {"a": 1, "b": 2};
    final ImmutableMap<String, int> imap = map.lockUnsafe;

    expect(map, imap.unlock);

    map["c"] = 3;
    map["a"] = 10;

    expect(map, imap.unlock);
  });

  test("toIMap", () {
    final Map<String, int> map = {"a": 1, "b": 2};

    // 1) No config
    expect(map.toIMap(), isA<ImmutableMap<String, int>>());
    expect(map.toIMap().unlock, {"a": 1, "b": 2});

    // 2) With config
    expect(
      map.toIMap(ImmutableMapConfig(sort: true)),
      isA<ImmutableMap<String, int>>(),
    );
    expect(map.toIMap(ImmutableMapConfig(sort: true)).unlock, {"a": 1, "b": 2});
    expect(
      map.toIMap(ImmutableMapConfig(sort: true)).config,
      ImmutableMapConfig(sort: true),
    );
  });

  test("mapTo", () {
    Map<String, int> imap = {"x": 1, "b": 2, "c": 3};
    var imap1 = imap.mapTo<String>((String k, int? v) => "$k:$v");
    expect(imap1, ["x:1", "b:2", "c:3"]);
  });
}
