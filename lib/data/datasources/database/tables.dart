import 'package:drift/drift.dart';

// Team table
@DataClassName("TeamEntity")
class Teams extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Match table
@DataClassName("MatchEntity")
class Matches extends Table {
  TextColumn get id => text()();
  TextColumn get teamId => text()();
  TextColumn get opponentName => text()();
  TextColumn get eventName => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Set table
@DataClassName("SetEntity")
class Sets extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  IntColumn get setIndex => integer()();
  IntColumn get startRotation => integer()(); // 1-6
  TextColumn get startServeReceiveState => text()(); // 'serve' or 'receive'
  IntColumn get ourScore => integer().withDefault(const Constant(0))();
  IntColumn get oppScore => integer().withDefault(const Constant(0))();
  IntColumn get ourTimeoutsUsed => integer().withDefault(const Constant(0))();
  IntColumn get oppTimeoutsUsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {matchId, setIndex}
      ];
}

// Rally table
@DataClassName("RallyEntity")
class Rallies extends Table {
  TextColumn get id => text()();
  TextColumn get setId => text()();
  IntColumn get rallyIndex => integer()();
  IntColumn get rotationAtStart => integer()(); // 1-6
  BoolColumn get weWereServing => boolean()();
  TextColumn get outcome => text()(); // Enum value as string
  BoolColumn get weWon => boolean()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {setId, rallyIndex}
      ];
}
