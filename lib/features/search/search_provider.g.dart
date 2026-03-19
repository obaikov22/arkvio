// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchDocumentsHash() => r'362d76c6eb2a304c10aebe1f5f5deb9be437b4e6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [searchDocuments].
@ProviderFor(searchDocuments)
const searchDocumentsProvider = SearchDocumentsFamily();

/// See also [searchDocuments].
class SearchDocumentsFamily extends Family<AsyncValue<List<Document>>> {
  /// See also [searchDocuments].
  const SearchDocumentsFamily();

  /// See also [searchDocuments].
  SearchDocumentsProvider call(String query) {
    return SearchDocumentsProvider(query);
  }

  @override
  SearchDocumentsProvider getProviderOverride(
    covariant SearchDocumentsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchDocumentsProvider';
}

/// See also [searchDocuments].
class SearchDocumentsProvider
    extends AutoDisposeFutureProvider<List<Document>> {
  /// See also [searchDocuments].
  SearchDocumentsProvider(String query)
    : this._internal(
        (ref) => searchDocuments(ref as SearchDocumentsRef, query),
        from: searchDocumentsProvider,
        name: r'searchDocumentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchDocumentsHash,
        dependencies: SearchDocumentsFamily._dependencies,
        allTransitiveDependencies:
            SearchDocumentsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchDocumentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Document>> Function(SearchDocumentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchDocumentsProvider._internal(
        (ref) => create(ref as SearchDocumentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Document>> createElement() {
    return _SearchDocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchDocumentsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchDocumentsRef on AutoDisposeFutureProviderRef<List<Document>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchDocumentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Document>>
    with SearchDocumentsRef {
  _SearchDocumentsProviderElement(super.provider);

  @override
  String get query => (origin as SearchDocumentsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
