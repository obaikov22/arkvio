import 'package:drift/drift.dart';
import 'folders_table.dart';

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().nullable().references(Folders, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  IntColumn get fileSizeKb => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  IntColumn get reminderDays => integer().withDefault(const Constant(7))();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active | done | expired
  TextColumn get tags =>
      text().withDefault(const Constant(''))(); // comma-separated
  TextColumn get content => text().nullable()(); // for notes
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
