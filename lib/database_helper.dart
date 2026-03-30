import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton: Solo existe una instancia de la base de datos
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('polla_mundial.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Busca la ruta donde el celular guarda las bases de datos
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Aquí definimos la estructura de nuestra Polla
  Future _createDB(Database db, int version) async {
    // Tabla de Participantes
    await db.execute('''
      CREATE TABLE participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        points INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Partidos
    await db.execute('''
  CREATE TABLE matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_a TEXT NOT NULL,
    team_b TEXT NOT NULL,
    score_a INTEGER,
    score_b INTEGER,
    group_name TEXT
  )
''');

    // NUEVA: Tabla de Pronósticos (Une al jugador con el partido)
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        participant_id INTEGER,
        match_id INTEGER,
        predict_score_a INTEGER,
        predict_score_b INTEGER,
        FOREIGN KEY (participant_id) REFERENCES participants (id),
        FOREIGN KEY (match_id) REFERENCES matches (id)
      )
    ''');
  }

  // Función para cerrar la base de datos si es necesario
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // --- MÉTODOS PARA PARTICIPANTES ---
  Future<int> insertParticipant(String name) async {
    final db = await database;
    // Usamos INSERT OR IGNORE o validamos para evitar duplicados
    return await db.insert('participants', {'name': name, 'points': 0});
  }

  Future<List<Map<String, dynamic>>> getParticipants() async {
    final db = await database;
    return await db.query('participants', orderBy: 'points DESC');
  }

  // --- MÉTODOS PARA PARTIDOS ---
  Future<int> insertMatch(String teamA, String teamB) async {
    final db = await database;
    return await db.insert('matches', {'team_a': teamA, 'team_b': teamB});
  }

  Future<List<Map<String, dynamic>>> getMatches() async {
    final db = await database;
    return await db.query('matches');
  }

  // PUNTO 3: Eliminar partido y revertir puntos (Protección de negativos)
  Future<void> deleteMatchAndRevertPoints(int matchId) async {
    final db = await database;

    // 1. Buscamos quiénes acertaron en este partido para saber a quién restarle
    // (Esta es una lógica avanzada: si borras un partido, hay que quitar los puntos que dio)
    final predictions = await db.query(
      'predictions',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );

    for (var pred in predictions) {
      // Restamos 3 puntos (o los que asignes) pero usamos MAX(0, ...)
      await db.execute(
        'UPDATE participants SET points = MAX(0, points - 3) WHERE id = ?',
        [pred['participant_id']],
      );
    }

    // 2. Borramos el partido y sus predicciones
    await db.delete('predictions', where: 'match_id = ?', whereArgs: [matchId]);
    await db.delete('matches', where: 'id = ?', whereArgs: [matchId]);
  }

  // --- MÉTODOS PARA PREDICCIONES (APUESTAS) ---
  Future<void> savePrediction(int pId, int mId, int sA, int sB) async {
    final db = await database;
    // Usamos conflictAlgorithm para que si ya existe la apuesta, la reemplace
    await db.insert('predictions', {
      'participant_id': pId,
      'match_id': mId,
      'predict_score_a': sA,
      'predict_score_b': sB,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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

    // Contamos todos los partidos
    final List<Map<String, dynamic>> allMatches = await db.query('matches');
    int total = allMatches.length;

    // Contamos los que tienen score_a diferente de null (ya jugados)
    int jugados = allMatches.where((m) => m['score_a'] != null).length;
    int pendientes = total - jugados;

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
    final result = await db.query('matches', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> cargarFixtureMundial(List<Map<String, String>> partidos) async {
  final db = await database;
  final batch = db.batch();
  for (final p in partidos) {
    batch.insert('matches', {
      'team_a': p['team_a'],
      'team_b': p['team_b'],
      'group_name': p['group'], // ✅ Ahora guarda el grupo
      'score_a': null,
      'score_b': null,
    });
  }
  await batch.commit(noResult: true);
}
}
