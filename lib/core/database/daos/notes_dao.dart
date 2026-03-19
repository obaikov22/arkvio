part of '../app_database.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Future<List<Note>> getNotesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(notes)
          ..where((n) =>
              n.date.isBiggerOrEqualValue(start) &
              n.date.isSmallerThanValue(end))
          ..orderBy([(n) => OrderingTerm.asc(n.createdAt)]))
        .get();
  }

  Future<List<Note>> getAllNotesForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(notes)
          ..where((n) =>
              n.date.isBiggerOrEqualValue(start) &
              n.date.isSmallerThanValue(end))
          ..orderBy([(n) => OrderingTerm.asc(n.date)]))
        .get();
  }

  Future<Set<DateTime>> getDatesWithNotes(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await (select(notes)
          ..where((n) =>
              n.date.isBiggerOrEqualValue(start) &
              n.date.isSmallerThanValue(end)))
        .get();
    return rows
        .map((n) => DateTime(n.date.year, n.date.month, n.date.day))
        .toSet();
  }

  Future<void> insertNote(NotesCompanion note) =>
      into(notes).insert(note);

  Future<void> updateNote(Note note) =>
      update(notes).replace(note.copyWith(updatedAt: DateTime.now()));

  Future<void> deleteNote(int id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();
}
