// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections
// ignore_for_file: prefer_const_constructors, prefer_final_locals, prefer_final_in_for_each
import 'package:fic/fic.dart';
import 'package:test/test.dart';

void main() {
  test("isDeepEquals", () {
    expect(ImmutableMapConfig().isDeepEquals, isTrue);
    expect(ImmutableMapConfig(isDeepEquals: false).isDeepEquals, isFalse);
  });

  test("sort", () {
    expect(ImmutableMapConfig().sort, isFalse);
    expect(ImmutableMapConfig(sort: false).sort, isFalse);
    expect(ImmutableMapConfig(sort: true).sort, isTrue);
  });

  test("cacheHashCode", () {
    expect(ImmutableMapConfig().cacheHashCode, isTrue);
    expect(ImmutableMapConfig(cacheHashCode: false).cacheHashCode, isFalse);
  });

  test("==", () {
    const ImmutableMapConfig configMap1 = ImmutableMapConfig(),
        configMap2 = ImmutableMapConfig(isDeepEquals: false),
        configMap3 = ImmutableMapConfig(sort: true),
        configMap4 = ImmutableMapConfig(cacheHashCode: false);
    final ImmutableMapConfig configMap5 = ImmutableMapConfig(),
        configMap6 = ImmutableMapConfig(isDeepEquals: false),
        configMap7 = ImmutableMapConfig(sort: true),
        configMap8 = ImmutableMapConfig(cacheHashCode: false);

    expect(configMap1 == configMap1, isTrue);
    expect(configMap1 == configMap2, isFalse);
    expect(configMap1 == configMap3, isFalse);
    expect(configMap1 == configMap4, isFalse);
    expect(configMap1 == configMap5, isTrue);
    expect(configMap1 == configMap6, isFalse);
    expect(configMap1 == configMap7, isFalse);
    expect(configMap1 == configMap8, isFalse);

    expect(configMap2 == configMap1, isFalse);
    expect(configMap2 == configMap2, isTrue);
    expect(configMap2 == configMap3, isFalse);
    expect(configMap2 == configMap4, isFalse);
    expect(configMap2 == configMap5, isFalse);
    expect(configMap2 == configMap6, isTrue);
    expect(configMap2 == configMap7, isFalse);
    expect(configMap2 == configMap8, isFalse);

    expect(configMap3 == configMap1, isFalse);
    expect(configMap3 == configMap2, isFalse);
    expect(configMap3 == configMap3, isTrue);
    expect(configMap3 == configMap4, isFalse);
    expect(configMap3 == configMap5, isFalse);
    expect(configMap3 == configMap6, isFalse);
    expect(configMap3 == configMap7, isTrue);
    expect(configMap3 == configMap8, isFalse);

    expect(configMap4 == configMap1, isFalse);
    expect(configMap4 == configMap2, isFalse);
    expect(configMap4 == configMap3, isFalse);
    expect(configMap4 == configMap4, isTrue);
    expect(configMap4 == configMap5, isFalse);
    expect(configMap4 == configMap6, isFalse);
    expect(configMap4 == configMap7, isFalse);
    expect(configMap4 == configMap8, isTrue);
  });

  test("copyWith", () {
    const ImmutableMapConfig configMap1 = ImmutableMapConfig();
    final ImmutableMapConfig configMapIdentical = configMap1.copyWith(),
        configMap1WithDeepFalse = configMap1.copyWith(isDeepEquals: false),
        configMap1WithSortFalse = configMap1.copyWith(sort: true),
        configMap1WithCacheHashCodeFalse = configMap1.copyWith(
          cacheHashCode: false,
        ),
        configMap1WithAllFalse = configMap1.copyWith(
          isDeepEquals: false,
          sort: false,
          cacheHashCode: false,
        );

    expect(identical(configMap1, configMapIdentical), isTrue);

    expect(identical(configMap1, configMap1WithDeepFalse), isFalse);
    expect(configMap1.isDeepEquals, !configMap1WithDeepFalse.isDeepEquals);
    expect(configMap1.sort, configMap1WithDeepFalse.sort);
    expect(configMap1.cacheHashCode, configMap1WithDeepFalse.cacheHashCode);

    expect(identical(configMap1, configMap1WithSortFalse), isFalse);
    expect(configMap1.isDeepEquals, configMap1WithSortFalse.isDeepEquals);
    expect(configMap1.sort, !configMap1WithSortFalse.sort);
    expect(configMap1.cacheHashCode, configMap1WithSortFalse.cacheHashCode);

    expect(identical(configMap1, configMap1WithCacheHashCodeFalse), isFalse);
    expect(
      configMap1.isDeepEquals,
      configMap1WithCacheHashCodeFalse.isDeepEquals,
    );
    expect(configMap1.sort, configMap1WithCacheHashCodeFalse.sort);
    expect(
      configMap1.cacheHashCode,
      !configMap1WithCacheHashCodeFalse.cacheHashCode,
    );

    expect(identical(configMap1, configMap1WithAllFalse), isFalse);
    expect(configMap1.isDeepEquals, !configMap1WithAllFalse.isDeepEquals);
    expect(configMap1.sort, configMap1WithAllFalse.sort);
    expect(configMap1.cacheHashCode, !configMap1WithAllFalse.cacheHashCode);
  });

  test("hashCode", () {
    const ImmutableMapConfig configMap1 = ImmutableMapConfig(),
        configMap2 = ImmutableMapConfig(isDeepEquals: false),
        configMap3 = ImmutableMapConfig(sort: true),
        configMap4 = ImmutableMapConfig(cacheHashCode: false);

    expect(configMap1.hashCode, ImmutableMapConfig().hashCode);
    expect(
      configMap2.hashCode,
      ImmutableMapConfig(isDeepEquals: false).hashCode,
    );
    expect(configMap3.hashCode, ImmutableMapConfig(sort: true).hashCode);
    expect(
      configMap4.hashCode,
      ImmutableMapConfig(cacheHashCode: false).hashCode,
    );
    expect(configMap1.hashCode, isNot(configMap2.hashCode));
    expect(configMap1.hashCode, isNot(configMap3.hashCode));
    expect(configMap1.hashCode, isNot(configMap4.hashCode));
    expect(configMap2.hashCode, isNot(configMap3.hashCode));
    expect(configMap2.hashCode, isNot(configMap4.hashCode));
    expect(configMap3.hashCode, isNot(configMap4.hashCode));
  });

  test("toString", () {
    expect(
      ImmutableMapConfig().toString(),
      "ConfigMap{isDeepEquals: true, sort: false, cacheHashCode: true}",
    );
    expect(
      ImmutableMapConfig(isDeepEquals: false).toString(),
      "ConfigMap{isDeepEquals: false, sort: false, cacheHashCode: true}",
    );
    expect(
      ImmutableMapConfig(sort: true).toString(),
      "ConfigMap{isDeepEquals: true, sort: true, cacheHashCode: true}",
    );
    expect(
      ImmutableMapConfig(cacheHashCode: false).toString(),
      "ConfigMap{isDeepEquals: true, sort: false, cacheHashCode: false}",
    );
  });

  test("defaultConfig", () {
    // 1) Is initially a ConfigMap with all attributes true
    expect(ImmutableMap.defaultConfig, const ImmutableMapConfig());
    expect(ImmutableMap.defaultConfig.isDeepEquals, isTrue);
    expect(ImmutableMap.defaultConfig.sort, isFalse);
    expect(ImmutableMap.defaultConfig.cacheHashCode, isTrue);

    // 2) Can modify the default
    ImmutableMap.defaultConfig = ImmutableMapConfig(
      isDeepEquals: false,
      sort: true,
      cacheHashCode: false,
    );
    expect(
      ImmutableMap.defaultConfig,
      const ImmutableMapConfig(
        isDeepEquals: false,
        sort: true,
        cacheHashCode: false,
      ),
    );
  });
}
