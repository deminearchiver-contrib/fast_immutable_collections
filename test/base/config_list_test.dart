// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  test("isDeepEquals", () {
    expect(ImmutableListConfig().isDeepEquals, isTrue);
    expect(ImmutableListConfig(isDeepEquals: false).isDeepEquals, isFalse);
  });

  test("==", () {
    const ImmutableListConfig configList1 = ImmutableListConfig(),
        configList2 = ImmutableListConfig(isDeepEquals: false);
    final ImmutableListConfig configList3 = ImmutableListConfig(),
        configList4 = ImmutableListConfig(isDeepEquals: false);

    expect(configList1 == configList1, isTrue);
    expect(configList1 == configList2, isFalse);
    expect(configList1 == configList3, isTrue);
    expect(configList2 == configList2, isTrue);
    expect(configList2 == configList3, isFalse);
    expect(configList2 == configList4, isTrue);
  });

  test("copyWith", () {
    const ImmutableListConfig configList1 = ImmutableListConfig(),
        configList2 = ImmutableListConfig(isDeepEquals: false);
    final ImmutableListConfig configList1WithTrue = configList1.copyWith(
          isDeepEquals: true,
        ),
        configList1WithFalse = configList1.copyWith(isDeepEquals: false),
        configList2WithTrue = configList2.copyWith(isDeepEquals: true),
        configList2WithFalse = configList2.copyWith(isDeepEquals: false);

    expect(identical(configList1, configList1WithTrue), isTrue);
    expect(configList1.isDeepEquals, configList1WithTrue.isDeepEquals);
    expect(configList1.isDeepEquals, !configList1WithFalse.isDeepEquals);

    expect(identical(configList2, configList2WithFalse), isTrue);
    expect(configList2.isDeepEquals, configList2WithFalse.isDeepEquals);
    expect(configList2.isDeepEquals, !configList2WithTrue.isDeepEquals);
  });

  test("hashCode", () {
    const ImmutableListConfig configList1 = ImmutableListConfig(),
        configList2 = ImmutableListConfig(isDeepEquals: false);
    expect(configList1.hashCode, ImmutableListConfig().hashCode);
    expect(
      configList2.hashCode,
      ImmutableListConfig(isDeepEquals: false).hashCode,
    );
    expect(configList1.hashCode, isNot(configList2.hashCode));
  });

  test("toString", () {
    const ImmutableListConfig configList1 = ImmutableListConfig(),
        configList2 = ImmutableListConfig(isDeepEquals: false);
    expect(
      configList1.toString(),
      "ConfigList{isDeepEquals: true, cacheHashCode: true}",
    );
    expect(
      configList2.toString(),
      "ConfigList{isDeepEquals: false, cacheHashCode: true}",
    );
  });

  test("defaultConfig", () {
    // 1) Is initially a ConfigList with isDeepEquals = true
    expect(ImmutableList.defaultConfig, const ImmutableListConfig());
    expect(ImmutableList.defaultConfig.isDeepEquals, isTrue);

    // 2) Can modify the default
    ImmutableList.defaultConfig = ImmutableListConfig(isDeepEquals: false);
    expect(
      ImmutableList.defaultConfig,
      const ImmutableListConfig(isDeepEquals: false),
    );
  });
}
