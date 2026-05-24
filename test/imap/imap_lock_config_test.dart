// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/src/fic.dart';
import 'package:test/test.dart';

void main() {
  //
  test("lockConfig", () {
    ImmutableCollection.lockConfig();

    expect(() => ImmutableMap.flushFactor = 1000, throwsStateError);
    expect(() => ImmutableMap.resetAllConfigurations(), throwsStateError);
    expect(
      () =>
          ImmutableMap.defaultConfig = ImmutableMapConfig(cacheHashCode: false),
      throwsStateError,
    );
  });
}
