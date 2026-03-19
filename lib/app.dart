import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/database/app_database.dart';
import 'core/navigation/arkvio_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/folders/folder_detail_screen.dart';
import 'features/documents/document_upload_screen.dart';
import 'features/documents/document_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/deadlines/deadlines_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/notes/create_note_screen.dart';
import 'features/whats_new/whats_new_screen.dart';
import 'features/folders/folder_provider.dart';

GoRouter buildRouter(bool onboardingDone, bool showWhatsNew) => GoRouter(
      navigatorKey: ArkvioRouter.navigatorKey,
      initialLocation: !onboardingDone
          ? '/onboarding'
          : showWhatsNew
              ? '/whats_new'
              : '/',
      routes: [
        GoRoute(
            path: '/onboarding',
            builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/folder/:id',
          builder: (_, state) => FolderDetailScreen(
            folderId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/upload',
          builder: (_, state) => DocumentUploadScreen(
            folderId: state.uri.queryParameters['folderId'] != null
                ? int.parse(state.uri.queryParameters['folderId']!)
                : null,
          ),
        ),
        GoRoute(
          path: '/document/:id',
          builder: (_, state) => DocumentDetailScreen(
            documentId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/create-note',
          builder: (_, state) => CreateNoteScreen(
            folderId:
                int.tryParse(state.uri.queryParameters['folderId'] ?? ''),
            editDocumentId:
                int.tryParse(state.uri.queryParameters['editId'] ?? ''),
          ),
        ),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(
            path: '/deadlines', builder: (_, __) => const DeadlinesScreen()),
        GoRoute(
            path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(
            path: '/whats_new', builder: (_, __) => const WhatsNewScreen()),
      ],
    );

class ArkvioApp extends ConsumerStatefulWidget {
  final bool onboardingDone;
  final bool showWhatsNew;
  const ArkvioApp({
    super.key,
    required this.onboardingDone,
    required this.showWhatsNew,
  });

  @override
  ConsumerState<ArkvioApp> createState() => _ArkvioAppState();
}

class _ArkvioAppState extends ConsumerState<ArkvioApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(widget.onboardingDone, widget.showWhatsNew);
    unawaited(_seedDatabase());
  }

  Future<void> _seedDatabase() async {
    final db = ref.read(appDatabaseProvider);
    final count = await db.foldersDao.countFolders();
    if (count > 0) return;

    final dogovoryId = await db.foldersDao.insertFolder(
      const FoldersCompanion(
        name: Value('Договоры'),
        colorHex: Value('#378ADD'),
        sortOrder: Value(0),
      ),
    );
    await db.foldersDao.insertFolder(
      const FoldersCompanion(
        name: Value('Акты'),
        colorHex: Value('#639922'),
        sortOrder: Value(1),
      ),
    );
    await db.foldersDao.insertFolder(
      const FoldersCompanion(
        name: Value('Счета'),
        colorHex: Value('#BA7517'),
        sortOrder: Value(2),
      ),
    );

    await db.documentsDao.insertDocument(
      DocumentsCompanion(
        title: const Value('Договор с ООО Альфа'),
        filePath: const Value(''),
        fileType: const Value('pdf'),
        fileSizeKb: const Value(245),
        folderId: Value(dogovoryId),
        tags: const Value('договор, ООО Альфа'),
        deadlineAt: Value(DateTime.now().add(const Duration(days: 7))),
        reminderDays: const Value(3),
        status: const Value('active'),
      ),
    );
    await db.documentsDao.insertDocument(
      DocumentsCompanion(
        title: const Value('Договор аренды офиса 2025'),
        filePath: const Value(''),
        fileType: const Value('docx'),
        fileSizeKb: const Value(89),
        folderId: Value(dogovoryId),
        tags: const Value('аренда, офис'),
        deadlineAt: Value(DateTime.now().add(const Duration(days: 45))),
        reminderDays: const Value(7),
        status: const Value('active'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Arkvio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
