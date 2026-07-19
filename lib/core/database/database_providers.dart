import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/database/app_database.dart';

part 'database_providers.g.dart';

/// Application-lifetime [AppDatabase].
///
/// Purpose: One keepAlive DB for catalog/queue; tests override with
/// [AppDatabase.memory].
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
}
