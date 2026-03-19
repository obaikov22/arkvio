import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  DateTimeColumn get date => dateTime()(); // stored as midnight local
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
