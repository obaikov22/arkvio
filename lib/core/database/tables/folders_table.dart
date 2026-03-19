import 'package:drift/drift.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get colorHex => text().withDefault(const Constant('#378ADD'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
