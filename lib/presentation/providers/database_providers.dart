import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/data/datasources/database/vbstats_database.dart';
import 'package:vbstats/data/repositories/match_repository_impl.dart';
import 'package:vbstats/domain/repositories/match_repository.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Database provider
final databaseProvider = FutureProvider<VBStatsDatabase>((ref) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'vbstats.db'));
  return VBStatsDatabase(NativeDatabase(file));
});

// Match repository provider
final matchRepositoryProvider = FutureProvider<MatchRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return MatchRepositoryImpl(db);
});
