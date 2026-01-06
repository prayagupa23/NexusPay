import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import '../models/recipient_honor_score_model.dart';

class RecipientHonorScoreDB {
  static final RecipientHonorScoreDB _instance = RecipientHonorScoreDB._internal();
  factory RecipientHonorScoreDB() => _instance;
  RecipientHonorScoreDB._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recipient_honor_scores.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipient_honor_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            number_id TEXT NOT NULL,
            honor_score INTEGER NOT NULL DEFAULT 50,
            UNIQUE(user_id, number_id)
          )
        ''');
      },
    );
  }

  Future<void> insertOrUpdateHonorScore(RecipientHonorScore score) async {
    final db = await database;
    await db.insert(
      'recipient_honor_scores',
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<RecipientHonorScore?> getHonorScore(String userId, String numberId) async {
    final db = await database;
    final maps = await db.query(
      'recipient_honor_scores',
      where: 'user_id = ? AND number_id = ?',
      whereArgs: [userId, numberId],
    );
    if (maps.isNotEmpty) {
      return RecipientHonorScore.fromMap(maps.first);
    }
    return null;
  }

  Future<List<RecipientHonorScore>> getAllScoresForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'recipient_honor_scores',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((e) => RecipientHonorScore.fromMap(e)).toList();
  }

  Future<void> updateHonorScore(String userId, String numberId, int newScore) async {
    final db = await database;
    await db.update(
      'recipient_honor_scores',
      {'honor_score': newScore},
      where: 'user_id = ? AND number_id = ?',
      whereArgs: [userId, numberId],
    );
  }

  Future<void> deleteHonorScore(String userId, String numberId) async {
    final db = await database;
    await db.delete(
      'recipient_honor_scores',
      where: 'user_id = ? AND number_id = ?',
      whereArgs: [userId, numberId],
    );
  }

  /// Returns restriction level and message based on honor score.
  /// Levels: none, warn, restrict, severe, block
  Map<String, String> getRestrictionForScore(int honorScore) {
    if (honorScore >= 70) {
      return {'level': 'none', 'message': 'Trusted contact. No restrictions.'};
    } else if (honorScore >= 50) {
      return {'level': 'warn', 'message': 'Caution: This contact has a reduced honor score. Proceed carefully.'};
    } else if (honorScore >= 40) {
      return {'level': 'restrict', 'message': 'Warning: This contact is risky. Payment limits may apply.'};
    } else if (honorScore >= 30) {
      return {'level': 'severe', 'message': 'Severe warning: This contact is highly risky. Most actions are restricted.'};
    } else {
      return {'level': 'block', 'message': 'Blocked: This contact is not trusted. Payments are blocked.'};
    }
  }
}
