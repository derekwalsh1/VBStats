// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vbstats_database.dart';

// ignore_for_file: type=lint
class $MatchesTable extends Matches with TableInfo<$MatchesTable, MatchEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opponentNameMeta = const VerificationMeta(
    'opponentName',
  );
  @override
  late final GeneratedColumn<String> opponentName = GeneratedColumn<String>(
    'opponent_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventNameMeta = const VerificationMeta(
    'eventName',
  );
  @override
  late final GeneratedColumn<String> eventName = GeneratedColumn<String>(
    'event_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opponentName,
    eventName,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('opponent_name')) {
      context.handle(
        _opponentNameMeta,
        opponentName.isAcceptableOrUnknown(
          data['opponent_name']!,
          _opponentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opponentNameMeta);
    }
    if (data.containsKey('event_name')) {
      context.handle(
        _eventNameMeta,
        eventName.isAcceptableOrUnknown(data['event_name']!, _eventNameMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      opponentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_name'],
      )!,
      eventName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_name'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class MatchEntity extends DataClass implements Insertable<MatchEntity> {
  final String id;
  final String opponentName;
  final String? eventName;
  final DateTime date;
  final DateTime createdAt;
  const MatchEntity({
    required this.id,
    required this.opponentName,
    this.eventName,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['opponent_name'] = Variable<String>(opponentName);
    if (!nullToAbsent || eventName != null) {
      map['event_name'] = Variable<String>(eventName);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      opponentName: Value(opponentName),
      eventName: eventName == null && nullToAbsent
          ? const Value.absent()
          : Value(eventName),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory MatchEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchEntity(
      id: serializer.fromJson<String>(json['id']),
      opponentName: serializer.fromJson<String>(json['opponentName']),
      eventName: serializer.fromJson<String?>(json['eventName']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'opponentName': serializer.toJson<String>(opponentName),
      'eventName': serializer.toJson<String?>(eventName),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MatchEntity copyWith({
    String? id,
    String? opponentName,
    Value<String?> eventName = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => MatchEntity(
    id: id ?? this.id,
    opponentName: opponentName ?? this.opponentName,
    eventName: eventName.present ? eventName.value : this.eventName,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  MatchEntity copyWithCompanion(MatchesCompanion data) {
    return MatchEntity(
      id: data.id.present ? data.id.value : this.id,
      opponentName: data.opponentName.present
          ? data.opponentName.value
          : this.opponentName,
      eventName: data.eventName.present ? data.eventName.value : this.eventName,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchEntity(')
          ..write('id: $id, ')
          ..write('opponentName: $opponentName, ')
          ..write('eventName: $eventName, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, opponentName, eventName, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchEntity &&
          other.id == this.id &&
          other.opponentName == this.opponentName &&
          other.eventName == this.eventName &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class MatchesCompanion extends UpdateCompanion<MatchEntity> {
  final Value<String> id;
  final Value<String> opponentName;
  final Value<String?> eventName;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.eventName = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    required String opponentName,
    this.eventName = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       opponentName = Value(opponentName),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<MatchEntity> custom({
    Expression<String>? id,
    Expression<String>? opponentName,
    Expression<String>? eventName,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opponentName != null) 'opponent_name': opponentName,
      if (eventName != null) 'event_name': eventName,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? opponentName,
    Value<String?>? eventName,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      opponentName: opponentName ?? this.opponentName,
      eventName: eventName ?? this.eventName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (opponentName.present) {
      map['opponent_name'] = Variable<String>(opponentName.value);
    }
    if (eventName.present) {
      map['event_name'] = Variable<String>(eventName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('opponentName: $opponentName, ')
          ..write('eventName: $eventName, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetsTable extends Sets with TableInfo<$SetsTable, SetEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startRotationMeta = const VerificationMeta(
    'startRotation',
  );
  @override
  late final GeneratedColumn<int> startRotation = GeneratedColumn<int>(
    'start_rotation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startServeReceiveStateMeta =
      const VerificationMeta('startServeReceiveState');
  @override
  late final GeneratedColumn<String> startServeReceiveState =
      GeneratedColumn<String>(
        'start_serve_receive_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ourScoreMeta = const VerificationMeta(
    'ourScore',
  );
  @override
  late final GeneratedColumn<int> ourScore = GeneratedColumn<int>(
    'our_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _oppScoreMeta = const VerificationMeta(
    'oppScore',
  );
  @override
  late final GeneratedColumn<int> oppScore = GeneratedColumn<int>(
    'opp_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ourTimeoutsUsedMeta = const VerificationMeta(
    'ourTimeoutsUsed',
  );
  @override
  late final GeneratedColumn<int> ourTimeoutsUsed = GeneratedColumn<int>(
    'our_timeouts_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _oppTimeoutsUsedMeta = const VerificationMeta(
    'oppTimeoutsUsed',
  );
  @override
  late final GeneratedColumn<int> oppTimeoutsUsed = GeneratedColumn<int>(
    'opp_timeouts_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    setIndex,
    startRotation,
    startServeReceiveState,
    ourScore,
    oppScore,
    ourTimeoutsUsed,
    oppTimeoutsUsed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('start_rotation')) {
      context.handle(
        _startRotationMeta,
        startRotation.isAcceptableOrUnknown(
          data['start_rotation']!,
          _startRotationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startRotationMeta);
    }
    if (data.containsKey('start_serve_receive_state')) {
      context.handle(
        _startServeReceiveStateMeta,
        startServeReceiveState.isAcceptableOrUnknown(
          data['start_serve_receive_state']!,
          _startServeReceiveStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startServeReceiveStateMeta);
    }
    if (data.containsKey('our_score')) {
      context.handle(
        _ourScoreMeta,
        ourScore.isAcceptableOrUnknown(data['our_score']!, _ourScoreMeta),
      );
    }
    if (data.containsKey('opp_score')) {
      context.handle(
        _oppScoreMeta,
        oppScore.isAcceptableOrUnknown(data['opp_score']!, _oppScoreMeta),
      );
    }
    if (data.containsKey('our_timeouts_used')) {
      context.handle(
        _ourTimeoutsUsedMeta,
        ourTimeoutsUsed.isAcceptableOrUnknown(
          data['our_timeouts_used']!,
          _ourTimeoutsUsedMeta,
        ),
      );
    }
    if (data.containsKey('opp_timeouts_used')) {
      context.handle(
        _oppTimeoutsUsedMeta,
        oppTimeoutsUsed.isAcceptableOrUnknown(
          data['opp_timeouts_used']!,
          _oppTimeoutsUsedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {matchId, setIndex},
  ];
  @override
  SetEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      startRotation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_rotation'],
      )!,
      startServeReceiveState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_serve_receive_state'],
      )!,
      ourScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}our_score'],
      )!,
      oppScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opp_score'],
      )!,
      ourTimeoutsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}our_timeouts_used'],
      )!,
      oppTimeoutsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opp_timeouts_used'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SetsTable createAlias(String alias) {
    return $SetsTable(attachedDatabase, alias);
  }
}

class SetEntity extends DataClass implements Insertable<SetEntity> {
  final String id;
  final String matchId;
  final int setIndex;
  final int startRotation;
  final String startServeReceiveState;
  final int ourScore;
  final int oppScore;
  final int ourTimeoutsUsed;
  final int oppTimeoutsUsed;
  final DateTime createdAt;
  const SetEntity({
    required this.id,
    required this.matchId,
    required this.setIndex,
    required this.startRotation,
    required this.startServeReceiveState,
    required this.ourScore,
    required this.oppScore,
    required this.ourTimeoutsUsed,
    required this.oppTimeoutsUsed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['set_index'] = Variable<int>(setIndex);
    map['start_rotation'] = Variable<int>(startRotation);
    map['start_serve_receive_state'] = Variable<String>(startServeReceiveState);
    map['our_score'] = Variable<int>(ourScore);
    map['opp_score'] = Variable<int>(oppScore);
    map['our_timeouts_used'] = Variable<int>(ourTimeoutsUsed);
    map['opp_timeouts_used'] = Variable<int>(oppTimeoutsUsed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SetsCompanion toCompanion(bool nullToAbsent) {
    return SetsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      setIndex: Value(setIndex),
      startRotation: Value(startRotation),
      startServeReceiveState: Value(startServeReceiveState),
      ourScore: Value(ourScore),
      oppScore: Value(oppScore),
      ourTimeoutsUsed: Value(ourTimeoutsUsed),
      oppTimeoutsUsed: Value(oppTimeoutsUsed),
      createdAt: Value(createdAt),
    );
  }

  factory SetEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetEntity(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      startRotation: serializer.fromJson<int>(json['startRotation']),
      startServeReceiveState: serializer.fromJson<String>(
        json['startServeReceiveState'],
      ),
      ourScore: serializer.fromJson<int>(json['ourScore']),
      oppScore: serializer.fromJson<int>(json['oppScore']),
      ourTimeoutsUsed: serializer.fromJson<int>(json['ourTimeoutsUsed']),
      oppTimeoutsUsed: serializer.fromJson<int>(json['oppTimeoutsUsed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'setIndex': serializer.toJson<int>(setIndex),
      'startRotation': serializer.toJson<int>(startRotation),
      'startServeReceiveState': serializer.toJson<String>(
        startServeReceiveState,
      ),
      'ourScore': serializer.toJson<int>(ourScore),
      'oppScore': serializer.toJson<int>(oppScore),
      'ourTimeoutsUsed': serializer.toJson<int>(ourTimeoutsUsed),
      'oppTimeoutsUsed': serializer.toJson<int>(oppTimeoutsUsed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SetEntity copyWith({
    String? id,
    String? matchId,
    int? setIndex,
    int? startRotation,
    String? startServeReceiveState,
    int? ourScore,
    int? oppScore,
    int? ourTimeoutsUsed,
    int? oppTimeoutsUsed,
    DateTime? createdAt,
  }) => SetEntity(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    setIndex: setIndex ?? this.setIndex,
    startRotation: startRotation ?? this.startRotation,
    startServeReceiveState:
        startServeReceiveState ?? this.startServeReceiveState,
    ourScore: ourScore ?? this.ourScore,
    oppScore: oppScore ?? this.oppScore,
    ourTimeoutsUsed: ourTimeoutsUsed ?? this.ourTimeoutsUsed,
    oppTimeoutsUsed: oppTimeoutsUsed ?? this.oppTimeoutsUsed,
    createdAt: createdAt ?? this.createdAt,
  );
  SetEntity copyWithCompanion(SetsCompanion data) {
    return SetEntity(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      startRotation: data.startRotation.present
          ? data.startRotation.value
          : this.startRotation,
      startServeReceiveState: data.startServeReceiveState.present
          ? data.startServeReceiveState.value
          : this.startServeReceiveState,
      ourScore: data.ourScore.present ? data.ourScore.value : this.ourScore,
      oppScore: data.oppScore.present ? data.oppScore.value : this.oppScore,
      ourTimeoutsUsed: data.ourTimeoutsUsed.present
          ? data.ourTimeoutsUsed.value
          : this.ourTimeoutsUsed,
      oppTimeoutsUsed: data.oppTimeoutsUsed.present
          ? data.oppTimeoutsUsed.value
          : this.oppTimeoutsUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetEntity(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('setIndex: $setIndex, ')
          ..write('startRotation: $startRotation, ')
          ..write('startServeReceiveState: $startServeReceiveState, ')
          ..write('ourScore: $ourScore, ')
          ..write('oppScore: $oppScore, ')
          ..write('ourTimeoutsUsed: $ourTimeoutsUsed, ')
          ..write('oppTimeoutsUsed: $oppTimeoutsUsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    matchId,
    setIndex,
    startRotation,
    startServeReceiveState,
    ourScore,
    oppScore,
    ourTimeoutsUsed,
    oppTimeoutsUsed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetEntity &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.setIndex == this.setIndex &&
          other.startRotation == this.startRotation &&
          other.startServeReceiveState == this.startServeReceiveState &&
          other.ourScore == this.ourScore &&
          other.oppScore == this.oppScore &&
          other.ourTimeoutsUsed == this.ourTimeoutsUsed &&
          other.oppTimeoutsUsed == this.oppTimeoutsUsed &&
          other.createdAt == this.createdAt);
}

class SetsCompanion extends UpdateCompanion<SetEntity> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<int> setIndex;
  final Value<int> startRotation;
  final Value<String> startServeReceiveState;
  final Value<int> ourScore;
  final Value<int> oppScore;
  final Value<int> ourTimeoutsUsed;
  final Value<int> oppTimeoutsUsed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.startRotation = const Value.absent(),
    this.startServeReceiveState = const Value.absent(),
    this.ourScore = const Value.absent(),
    this.oppScore = const Value.absent(),
    this.ourTimeoutsUsed = const Value.absent(),
    this.oppTimeoutsUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetsCompanion.insert({
    required String id,
    required String matchId,
    required int setIndex,
    required int startRotation,
    required String startServeReceiveState,
    this.ourScore = const Value.absent(),
    this.oppScore = const Value.absent(),
    this.ourTimeoutsUsed = const Value.absent(),
    this.oppTimeoutsUsed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       matchId = Value(matchId),
       setIndex = Value(setIndex),
       startRotation = Value(startRotation),
       startServeReceiveState = Value(startServeReceiveState),
       createdAt = Value(createdAt);
  static Insertable<SetEntity> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<int>? setIndex,
    Expression<int>? startRotation,
    Expression<String>? startServeReceiveState,
    Expression<int>? ourScore,
    Expression<int>? oppScore,
    Expression<int>? ourTimeoutsUsed,
    Expression<int>? oppTimeoutsUsed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (setIndex != null) 'set_index': setIndex,
      if (startRotation != null) 'start_rotation': startRotation,
      if (startServeReceiveState != null)
        'start_serve_receive_state': startServeReceiveState,
      if (ourScore != null) 'our_score': ourScore,
      if (oppScore != null) 'opp_score': oppScore,
      if (ourTimeoutsUsed != null) 'our_timeouts_used': ourTimeoutsUsed,
      if (oppTimeoutsUsed != null) 'opp_timeouts_used': oppTimeoutsUsed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetsCompanion copyWith({
    Value<String>? id,
    Value<String>? matchId,
    Value<int>? setIndex,
    Value<int>? startRotation,
    Value<String>? startServeReceiveState,
    Value<int>? ourScore,
    Value<int>? oppScore,
    Value<int>? ourTimeoutsUsed,
    Value<int>? oppTimeoutsUsed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SetsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      setIndex: setIndex ?? this.setIndex,
      startRotation: startRotation ?? this.startRotation,
      startServeReceiveState:
          startServeReceiveState ?? this.startServeReceiveState,
      ourScore: ourScore ?? this.ourScore,
      oppScore: oppScore ?? this.oppScore,
      ourTimeoutsUsed: ourTimeoutsUsed ?? this.ourTimeoutsUsed,
      oppTimeoutsUsed: oppTimeoutsUsed ?? this.oppTimeoutsUsed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (startRotation.present) {
      map['start_rotation'] = Variable<int>(startRotation.value);
    }
    if (startServeReceiveState.present) {
      map['start_serve_receive_state'] = Variable<String>(
        startServeReceiveState.value,
      );
    }
    if (ourScore.present) {
      map['our_score'] = Variable<int>(ourScore.value);
    }
    if (oppScore.present) {
      map['opp_score'] = Variable<int>(oppScore.value);
    }
    if (ourTimeoutsUsed.present) {
      map['our_timeouts_used'] = Variable<int>(ourTimeoutsUsed.value);
    }
    if (oppTimeoutsUsed.present) {
      map['opp_timeouts_used'] = Variable<int>(oppTimeoutsUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('setIndex: $setIndex, ')
          ..write('startRotation: $startRotation, ')
          ..write('startServeReceiveState: $startServeReceiveState, ')
          ..write('ourScore: $ourScore, ')
          ..write('oppScore: $oppScore, ')
          ..write('ourTimeoutsUsed: $ourTimeoutsUsed, ')
          ..write('oppTimeoutsUsed: $oppTimeoutsUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RalliesTable extends Rallies with TableInfo<$RalliesTable, RallyEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RalliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rallyIndexMeta = const VerificationMeta(
    'rallyIndex',
  );
  @override
  late final GeneratedColumn<int> rallyIndex = GeneratedColumn<int>(
    'rally_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationAtStartMeta = const VerificationMeta(
    'rotationAtStart',
  );
  @override
  late final GeneratedColumn<int> rotationAtStart = GeneratedColumn<int>(
    'rotation_at_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weWereServingMeta = const VerificationMeta(
    'weWereServing',
  );
  @override
  late final GeneratedColumn<bool> weWereServing = GeneratedColumn<bool>(
    'we_were_serving',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("we_were_serving" IN (0, 1))',
    ),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weWonMeta = const VerificationMeta('weWon');
  @override
  late final GeneratedColumn<bool> weWon = GeneratedColumn<bool>(
    'we_won',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("we_won" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    setId,
    rallyIndex,
    rotationAtStart,
    weWereServing,
    outcome,
    weWon,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rallies';
  @override
  VerificationContext validateIntegrity(
    Insertable<RallyEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('rally_index')) {
      context.handle(
        _rallyIndexMeta,
        rallyIndex.isAcceptableOrUnknown(data['rally_index']!, _rallyIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rallyIndexMeta);
    }
    if (data.containsKey('rotation_at_start')) {
      context.handle(
        _rotationAtStartMeta,
        rotationAtStart.isAcceptableOrUnknown(
          data['rotation_at_start']!,
          _rotationAtStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rotationAtStartMeta);
    }
    if (data.containsKey('we_were_serving')) {
      context.handle(
        _weWereServingMeta,
        weWereServing.isAcceptableOrUnknown(
          data['we_were_serving']!,
          _weWereServingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weWereServingMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('we_won')) {
      context.handle(
        _weWonMeta,
        weWon.isAcceptableOrUnknown(data['we_won']!, _weWonMeta),
      );
    } else if (isInserting) {
      context.missing(_weWonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {setId, rallyIndex},
  ];
  @override
  RallyEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RallyEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      rallyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rally_index'],
      )!,
      rotationAtStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation_at_start'],
      )!,
      weWereServing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}we_were_serving'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      weWon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}we_won'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $RalliesTable createAlias(String alias) {
    return $RalliesTable(attachedDatabase, alias);
  }
}

class RallyEntity extends DataClass implements Insertable<RallyEntity> {
  final String id;
  final String setId;
  final int rallyIndex;
  final int rotationAtStart;
  final bool weWereServing;
  final String outcome;
  final bool weWon;
  final DateTime timestamp;
  const RallyEntity({
    required this.id,
    required this.setId,
    required this.rallyIndex,
    required this.rotationAtStart,
    required this.weWereServing,
    required this.outcome,
    required this.weWon,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['rally_index'] = Variable<int>(rallyIndex);
    map['rotation_at_start'] = Variable<int>(rotationAtStart);
    map['we_were_serving'] = Variable<bool>(weWereServing);
    map['outcome'] = Variable<String>(outcome);
    map['we_won'] = Variable<bool>(weWon);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  RalliesCompanion toCompanion(bool nullToAbsent) {
    return RalliesCompanion(
      id: Value(id),
      setId: Value(setId),
      rallyIndex: Value(rallyIndex),
      rotationAtStart: Value(rotationAtStart),
      weWereServing: Value(weWereServing),
      outcome: Value(outcome),
      weWon: Value(weWon),
      timestamp: Value(timestamp),
    );
  }

  factory RallyEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RallyEntity(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      rallyIndex: serializer.fromJson<int>(json['rallyIndex']),
      rotationAtStart: serializer.fromJson<int>(json['rotationAtStart']),
      weWereServing: serializer.fromJson<bool>(json['weWereServing']),
      outcome: serializer.fromJson<String>(json['outcome']),
      weWon: serializer.fromJson<bool>(json['weWon']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'rallyIndex': serializer.toJson<int>(rallyIndex),
      'rotationAtStart': serializer.toJson<int>(rotationAtStart),
      'weWereServing': serializer.toJson<bool>(weWereServing),
      'outcome': serializer.toJson<String>(outcome),
      'weWon': serializer.toJson<bool>(weWon),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  RallyEntity copyWith({
    String? id,
    String? setId,
    int? rallyIndex,
    int? rotationAtStart,
    bool? weWereServing,
    String? outcome,
    bool? weWon,
    DateTime? timestamp,
  }) => RallyEntity(
    id: id ?? this.id,
    setId: setId ?? this.setId,
    rallyIndex: rallyIndex ?? this.rallyIndex,
    rotationAtStart: rotationAtStart ?? this.rotationAtStart,
    weWereServing: weWereServing ?? this.weWereServing,
    outcome: outcome ?? this.outcome,
    weWon: weWon ?? this.weWon,
    timestamp: timestamp ?? this.timestamp,
  );
  RallyEntity copyWithCompanion(RalliesCompanion data) {
    return RallyEntity(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      rallyIndex: data.rallyIndex.present
          ? data.rallyIndex.value
          : this.rallyIndex,
      rotationAtStart: data.rotationAtStart.present
          ? data.rotationAtStart.value
          : this.rotationAtStart,
      weWereServing: data.weWereServing.present
          ? data.weWereServing.value
          : this.weWereServing,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      weWon: data.weWon.present ? data.weWon.value : this.weWon,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RallyEntity(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('rallyIndex: $rallyIndex, ')
          ..write('rotationAtStart: $rotationAtStart, ')
          ..write('weWereServing: $weWereServing, ')
          ..write('outcome: $outcome, ')
          ..write('weWon: $weWon, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    setId,
    rallyIndex,
    rotationAtStart,
    weWereServing,
    outcome,
    weWon,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RallyEntity &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.rallyIndex == this.rallyIndex &&
          other.rotationAtStart == this.rotationAtStart &&
          other.weWereServing == this.weWereServing &&
          other.outcome == this.outcome &&
          other.weWon == this.weWon &&
          other.timestamp == this.timestamp);
}

class RalliesCompanion extends UpdateCompanion<RallyEntity> {
  final Value<String> id;
  final Value<String> setId;
  final Value<int> rallyIndex;
  final Value<int> rotationAtStart;
  final Value<bool> weWereServing;
  final Value<String> outcome;
  final Value<bool> weWon;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const RalliesCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.rallyIndex = const Value.absent(),
    this.rotationAtStart = const Value.absent(),
    this.weWereServing = const Value.absent(),
    this.outcome = const Value.absent(),
    this.weWon = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RalliesCompanion.insert({
    required String id,
    required String setId,
    required int rallyIndex,
    required int rotationAtStart,
    required bool weWereServing,
    required String outcome,
    required bool weWon,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       setId = Value(setId),
       rallyIndex = Value(rallyIndex),
       rotationAtStart = Value(rotationAtStart),
       weWereServing = Value(weWereServing),
       outcome = Value(outcome),
       weWon = Value(weWon),
       timestamp = Value(timestamp);
  static Insertable<RallyEntity> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<int>? rallyIndex,
    Expression<int>? rotationAtStart,
    Expression<bool>? weWereServing,
    Expression<String>? outcome,
    Expression<bool>? weWon,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (rallyIndex != null) 'rally_index': rallyIndex,
      if (rotationAtStart != null) 'rotation_at_start': rotationAtStart,
      if (weWereServing != null) 'we_were_serving': weWereServing,
      if (outcome != null) 'outcome': outcome,
      if (weWon != null) 'we_won': weWon,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RalliesCompanion copyWith({
    Value<String>? id,
    Value<String>? setId,
    Value<int>? rallyIndex,
    Value<int>? rotationAtStart,
    Value<bool>? weWereServing,
    Value<String>? outcome,
    Value<bool>? weWon,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return RalliesCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      rallyIndex: rallyIndex ?? this.rallyIndex,
      rotationAtStart: rotationAtStart ?? this.rotationAtStart,
      weWereServing: weWereServing ?? this.weWereServing,
      outcome: outcome ?? this.outcome,
      weWon: weWon ?? this.weWon,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (rallyIndex.present) {
      map['rally_index'] = Variable<int>(rallyIndex.value);
    }
    if (rotationAtStart.present) {
      map['rotation_at_start'] = Variable<int>(rotationAtStart.value);
    }
    if (weWereServing.present) {
      map['we_were_serving'] = Variable<bool>(weWereServing.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (weWon.present) {
      map['we_won'] = Variable<bool>(weWon.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RalliesCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('rallyIndex: $rallyIndex, ')
          ..write('rotationAtStart: $rotationAtStart, ')
          ..write('weWereServing: $weWereServing, ')
          ..write('outcome: $outcome, ')
          ..write('weWon: $weWon, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VBStatsDatabase extends GeneratedDatabase {
  _$VBStatsDatabase(QueryExecutor e) : super(e);
  $VBStatsDatabaseManager get managers => $VBStatsDatabaseManager(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $SetsTable sets = $SetsTable(this);
  late final $RalliesTable rallies = $RalliesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [matches, sets, rallies];
}

typedef $$MatchesTableCreateCompanionBuilder =
    MatchesCompanion Function({
      required String id,
      required String opponentName,
      Value<String?> eventName,
      required DateTime date,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MatchesTableUpdateCompanionBuilder =
    MatchesCompanion Function({
      Value<String> id,
      Value<String> opponentName,
      Value<String?> eventName,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MatchesTableFilterComposer
    extends Composer<_$VBStatsDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchesTableOrderingComposer
    extends Composer<_$VBStatsDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$VBStatsDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventName =>
      $composableBuilder(column: $table.eventName, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$VBStatsDatabase,
          $MatchesTable,
          MatchEntity,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (
            MatchEntity,
            BaseReferences<_$VBStatsDatabase, $MatchesTable, MatchEntity>,
          ),
          MatchEntity,
          PrefetchHooks Function()
        > {
  $$MatchesTableTableManager(_$VBStatsDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> opponentName = const Value.absent(),
                Value<String?> eventName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                opponentName: opponentName,
                eventName: eventName,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String opponentName,
                Value<String?> eventName = const Value.absent(),
                required DateTime date,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                opponentName: opponentName,
                eventName: eventName,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$VBStatsDatabase,
      $MatchesTable,
      MatchEntity,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (
        MatchEntity,
        BaseReferences<_$VBStatsDatabase, $MatchesTable, MatchEntity>,
      ),
      MatchEntity,
      PrefetchHooks Function()
    >;
typedef $$SetsTableCreateCompanionBuilder =
    SetsCompanion Function({
      required String id,
      required String matchId,
      required int setIndex,
      required int startRotation,
      required String startServeReceiveState,
      Value<int> ourScore,
      Value<int> oppScore,
      Value<int> ourTimeoutsUsed,
      Value<int> oppTimeoutsUsed,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SetsTableUpdateCompanionBuilder =
    SetsCompanion Function({
      Value<String> id,
      Value<String> matchId,
      Value<int> setIndex,
      Value<int> startRotation,
      Value<String> startServeReceiveState,
      Value<int> ourScore,
      Value<int> oppScore,
      Value<int> ourTimeoutsUsed,
      Value<int> oppTimeoutsUsed,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SetsTableFilterComposer
    extends Composer<_$VBStatsDatabase, $SetsTable> {
  $$SetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startRotation => $composableBuilder(
    column: $table.startRotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startServeReceiveState => $composableBuilder(
    column: $table.startServeReceiveState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ourScore => $composableBuilder(
    column: $table.ourScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oppScore => $composableBuilder(
    column: $table.oppScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ourTimeoutsUsed => $composableBuilder(
    column: $table.ourTimeoutsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oppTimeoutsUsed => $composableBuilder(
    column: $table.oppTimeoutsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SetsTableOrderingComposer
    extends Composer<_$VBStatsDatabase, $SetsTable> {
  $$SetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startRotation => $composableBuilder(
    column: $table.startRotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startServeReceiveState => $composableBuilder(
    column: $table.startServeReceiveState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ourScore => $composableBuilder(
    column: $table.ourScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oppScore => $composableBuilder(
    column: $table.oppScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ourTimeoutsUsed => $composableBuilder(
    column: $table.ourTimeoutsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oppTimeoutsUsed => $composableBuilder(
    column: $table.oppTimeoutsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetsTableAnnotationComposer
    extends Composer<_$VBStatsDatabase, $SetsTable> {
  $$SetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get startRotation => $composableBuilder(
    column: $table.startRotation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startServeReceiveState => $composableBuilder(
    column: $table.startServeReceiveState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ourScore =>
      $composableBuilder(column: $table.ourScore, builder: (column) => column);

  GeneratedColumn<int> get oppScore =>
      $composableBuilder(column: $table.oppScore, builder: (column) => column);

  GeneratedColumn<int> get ourTimeoutsUsed => $composableBuilder(
    column: $table.ourTimeoutsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oppTimeoutsUsed => $composableBuilder(
    column: $table.oppTimeoutsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SetsTableTableManager
    extends
        RootTableManager<
          _$VBStatsDatabase,
          $SetsTable,
          SetEntity,
          $$SetsTableFilterComposer,
          $$SetsTableOrderingComposer,
          $$SetsTableAnnotationComposer,
          $$SetsTableCreateCompanionBuilder,
          $$SetsTableUpdateCompanionBuilder,
          (SetEntity, BaseReferences<_$VBStatsDatabase, $SetsTable, SetEntity>),
          SetEntity,
          PrefetchHooks Function()
        > {
  $$SetsTableTableManager(_$VBStatsDatabase db, $SetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int> startRotation = const Value.absent(),
                Value<String> startServeReceiveState = const Value.absent(),
                Value<int> ourScore = const Value.absent(),
                Value<int> oppScore = const Value.absent(),
                Value<int> ourTimeoutsUsed = const Value.absent(),
                Value<int> oppTimeoutsUsed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion(
                id: id,
                matchId: matchId,
                setIndex: setIndex,
                startRotation: startRotation,
                startServeReceiveState: startServeReceiveState,
                ourScore: ourScore,
                oppScore: oppScore,
                ourTimeoutsUsed: ourTimeoutsUsed,
                oppTimeoutsUsed: oppTimeoutsUsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String matchId,
                required int setIndex,
                required int startRotation,
                required String startServeReceiveState,
                Value<int> ourScore = const Value.absent(),
                Value<int> oppScore = const Value.absent(),
                Value<int> ourTimeoutsUsed = const Value.absent(),
                Value<int> oppTimeoutsUsed = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion.insert(
                id: id,
                matchId: matchId,
                setIndex: setIndex,
                startRotation: startRotation,
                startServeReceiveState: startServeReceiveState,
                ourScore: ourScore,
                oppScore: oppScore,
                ourTimeoutsUsed: ourTimeoutsUsed,
                oppTimeoutsUsed: oppTimeoutsUsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SetsTableProcessedTableManager =
    ProcessedTableManager<
      _$VBStatsDatabase,
      $SetsTable,
      SetEntity,
      $$SetsTableFilterComposer,
      $$SetsTableOrderingComposer,
      $$SetsTableAnnotationComposer,
      $$SetsTableCreateCompanionBuilder,
      $$SetsTableUpdateCompanionBuilder,
      (SetEntity, BaseReferences<_$VBStatsDatabase, $SetsTable, SetEntity>),
      SetEntity,
      PrefetchHooks Function()
    >;
typedef $$RalliesTableCreateCompanionBuilder =
    RalliesCompanion Function({
      required String id,
      required String setId,
      required int rallyIndex,
      required int rotationAtStart,
      required bool weWereServing,
      required String outcome,
      required bool weWon,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$RalliesTableUpdateCompanionBuilder =
    RalliesCompanion Function({
      Value<String> id,
      Value<String> setId,
      Value<int> rallyIndex,
      Value<int> rotationAtStart,
      Value<bool> weWereServing,
      Value<String> outcome,
      Value<bool> weWon,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$RalliesTableFilterComposer
    extends Composer<_$VBStatsDatabase, $RalliesTable> {
  $$RalliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rallyIndex => $composableBuilder(
    column: $table.rallyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotationAtStart => $composableBuilder(
    column: $table.rotationAtStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weWereServing => $composableBuilder(
    column: $table.weWereServing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weWon => $composableBuilder(
    column: $table.weWon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RalliesTableOrderingComposer
    extends Composer<_$VBStatsDatabase, $RalliesTable> {
  $$RalliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rallyIndex => $composableBuilder(
    column: $table.rallyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotationAtStart => $composableBuilder(
    column: $table.rotationAtStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weWereServing => $composableBuilder(
    column: $table.weWereServing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weWon => $composableBuilder(
    column: $table.weWon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RalliesTableAnnotationComposer
    extends Composer<_$VBStatsDatabase, $RalliesTable> {
  $$RalliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<int> get rallyIndex => $composableBuilder(
    column: $table.rallyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rotationAtStart => $composableBuilder(
    column: $table.rotationAtStart,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weWereServing => $composableBuilder(
    column: $table.weWereServing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get weWon =>
      $composableBuilder(column: $table.weWon, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$RalliesTableTableManager
    extends
        RootTableManager<
          _$VBStatsDatabase,
          $RalliesTable,
          RallyEntity,
          $$RalliesTableFilterComposer,
          $$RalliesTableOrderingComposer,
          $$RalliesTableAnnotationComposer,
          $$RalliesTableCreateCompanionBuilder,
          $$RalliesTableUpdateCompanionBuilder,
          (
            RallyEntity,
            BaseReferences<_$VBStatsDatabase, $RalliesTable, RallyEntity>,
          ),
          RallyEntity,
          PrefetchHooks Function()
        > {
  $$RalliesTableTableManager(_$VBStatsDatabase db, $RalliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RalliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RalliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RalliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<int> rallyIndex = const Value.absent(),
                Value<int> rotationAtStart = const Value.absent(),
                Value<bool> weWereServing = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<bool> weWon = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RalliesCompanion(
                id: id,
                setId: setId,
                rallyIndex: rallyIndex,
                rotationAtStart: rotationAtStart,
                weWereServing: weWereServing,
                outcome: outcome,
                weWon: weWon,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String setId,
                required int rallyIndex,
                required int rotationAtStart,
                required bool weWereServing,
                required String outcome,
                required bool weWon,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => RalliesCompanion.insert(
                id: id,
                setId: setId,
                rallyIndex: rallyIndex,
                rotationAtStart: rotationAtStart,
                weWereServing: weWereServing,
                outcome: outcome,
                weWon: weWon,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RalliesTableProcessedTableManager =
    ProcessedTableManager<
      _$VBStatsDatabase,
      $RalliesTable,
      RallyEntity,
      $$RalliesTableFilterComposer,
      $$RalliesTableOrderingComposer,
      $$RalliesTableAnnotationComposer,
      $$RalliesTableCreateCompanionBuilder,
      $$RalliesTableUpdateCompanionBuilder,
      (
        RallyEntity,
        BaseReferences<_$VBStatsDatabase, $RalliesTable, RallyEntity>,
      ),
      RallyEntity,
      PrefetchHooks Function()
    >;

class $VBStatsDatabaseManager {
  final _$VBStatsDatabase _db;
  $VBStatsDatabaseManager(this._db);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$RalliesTableTableManager get rallies =>
      $$RalliesTableTableManager(_db, _db.rallies);
}
