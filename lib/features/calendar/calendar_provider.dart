import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../folders/folder_provider.dart';

part 'calendar_provider.g.dart';

@riverpod
Future<List<Note>> notesForDate(NotesForDateRef ref, DateTime date) {
  return ref.watch(appDatabaseProvider).notesDao.getNotesForDate(date);
}

@riverpod
Future<Set<DateTime>> datesWithNotes(
  DatesWithNotesRef ref,
  int year,
  int month,
) {
  return ref
      .watch(appDatabaseProvider)
      .notesDao
      .getDatesWithNotes(year, month);
}

@riverpod
Future<List<Note>> allNotesForMonth(
  AllNotesForMonthRef ref,
  int year,
  int month,
) {
  return ref
      .watch(appDatabaseProvider)
      .notesDao
      .getAllNotesForMonth(year, month);
}

@riverpod
Future<List<Document>> documentsForDate(
    DocumentsForDateRef ref, DateTime date) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .getDocumentsForDate(date);
}

@riverpod
Future<Set<DateTime>> datesWithDocuments(
  DatesWithDocumentsRef ref,
  int year,
  int month,
) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .getDatesWithDocuments(year, month);
}
