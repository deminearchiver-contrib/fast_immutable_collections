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
    expect(
      const IMapOfSetsConst(ImmutableMapLiteral._({})),
      isA<IMapOfSetsConst>(),
    );
    expect(
      const IMapOfSetsConst(ImmutableMapLiteral._({})),
      isA<IMapOfSetsConst>(),
    );
    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})),
      isA<IMapOfSetsConst<String, int>>(),
    );
    expect(
      const IMapOfSetsConst(
        ImmutableMapLiteral._({
          'a': ImmutableSet<int>.literal({1, 2}),
        }),
      ),
      isA<IMapOfSetsConst<String, int>>(),
    );
    expect(
      const IMapOfSetsConst<String, int>(
        ImmutableMapLiteral._({
          'a': ImmutableSet<int>.literal({1, 2}),
        }),
      ),
      isA<IMapOfSetsConst<String, int>>(),
    );
  });

  test("isEmpty | isNotEmpty", () {
    expect(const IMapOfSetsConst(ImmutableMapLiteral._({})), isEmpty);
    expect(const IMapOfSetsConst(ImmutableMapLiteral._({})).isEmpty, isTrue);
    expect(
      const IMapOfSetsConst(ImmutableMapLiteral._({})).isNotEmpty,
      isFalse,
    );

    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})).isEmpty,
      isTrue,
    );
    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})).isNotEmpty,
      isFalse,
    );

    expect(
      const IMapOfSetsConst(
        ImmutableMapLiteral._({
          'a': ImmutableSet<int>.literal({1, 2}),
        }),
      ),
      isNotEmpty,
    );
    expect(
      const IMapOfSetsConst(
        ImmutableMapLiteral._({
          'a': ImmutableSet<int>.literal({1, 2}),
        }),
      ).isEmpty,
      isFalse,
    );
    expect(
      const IMapOfSetsConst(
        ImmutableMapLiteral._({
          'a': ImmutableSet<int>.literal({1, 2}),
        }),
      ).isNotEmpty,
      isTrue,
    );

    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})),
      isEmpty,
    );
    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})).isEmpty,
      isTrue,
    );
    expect(
      const IMapOfSetsConst<String, int>(ImmutableMapLiteral._({})).isNotEmpty,
      isFalse,
    );
  });
}
