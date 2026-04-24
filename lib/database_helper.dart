import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('polla_mundial.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 4, // ← sube de 3 a 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Participantes
    await db.execute('''
      CREATE TABLE participants (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT    NOT NULL,
        points  INTEGER DEFAULT 0
      )
    ''');

    // Torneos
    await db.execute('''
      CREATE TABLE tournaments (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        created_at TEXT    NOT NULL,
        is_active  INTEGER DEFAULT 1
      )
    ''');

    // Snapshot de puntos por torneo
    await db.execute('''
      CREATE TABLE tournament_snapshots (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id    INTEGER NOT NULL,
        participant_id   INTEGER NOT NULL,
        participant_name TEXT    NOT NULL,
        points           INTEGER DEFAULT 0,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id)
      )
    ''');

    // Rondas eliminatorias
    await db.execute('''
      CREATE TABLE knockout_rounds (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        order_num     INTEGER NOT NULL,
        tournament_id INTEGER DEFAULT 1
      )
    ''');

    // Partidos
    await db.execute('''
      CREATE TABLE matches (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        team_a             TEXT    NOT NULL,
        team_b             TEXT    NOT NULL,
        score_a            INTEGER,
        score_b            INTEGER,
        group_name         TEXT,
        match_date         TEXT,
        tournament_id      INTEGER DEFAULT 1,
        knockout_round_id  INTEGER
      )
    ''');

    // Predicciones
    await db.execute('''
      CREATE TABLE predictions (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        participant_id  INTEGER,
        match_id        INTEGER,
        predict_score_a INTEGER,
        predict_score_b INTEGER,
        FOREIGN KEY (participant_id) REFERENCES participants (id),
        FOREIGN KEY (match_id)       REFERENCES matches (id)
      )
    ''');

    // Apuestas al campeón
    await db.execute('''
      CREATE TABLE champion_bets (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        participant_id INTEGER,
        team           TEXT    NOT NULL,
        tournament_id  INTEGER DEFAULT 1,
        UNIQUE(participant_id, tournament_id),
        FOREIGN KEY (participant_id) REFERENCES participants (id)
      )
    ''');

    // Torneo inicial
    await db.insert('tournaments', {
      'name': 'Mundial 2026',
      'created_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE matches ADD COLUMN match_date TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS champion_bets (
          id             INTEGER PRIMARY KEY AUTOINCREMENT,
          participant_id INTEGER UNIQUE,
          team           TEXT NOT NULL,
          FOREIGN KEY (participant_id) REFERENCES participants (id)
        )
      ''');
    }
    if (oldVersion < 4) {
      // Torneos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tournaments (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          name       TEXT    NOT NULL,
          created_at TEXT    NOT NULL,
          is_active  INTEGER DEFAULT 1
        )
      ''');

      // Snapshots
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tournament_snapshots (
          id               INTEGER PRIMARY KEY AUTOINCREMENT,
          tournament_id    INTEGER NOT NULL,
          participant_id   INTEGER NOT NULL,
          participant_name TEXT    NOT NULL,
          points           INTEGER DEFAULT 0,
          FOREIGN KEY (tournament_id) REFERENCES tournaments (id)
        )
      ''');

      // Rondas eliminatorias
      await db.execute('''
        CREATE TABLE IF NOT EXISTS knockout_rounds (
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          name          TEXT    NOT NULL,
          order_num     INTEGER NOT NULL,
          tournament_id INTEGER DEFAULT 1
        )
      ''');

      // Nuevas columnas en matches
      try {
        await db.execute(
          'ALTER TABLE matches ADD COLUMN tournament_id INTEGER DEFAULT 1',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE matches ADD COLUMN knockout_round_id INTEGER',
        );
      } catch (_) {}

      // Nueva columna en champion_bets
      try {
        await db.execute(
          'ALTER TABLE champion_bets ADD COLUMN tournament_id INTEGER DEFAULT 1',
        );
      } catch (_) {}

      // Torneo inicial para datos existentes
      final torneos = await db.query('tournaments', limit: 1);
      if (torneos.isEmpty) {
        await db.insert('tournaments', {
          'name': 'Mundial 2026',
          'created_at': DateTime.now().toIso8601String(),
          'is_active': 1,
        });
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ── PARTICIPANTES ─────────────────────────────────────────────────────────
  Future<int> insertParticipant(String name) async {
    final db = await database;
    return await db.insert('participants', {'name': name, 'points': 0});
  }

  Future<List<Map<String, dynamic>>> getParticipants() async {
    final db = await database;
    return await db.query('participants', orderBy: 'points DESC');
  }

  // ── PARTIDOS ──────────────────────────────────────────────────────────────
  Future<int> insertMatch(String teamA, String teamB) async {
    final db = await database;
    return await db.insert('matches', {'team_a': teamA, 'team_b': teamB});
  }

  Future<List<Map<String, dynamic>>> getMatches() async {
    final db = await database;
    return await db.query('matches');
  }

  Future<void> deleteMatchAndRevertPoints(int matchId) async {
    final db = await database;
    final predictions = await db.query(
      'predictions',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
    for (var pred in predictions) {
      await db.execute(
        'UPDATE participants SET points = MAX(0, points - 3) WHERE id = ?',
        [pred['participant_id']],
      );
    }
    await db.delete('predictions', where: 'match_id = ?', whereArgs: [matchId]);
    await db.delete('matches', where: 'id = ?', whereArgs: [matchId]);
  }

  // ── PREDICCIONES ──────────────────────────────────────────────────────────
  Future<void> savePrediction(int pId, int mId, int sA, int sB) async {
    final db = await database;
    final existente = await db.query(
      'predictions',
      where: 'participant_id = ? AND match_id = ?',
      whereArgs: [pId, mId],
    );
    if (existente.isNotEmpty) {
      await db.update(
        'predictions',
        {'predict_score_a': sA, 'predict_score_b': sB},
        where: 'id = ?',
        whereArgs: [existente.first['id']],
      );
    } else {
      await db.insert('predictions', {
        'participant_id': pId,
        'match_id': mId,
        'predict_score_a': sA,
        'predict_score_b': sB,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getMatchPredictions(int matchId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.name, pr.predict_score_a, pr.predict_score_b
      FROM predictions pr
      JOIN participants p ON pr.participant_id = p.id
      WHERE pr.match_id = ?
    ''',
      [matchId],
    );
  }

  Future<Map<String, int>> getMatchStats() async {
    final db = await database;
    final torneoId = await getTournamentActivoId();
    final allMatches = await db.query(
      'matches',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
    );
    final total = allMatches.length;
    final jugados = allMatches.where((m) => m['score_a'] != null).length;
    final pendientes = total - jugados;
    return {'total': total, 'jugados': jugados, 'pendientes': pendientes};
  }

  Future<List<Map<String, dynamic>>> getPlayerHistory(int participantId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT
        matches.team_a,
        matches.team_b,
        matches.score_a,
        matches.score_b,
        predictions.predict_score_a,
        predictions.predict_score_b
      FROM predictions
      JOIN matches ON predictions.match_id = matches.id
      WHERE predictions.participant_id = ?
      ORDER BY matches.id ASC
    ''',
      [participantId],
    );
  }

  Future<bool> fixtureYaCargado() async {
    final db = await database;
    final torneoId = await getTournamentActivoId();
    final result = await db.query(
      'matches',
      where: 'tournament_id = ? AND group_name IS NOT NULL',
      whereArgs: [torneoId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> cargarFixtureMundial(List<Map<String, String>> partidos) async {
    final db = await database;
    final torneoId = await getTournamentActivoId();
    final batch = db.batch();
    for (final p in partidos) {
      batch.insert('matches', {
        'team_a': p['team_a'],
        'team_b': p['team_b'],
        'group_name': p['group'],
        'match_date': p['date'],
        'score_a': null,
        'score_b': null,
        'tournament_id': torneoId,
      });
    }
    await batch.commit(noResult: true);
  }

  // ── TORNEOS ───────────────────────────────────────────────────────────────
  Future<int> getTournamentActivoId() async {
    final db = await database;
    final result = await db.query(
      'tournaments',
      where: 'is_active = 1',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (result.isEmpty) return 1;
    return result.first['id'] as int;
  }

  Future<Map<String, dynamic>?> getTournamentActivo() async {
    final db = await database;
    final result = await db.query(
      'tournaments',
      where: 'is_active = 1',
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>> getTournamentsArchivados() async {
    final db = await database;
    return await db.query(
      'tournaments',
      where: 'is_active = 0',
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSnapshotTorneo(int tournamentId) async {
    final db = await database;
    return await db.query(
      'tournament_snapshots',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'points DESC',
    );
  }

  Future<void> crearNuevoTorneo(String nombre) async {
    final db = await database;
    final torneoId = await getTournamentActivoId();

    // 1. Snapshot de puntos actuales
    final jugadores = await db.query('participants');
    for (final j in jugadores) {
      await db.insert('tournament_snapshots', {
        'tournament_id': torneoId,
        'participant_id': j['id'],
        'participant_name': j['name'],
        'points': j['points'],
      });
    }

    // 2. Archivar torneo actual
    await db.update(
      'tournaments',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [torneoId],
    );

    // 3. Resetear puntos
    await db.execute('UPDATE participants SET points = 0');

    // 4. Borrar partidos y apuestas del torneo
    final matchIds = await db.query(
      'matches',
      columns: ['id'],
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
    );
    for (final m in matchIds) {
      await db.delete(
        'predictions',
        where: 'match_id = ?',
        whereArgs: [m['id']],
      );
    }
    await db.delete(
      'matches',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
    );
    await db.delete(
      'champion_bets',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
    );
    await db.delete(
      'knockout_rounds',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
    );

    // 5. Crear nuevo torneo
    await db.insert('tournaments', {
      'name': nombre,
      'created_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    });
  }

  // ── RONDAS ELIMINATORIAS ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getKnockoutRounds() async {
    final db = await database;
    final torneoId = await getTournamentActivoId();
    return await db.query(
      'knockout_rounds',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
      orderBy: 'order_num ASC',
    );
  }

  Future<int> crearKnockoutRound(String nombre) async {
    final db = await database;
    final torneoId = await getTournamentActivoId();

    // Calcular el siguiente order_num
    final existing = await db.query(
      'knockout_rounds',
      where: 'tournament_id = ?',
      whereArgs: [torneoId],
      orderBy: 'order_num DESC',
      limit: 1,
    );
    final nextOrder = existing.isEmpty
        ? 1
        : (existing.first['order_num'] as int) + 1;

    return await db.insert('knockout_rounds', {
      'name': nombre,
      'order_num': nextOrder,
      'tournament_id': torneoId,
    });
  }

  Future<void> eliminarKnockoutRound(int roundId) async {
    final db = await database;

    // Borrar partidos y predicciones de la ronda
    final partidos = await db.query(
      'matches',
      columns: ['id'],
      where: 'knockout_round_id = ?',
      whereArgs: [roundId],
    );
    for (final p in partidos) {
      await db.delete(
        'predictions',
        where: 'match_id = ?',
        whereArgs: [p['id']],
      );
    }
    await db.delete(
      'matches',
      where: 'knockout_round_id = ?',
      whereArgs: [roundId],
    );
    await db.delete('knockout_rounds', where: 'id = ?', whereArgs: [roundId]);
  }

  Future<List<Map<String, dynamic>>> getMatchesByRound(int roundId) async {
    final db = await database;
    return await db.query(
      'matches',
      where: 'knockout_round_id = ?',
      whereArgs: [roundId],
    );
  }

  Future<int> insertKnockoutMatch(
    String teamA,
    String teamB,
    int roundId,
  ) async {
    final db = await database;
    final torneoId = await getTournamentActivoId();
    return await db.insert('matches', {
      'team_a': teamA,
      'team_b': teamB,
      'score_a': null,
      'score_b': null,
      'tournament_id': torneoId,
      'knockout_round_id': roundId,
    });
  }
}
