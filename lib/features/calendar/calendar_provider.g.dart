// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesForDateHash() => r'29d0c30cff798dfc56a818ed4d11c867313585b7';

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

/// See also [notesForDate].
@ProviderFor(notesForDate)
const notesForDateProvider = NotesForDateFamily();

/// See also [notesForDate].
class NotesForDateFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [notesForDate].
  const NotesForDateFamily();

  /// See also [notesForDate].
  NotesForDateProvider call(DateTime date) {
    return NotesForDateProvider(date);
  }

  @override
  NotesForDateProvider getProviderOverride(
    covariant NotesForDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notesForDateProvider';
}

/// See also [notesForDate].
class NotesForDateProvider extends AutoDisposeFutureProvider<List<Note>> {
  /// See also [notesForDate].
  NotesForDateProvider(DateTime date)
    : this._internal(
        (ref) => notesForDate(ref as NotesForDateRef, date),
        from: notesForDateProvider,
        name: r'notesForDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notesForDateHash,
        dependencies: NotesForDateFamily._dependencies,
        allTransitiveDependencies:
            NotesForDateFamily._allTransitiveDependencies,
        date: date,
      );

  NotesForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<Note>> Function(NotesForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotesForDateProvider._internal(
        (ref) => create(ref as NotesForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Note>> createElement() {
    return _NotesForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotesForDateRef on AutoDisposeFutureProviderRef<List<Note>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _NotesForDateProviderElement
    extends AutoDisposeFutureProviderElement<List<Note>>
    with NotesForDateRef {
  _NotesForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as NotesForDateProvider).date;
}

String _$datesWithNotesHash() => r'37cc098d01ddca024c26d26197df0fd96820e27a';

/// See also [datesWithNotes].
@ProviderFor(datesWithNotes)
const datesWithNotesProvider = DatesWithNotesFamily();

/// See also [datesWithNotes].
class DatesWithNotesFamily extends Family<AsyncValue<Set<DateTime>>> {
  /// See also [datesWithNotes].
  const DatesWithNotesFamily();

  /// See also [datesWithNotes].
  DatesWithNotesProvider call(int year, int month) {
    return DatesWithNotesProvider(year, month);
  }

  @override
  DatesWithNotesProvider getProviderOverride(
    covariant DatesWithNotesProvider provider,
  ) {
    return call(provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'datesWithNotesProvider';
}

/// See also [datesWithNotes].
class DatesWithNotesProvider extends AutoDisposeFutureProvider<Set<DateTime>> {
  /// See also [datesWithNotes].
  DatesWithNotesProvider(int year, int month)
    : this._internal(
        (ref) => datesWithNotes(ref as DatesWithNotesRef, year, month),
        from: datesWithNotesProvider,
        name: r'datesWithNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$datesWithNotesHash,
        dependencies: DatesWithNotesFamily._dependencies,
        allTransitiveDependencies:
            DatesWithNotesFamily._allTransitiveDependencies,
        year: year,
        month: month,
      );

  DatesWithNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<Set<DateTime>> Function(DatesWithNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DatesWithNotesProvider._internal(
        (ref) => create(ref as DatesWithNotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Set<DateTime>> createElement() {
    return _DatesWithNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DatesWithNotesProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DatesWithNotesRef on AutoDisposeFutureProviderRef<Set<DateTime>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _DatesWithNotesProviderElement
    extends AutoDisposeFutureProviderElement<Set<DateTime>>
    with DatesWithNotesRef {
  _DatesWithNotesProviderElement(super.provider);

  @override
  int get year => (origin as DatesWithNotesProvider).year;
  @override
  int get month => (origin as DatesWithNotesProvider).month;
}

String _$allNotesForMonthHash() => r'fdd6f2967e98ec1d706fce9509159e0d6a9da0c7';

/// See also [allNotesForMonth].
@ProviderFor(allNotesForMonth)
const allNotesForMonthProvider = AllNotesForMonthFamily();

/// See also [allNotesForMonth].
class AllNotesForMonthFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [allNotesForMonth].
  const AllNotesForMonthFamily();

  /// See also [allNotesForMonth].
  AllNotesForMonthProvider call(int year, int month) {
    return AllNotesForMonthProvider(year, month);
  }

  @override
  AllNotesForMonthProvider getProviderOverride(
    covariant AllNotesForMonthProvider provider,
  ) {
    return call(provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allNotesForMonthProvider';
}

/// See also [allNotesForMonth].
class AllNotesForMonthProvider extends AutoDisposeFutureProvider<List<Note>> {
  /// See also [allNotesForMonth].
  AllNotesForMonthProvider(int year, int month)
    : this._internal(
        (ref) => allNotesForMonth(ref as AllNotesForMonthRef, year, month),
        from: allNotesForMonthProvider,
        name: r'allNotesForMonthProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allNotesForMonthHash,
        dependencies: AllNotesForMonthFamily._dependencies,
        allTransitiveDependencies:
            AllNotesForMonthFamily._allTransitiveDependencies,
        year: year,
        month: month,
      );

  AllNotesForMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<List<Note>> Function(AllNotesForMonthRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllNotesForMonthProvider._internal(
        (ref) => create(ref as AllNotesForMonthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Note>> createElement() {
    return _AllNotesForMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllNotesForMonthProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllNotesForMonthRef on AutoDisposeFutureProviderRef<List<Note>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _AllNotesForMonthProviderElement
    extends AutoDisposeFutureProviderElement<List<Note>>
    with AllNotesForMonthRef {
  _AllNotesForMonthProviderElement(super.provider);

  @override
  int get year => (origin as AllNotesForMonthProvider).year;
  @override
  int get month => (origin as AllNotesForMonthProvider).month;
}

String _$documentsForDateHash() => r'2ac1758bbeeabb30e909d2da2507a5c451a4c518';

/// See also [documentsForDate].
@ProviderFor(documentsForDate)
const documentsForDateProvider = DocumentsForDateFamily();

/// See also [documentsForDate].
class DocumentsForDateFamily extends Family<AsyncValue<List<Document>>> {
  /// See also [documentsForDate].
  const DocumentsForDateFamily();

  /// See also [documentsForDate].
  DocumentsForDateProvider call(DateTime date) {
    return DocumentsForDateProvider(date);
  }

  @override
  DocumentsForDateProvider getProviderOverride(
    covariant DocumentsForDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentsForDateProvider';
}

/// See also [documentsForDate].
class DocumentsForDateProvider
    extends AutoDisposeFutureProvider<List<Document>> {
  /// See also [documentsForDate].
  DocumentsForDateProvider(DateTime date)
    : this._internal(
        (ref) => documentsForDate(ref as DocumentsForDateRef, date),
        from: documentsForDateProvider,
        name: r'documentsForDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentsForDateHash,
        dependencies: DocumentsForDateFamily._dependencies,
        allTransitiveDependencies:
            DocumentsForDateFamily._allTransitiveDependencies,
        date: date,
      );

  DocumentsForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<Document>> Function(DocumentsForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsForDateProvider._internal(
        (ref) => create(ref as DocumentsForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Document>> createElement() {
    return _DocumentsForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentsForDateRef on AutoDisposeFutureProviderRef<List<Document>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DocumentsForDateProviderElement
    extends AutoDisposeFutureProviderElement<List<Document>>
    with DocumentsForDateRef {
  _DocumentsForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as DocumentsForDateProvider).date;
}

String _$datesWithDocumentsHash() =>
    r'ce1bad9c143aad88f3670b9b0c4da8391f9d1203';

/// See also [datesWithDocuments].
@ProviderFor(datesWithDocuments)
const datesWithDocumentsProvider = DatesWithDocumentsFamily();

/// See also [datesWithDocuments].
class DatesWithDocumentsFamily extends Family<AsyncValue<Set<DateTime>>> {
  /// See also [datesWithDocuments].
  const DatesWithDocumentsFamily();

  /// See also [datesWithDocuments].
  DatesWithDocumentsProvider call(int year, int month) {
    return DatesWithDocumentsProvider(year, month);
  }

  @override
  DatesWithDocumentsProvider getProviderOverride(
    covariant DatesWithDocumentsProvider provider,
  ) {
    return call(provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'datesWithDocumentsProvider';
}

/// See also [datesWithDocuments].
class DatesWithDocumentsProvider
    extends AutoDisposeFutureProvider<Set<DateTime>> {
  /// See also [datesWithDocuments].
  DatesWithDocumentsProvider(int year, int month)
    : this._internal(
        (ref) => datesWithDocuments(ref as DatesWithDocumentsRef, year, month),
        from: datesWithDocumentsProvider,
        name: r'datesWithDocumentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$datesWithDocumentsHash,
        dependencies: DatesWithDocumentsFamily._dependencies,
        allTransitiveDependencies:
            DatesWithDocumentsFamily._allTransitiveDependencies,
        year: year,
        month: month,
      );

  DatesWithDocumentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<Set<DateTime>> Function(DatesWithDocumentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DatesWithDocumentsProvider._internal(
        (ref) => create(ref as DatesWithDocumentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Set<DateTime>> createElement() {
    return _DatesWithDocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DatesWithDocumentsProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DatesWithDocumentsRef on AutoDisposeFutureProviderRef<Set<DateTime>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _DatesWithDocumentsProviderElement
    extends AutoDisposeFutureProviderElement<Set<DateTime>>
    with DatesWithDocumentsRef {
  _DatesWithDocumentsProviderElement(super.provider);

  @override
  int get year => (origin as DatesWithDocumentsProvider).year;
  @override
  int get month => (origin as DatesWithDocumentsProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
