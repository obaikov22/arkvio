// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsInFolderHash() => r'be378bc74a01f75d02d463f4b28436116edf34b8';

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

/// See also [documentsInFolder].
@ProviderFor(documentsInFolder)
const documentsInFolderProvider = DocumentsInFolderFamily();

/// See also [documentsInFolder].
class DocumentsInFolderFamily extends Family<AsyncValue<List<Document>>> {
  /// See also [documentsInFolder].
  const DocumentsInFolderFamily();

  /// See also [documentsInFolder].
  DocumentsInFolderProvider call(int folderId) {
    return DocumentsInFolderProvider(folderId);
  }

  @override
  DocumentsInFolderProvider getProviderOverride(
    covariant DocumentsInFolderProvider provider,
  ) {
    return call(provider.folderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentsInFolderProvider';
}

/// See also [documentsInFolder].
class DocumentsInFolderProvider
    extends AutoDisposeStreamProvider<List<Document>> {
  /// See also [documentsInFolder].
  DocumentsInFolderProvider(int folderId)
    : this._internal(
        (ref) => documentsInFolder(ref as DocumentsInFolderRef, folderId),
        from: documentsInFolderProvider,
        name: r'documentsInFolderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentsInFolderHash,
        dependencies: DocumentsInFolderFamily._dependencies,
        allTransitiveDependencies:
            DocumentsInFolderFamily._allTransitiveDependencies,
        folderId: folderId,
      );

  DocumentsInFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final int folderId;

  @override
  Override overrideWith(
    Stream<List<Document>> Function(DocumentsInFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsInFolderProvider._internal(
        (ref) => create(ref as DocumentsInFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Document>> createElement() {
    return _DocumentsInFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsInFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentsInFolderRef on AutoDisposeStreamProviderRef<List<Document>> {
  /// The parameter `folderId` of this provider.
  int get folderId;
}

class _DocumentsInFolderProviderElement
    extends AutoDisposeStreamProviderElement<List<Document>>
    with DocumentsInFolderRef {
  _DocumentsInFolderProviderElement(super.provider);

  @override
  int get folderId => (origin as DocumentsInFolderProvider).folderId;
}

String _$urgentDocumentsHash() => r'64581a2747f700de388ccf8c3f1bcedf4c75a3cb';

/// See also [urgentDocuments].
@ProviderFor(urgentDocuments)
final urgentDocumentsProvider =
    AutoDisposeStreamProvider<List<Document>>.internal(
      urgentDocuments,
      name: r'urgentDocumentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$urgentDocumentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UrgentDocumentsRef = AutoDisposeStreamProviderRef<List<Document>>;
String _$documentByIdHash() => r'2ae2576c9da53ce6a5963ef713581116e7d083b3';

/// See also [documentById].
@ProviderFor(documentById)
const documentByIdProvider = DocumentByIdFamily();

/// See also [documentById].
class DocumentByIdFamily extends Family<AsyncValue<Document?>> {
  /// See also [documentById].
  const DocumentByIdFamily();

  /// See also [documentById].
  DocumentByIdProvider call(int id) {
    return DocumentByIdProvider(id);
  }

  @override
  DocumentByIdProvider getProviderOverride(
    covariant DocumentByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentByIdProvider';
}

/// See also [documentById].
class DocumentByIdProvider extends AutoDisposeStreamProvider<Document?> {
  /// See also [documentById].
  DocumentByIdProvider(int id)
    : this._internal(
        (ref) => documentById(ref as DocumentByIdRef, id),
        from: documentByIdProvider,
        name: r'documentByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentByIdHash,
        dependencies: DocumentByIdFamily._dependencies,
        allTransitiveDependencies:
            DocumentByIdFamily._allTransitiveDependencies,
        id: id,
      );

  DocumentByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<Document?> Function(DocumentByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentByIdProvider._internal(
        (ref) => create(ref as DocumentByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Document?> createElement() {
    return _DocumentByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentByIdRef on AutoDisposeStreamProviderRef<Document?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _DocumentByIdProviderElement
    extends AutoDisposeStreamProviderElement<Document?>
    with DocumentByIdRef {
  _DocumentByIdProviderElement(super.provider);

  @override
  int get id => (origin as DocumentByIdProvider).id;
}

String _$documentCountInFolderHash() =>
    r'8f716d5a11d2d42dcde2bee1b75eb7256f121cd9';

/// See also [documentCountInFolder].
@ProviderFor(documentCountInFolder)
const documentCountInFolderProvider = DocumentCountInFolderFamily();

/// See also [documentCountInFolder].
class DocumentCountInFolderFamily extends Family<AsyncValue<int>> {
  /// See also [documentCountInFolder].
  const DocumentCountInFolderFamily();

  /// See also [documentCountInFolder].
  DocumentCountInFolderProvider call(int folderId) {
    return DocumentCountInFolderProvider(folderId);
  }

  @override
  DocumentCountInFolderProvider getProviderOverride(
    covariant DocumentCountInFolderProvider provider,
  ) {
    return call(provider.folderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentCountInFolderProvider';
}

/// See also [documentCountInFolder].
class DocumentCountInFolderProvider extends AutoDisposeStreamProvider<int> {
  /// See also [documentCountInFolder].
  DocumentCountInFolderProvider(int folderId)
    : this._internal(
        (ref) =>
            documentCountInFolder(ref as DocumentCountInFolderRef, folderId),
        from: documentCountInFolderProvider,
        name: r'documentCountInFolderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentCountInFolderHash,
        dependencies: DocumentCountInFolderFamily._dependencies,
        allTransitiveDependencies:
            DocumentCountInFolderFamily._allTransitiveDependencies,
        folderId: folderId,
      );

  DocumentCountInFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final int folderId;

  @override
  Override overrideWith(
    Stream<int> Function(DocumentCountInFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentCountInFolderProvider._internal(
        (ref) => create(ref as DocumentCountInFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _DocumentCountInFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentCountInFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentCountInFolderRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `folderId` of this provider.
  int get folderId;
}

class _DocumentCountInFolderProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with DocumentCountInFolderRef {
  _DocumentCountInFolderProviderElement(super.provider);

  @override
  int get folderId => (origin as DocumentCountInFolderProvider).folderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
