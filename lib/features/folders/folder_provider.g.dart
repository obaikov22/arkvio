// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'92a246abcb363d93aa5a028712241f464abc4efe';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$foldersStreamHash() => r'f7fa89cf9cdc95a8e49fd08409aa58027e039b10';

/// See also [foldersStream].
@ProviderFor(foldersStream)
final foldersStreamProvider = AutoDisposeStreamProvider<List<Folder>>.internal(
  foldersStream,
  name: r'foldersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$foldersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FoldersStreamRef = AutoDisposeStreamProviderRef<List<Folder>>;
String _$folderByIdHash() => r'5c044e6c5832cf3426a8710f6429b238f327dab4';

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

/// See also [folderById].
@ProviderFor(folderById)
const folderByIdProvider = FolderByIdFamily();

/// See also [folderById].
class FolderByIdFamily extends Family<AsyncValue<Folder?>> {
  /// See also [folderById].
  const FolderByIdFamily();

  /// See also [folderById].
  FolderByIdProvider call(int id) {
    return FolderByIdProvider(id);
  }

  @override
  FolderByIdProvider getProviderOverride(
    covariant FolderByIdProvider provider,
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
  String? get name => r'folderByIdProvider';
}

/// See also [folderById].
class FolderByIdProvider extends AutoDisposeFutureProvider<Folder?> {
  /// See also [folderById].
  FolderByIdProvider(int id)
    : this._internal(
        (ref) => folderById(ref as FolderByIdRef, id),
        from: folderByIdProvider,
        name: r'folderByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$folderByIdHash,
        dependencies: FolderByIdFamily._dependencies,
        allTransitiveDependencies: FolderByIdFamily._allTransitiveDependencies,
        id: id,
      );

  FolderByIdProvider._internal(
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
    FutureOr<Folder?> Function(FolderByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FolderByIdProvider._internal(
        (ref) => create(ref as FolderByIdRef),
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
  AutoDisposeFutureProviderElement<Folder?> createElement() {
    return _FolderByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderByIdProvider && other.id == id;
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
mixin FolderByIdRef on AutoDisposeFutureProviderRef<Folder?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _FolderByIdProviderElement
    extends AutoDisposeFutureProviderElement<Folder?>
    with FolderByIdRef {
  _FolderByIdProviderElement(super.provider);

  @override
  int get id => (origin as FolderByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
