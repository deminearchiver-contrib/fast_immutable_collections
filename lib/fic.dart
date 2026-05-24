/// Data objects for working with immutable collections in Dart and Flutter.
/// {@category Collections, Immutable, Flutter}
/// Developed by Marcelo Glasberg (2021) https://glasberg.dev and https://github.com/marcglasberg
// and Philippe Fanaro https://github.com/psygo
/// For more info, see: https://pub.dartlang.org/packages/fast_immutable_collections

library;

export 'src/fic.dart'
    hide
        // Iterator
        IteratorAdd,
        IteratorAddAll,
        IteratorFlat,
        // List
        ImmutableListImplementation,
        ImmutableListEmpty,
        ImmutableListLiteral,
        ImmutableListInternals,
        ImmutableListDelegate,
        ImmutableListAddAllDelegate,
        ImmutableListAddDelegate,
        ImmutableListFlatDelegate,
        // Map
        ImmutableMapImplementation,
        ImmutableMapEmpty,
        ImmutableMapLiteral,
        ImmutableMapInternals,
        ImmutableMapDelegate,
        ImmutableMapAddAllDelegate,
        ImmutableMapAddDelegate,
        ImmutableMapFlatDelegate,
        ImmutableMapReplaceDelegate,
        // Set
        ImmutableSetImplementation,
        ImmutableSetEmpty,
        ImmutableSetLiteral,
        ImmutableSetInternals,
        ImmutableSetDelegate,
        ImmutableSetAddAllDelegate,
        ImmutableSetAddDelegate,
        ImmutableSetFlatDelegate;
