// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

extension FicObjectExtension on Object {
  /// Checks if some object in the format "Obj<T>" has a generic type T.
  ///
  /// Examples:
  /// expect(<int>[1].isOfExactGenericType(int), isTrue);
  /// expect(<num>[1].isOfExactGenericType(num), isTrue);
  /// expect(<int>[1].isOfExactGenericType(num), isFalse);
  /// expect(<num>[1].isOfExactGenericType(int), isFalse);
  bool isOfExactGenericType<T extends Object?>() {
    return runtimeType.toString().endsWith("<$T>");
  }

  /// Checks if some object in the format "Obj1<T>" has a generic type equal to "Obj2<T>".
  ///
  /// Examples:
  /// expect(<int>[1].isOfExactGenericTypeAs(<int>[1]), isTrue);
  /// expect(<num>[1].isOfExactGenericType(<num>[1]), isTrue);
  /// expect(<int>[1].isOfExactGenericType(<num>[1]), isFalse);
  /// expect(<num>[1].isOfExactGenericType(<num>[1]), isFalse);
  bool isOfExactGenericTypeAs<OtherType extends Object>(OtherType other) {
    final runtimeTypeStr = other.runtimeType.toString();
    final pos = runtimeTypeStr.lastIndexOf("<");
    return runtimeType.toString().endsWith(
      "<${runtimeTypeStr.substring(pos + 1)}",
    );
  }
}
