import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'player_detail_page.dart';
import 'world_cup_data.dart';
import 'app_colors.dart';
import 'podium_widget.dart';
import 'soccer_ball_widget.dart';
import 'flip_match_card.dart';
import 'trophy_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_banner_widget.dart';
import 'ad_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // ← inicializa AdMob
  runApp(const PollaMundialApp());
}

class PollaMundialApp extends StatelessWidget {
  const PollaMundialApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reemplaza el MaterialApp completo:
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polla Mundial 2026',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.fondoPrincipal,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.dorado,
          secondary: AppColors.acento,
          surface: AppColors.fondoTarjeta,
          error: AppColors.rojo,
        ),
        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.fondoPrincipal,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.dorado,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: AppColors.dorado),
        ),
        // Cards
        cardTheme: CardThemeData(
          color: AppColors.fondoTarjeta,
          elevation: 4,
          shadowColor: AppColors.dorado.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.dorado.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.fondoSecundario,
          selectedItemColor: AppColors.dorado,
          unselectedItemColor: AppColors.textoGris,
          elevation: 8,
        ),
        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dorado,
            foregroundColor: AppColors.fondoPrincipal,
            elevation: 4,
            shadowColor: AppColors.dorado.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.acento),
        ),
        // TextField
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fondoSecundario,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dorado.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dorado.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.dorado, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.textoGris),
          hintStyle: const TextStyle(color: AppColors.textoGris),
          prefixIconColor: AppColors.textoGris,
        ),
        // Divider
        dividerTheme: DividerThemeData(
          color: AppColors.dorado.withOpacity(0.2),
          thickness: 1,
        ),
        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.fondoTarjeta,
          contentTextStyle: const TextStyle(color: AppColors.textoBlanco),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        // Dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.fondoSecundario,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.dorado.withOpacity(0.3)),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.dorado,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        // Texto general
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textoBlanco),
          bodyMedium: TextStyle(color: AppColors.textoBlanco),
          bodySmall: TextStyle(color: AppColors.textoGris),
          titleLarge: TextStyle(
            color: AppColors.textoBlanco,
            fontWeight: FontWeight.bold,
          ),
        ),
        // CircleAvatar
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.fondoTarjeta,
          selectedColor: AppColors.dorado.withOpacity(0.3),
          labelStyle: const TextStyle(
            color: AppColors.textoBlanco,
            fontSize: 12,
          ),
          side: BorderSide(color: AppColors.dorado.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceActual = 0; // 0 para Ranking, 1 para Partidos
  String _filtroBusqueda = '';
  String _filtroGrupo = 'Todos';

  // --- FUNCIONES DE BASE DE DATOS PARA PARTICIPANTES ---
  Future<List<Map<String, dynamic>>> _obtenerParticipantes() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('participants', orderBy: 'points DESC');
  }

  Future<List<Map<String, dynamic>>> _obtenerApuestasDelPartido(
    int matchId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    // Usamos un RAW Query para traer el nombre del jugador desde la otra tabla
    return await db.rawQuery(
      '''
    SELECT participants.name, predictions.predict_score_a, predictions.predict_score_b 
    FROM predictions 
    JOIN participants ON predictions.participant_id = participants.id
    WHERE predictions.match_id = ?
  ''',
      [matchId],
    );
  }

  // 1. La lógica para borrar de la base de datos
  void _eliminarJugador(int id) async {
    final db = await DatabaseHelper.instance.database;
    // Borramos sus apuestas primero para no dejar basura en la DB
    await db.delete(
      'predictions',
      where: 'participant_id = ?',
      whereArgs: [id],
    );
    // Borramos al jugador
    await db.delete('participants', where: 'id = ?', whereArgs: [id]);
    setState(() {});
  }

  // 2. El diálogo de confirmación para no borrar por error
  void _confirmarEliminacionJugador(
    BuildContext context,
    int id,
    String nombre,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Eliminar a $nombre?"),
        content: const Text("Se borrarán sus puntos y todas sus apuestas."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _eliminarJugador(id);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacionPartido(
    BuildContext context,
    int id,
    String equipos,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar partido?"),
        content: Text(
          "Se borrará el encuentro: $equipos y todas sus apuestas.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _eliminarPartido(id);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅
  Future<void> _guardarApuesta(
    int participantId,
    int matchId,
    int golesA,
    int golesB,
  ) async {
    final db = await DatabaseHelper.instance.database;

    // Verificamos si ya existe una apuesta
    final existentes = await db.query(
      'predictions',
      where: 'participant_id = ? AND match_id = ?',
      whereArgs: [participantId, matchId],
    );

    if (existentes.isNotEmpty) {
      // Si existe, actualizamos
      await db.update(
        'predictions',
        {'predict_score_a': golesA, 'predict_score_b': golesB},
        where: 'id = ?',
        whereArgs: [existentes.first['id']],
      );
      print("🔄 Apuesta actualizada");
    } else {
      // Si no existe, insertamos
      await db.insert('predictions', {
        'participant_id': participantId,
        'match_id': matchId,
        'predict_score_a': golesA,
        'predict_score_b': golesB,
      });
      print("✅ Apuesta nueva registrada");
    }
    setState(() {}); // Para refrescar si mostramos la lista de apuestas
  }

  // --- LÓGICA DE PUNTOS ---
  void _finalizarPartido(
    int matchId,
    int resultadoRealA,
    int resultadoRealB,
  ) async {
    final db = await DatabaseHelper.instance.database;

    // IMPORTANTE: Verificamos si el partido ya estaba finalizado
    final partido = await db.query(
      'matches',
      where: 'id = ?',
      whereArgs: [matchId],
    );
    if (partido.isNotEmpty && partido.first['score_a'] != null) {
      print("⚠️ Este partido ya fue finalizado previamente.");
      return;
    }

    // 1. Guardamos el resultado oficial en la tabla del partido
    await db.update(
      'matches',
      {'score_a': resultadoRealA, 'score_b': resultadoRealB},
      where: 'id = ?',
      whereArgs: [matchId],
    );

    // 2. Buscamos todas las apuestas que se hicieron para ESTE partido
    final apuestas = await db.query(
      'predictions',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );

    // 3. Revisamos apuesta por apuesta
    for (var apuesta in apuestas) {
      int puntosGanados = 0;
      int prediccionA = apuesta['predict_score_a'] as int;
      int prediccionB = apuesta['predict_score_b'] as int;
      int idJugador = apuesta['participant_id'] as int;

      // Condición A: Acertó el marcador EXACTO (3 puntos)
      if (prediccionA == resultadoRealA && prediccionB == resultadoRealB) {
        puntosGanados = 3;
      }
      // Condición B: No acertó exacto, pero acertó al GANADOR o al EMPATE (1 punto)
      else {
        // ¿Quién ganó en la realidad? (1 = Equipo A, -1 = Equipo B, 0 = Empate)
        int ganadorReal = (resultadoRealA > resultadoRealB)
            ? 1
            : (resultadoRealA < resultadoRealB)
            ? -1
            : 0;
        // ¿Quién predijo que ganaría?
        int ganadorPredicho = (prediccionA > prediccionB)
            ? 1
            : (prediccionA < prediccionB)
            ? -1
            : 0;

        if (ganadorReal == ganadorPredicho) {
          puntosGanados = 1;
        }
      }

      // 4. Si ganó puntos, se los sumamos a su perfil en la base de datos
      if (puntosGanados > 0) {
        // Obtenemos los puntos actuales del jugador
        final jugadorData = await db.query(
          'participants',
          where: 'id = ?',
          whereArgs: [idJugador],
        );
        if (jugadorData.isNotEmpty) {
          int puntosActuales = jugadorData.first['points'] as int;

          // Actualizamos sumando los nuevos puntos
          await db.update(
            'participants',
            {'points': puntosActuales + puntosGanados},
            where: 'id = ?',
            whereArgs: [idJugador],
          );
        }
      }
    }

    // Refrescamos la pantalla para ver el nuevo Ranking
    setState(() {});
    print("🏁 Partido finalizado y puntos repartidos");

    _mostrarIntersticial();
  }

  void _mostrarIntersticial() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Intersticial falló: $error');
        },
      ),
    );
  }

  void _agregarJugador(String nombre) async {
    if (nombre.trim().isEmpty) return;
    final db = await DatabaseHelper.instance.database;

    // VALIDACIÓN: ¿Ya existe este nombre?
    final existente = await db.query(
      'participants',
      where: 'LOWER(name) = ?',
      whereArgs: [nombre.trim().toLowerCase()],
    );

    if (existente.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Este jugador ya está registrado.")),
        );
      }
      return;
    }

    await db.insert('participants', {'name': nombre.trim(), 'points': 0});
    if (mounted) setState(() {});
  }

  // --- FUNCIONES DE BASE DE DATOS PARA PARTIDOS ---
  Future<List<Map<String, dynamic>>> _obtenerPartidos() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('matches');
  }

  void _agregarPartido(String local, String visitante) async {
    if (local.isEmpty || visitante.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('matches', {
      'team_a': local,
      'team_b': visitante,
      'score_a': null,
      'score_b': null,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Definimos qué cuerpo mostrar según la pestaña seleccionada
    final List<Widget> _paginas = [_seccionRanking(), _seccionPartidos()];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Balón girando
            const SoccerBallWidget(size: 28),
            const SizedBox(width: 10),
            const Text(
              "POLLA MUNDIAL",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dorado,
                letterSpacing: 2,
              ),
            ),
            const Text(
              " 2026",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.doradoClaro,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.fondoPrincipal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.dorado.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F2E), Color(0xFF0D1333), Color(0xFF0A0F2E)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: _paginas[_indiceActual],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.fondoSecundario,
          border: Border(
            top: BorderSide(color: AppColors.dorado.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) => setState(() => _indiceActual = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_outlined),
              activeIcon: Icon(Icons.sports_soccer),
              label: 'Partidos',
            ),
          ],
        ),
      ),
    );
  }

  // --- VISTA 1: RANKING ---
  Widget _seccionRanking() {
    return Column(
      children: [
        // Botón reiniciar
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.rojo),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("⚠️ ¡CUIDADO!"),
                  content: const Text(
                    "¿Estás seguro de borrar TODO el torneo? Se eliminarán jugadores, partidos y puntos. Esta acción no se puede deshacer.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCELAR"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _reiniciarTodo();
                        Navigator.pop(context);
                      },
                      child: const Text("SÍ, REINICIAR TODO"),
                    ),
                  ],
                ),
              );
            },
            tooltip: "Borrar todo el torneo",
          ),
        ),

        const TrophyWidget(size: 88),
        const SizedBox(height: 6),
        const Text(
          "TABLA DE POSICIONES",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.dorado,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),

        // ✅ PODIO 3D
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _obtenerParticipantes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            final j = snapshot.data!;
            return PodiumWidget(
              primerNombre: j.length > 0 ? j[0]['name'] : null,
              primerPuntos: j.length > 0 ? j[0]['points'] : 0,
              segundoNombre: j.length > 1 ? j[1]['name'] : null,
              segundoPuntos: j.length > 1 ? j[1]['points'] : 0,
              tercerNombre: j.length > 2 ? j[2]['name'] : null,
              tercerPuntos: j.length > 2 ? j[2]['points'] : 0,
            );
          },
        ),

        const SizedBox(height: 10),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _obtenerParticipantes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.dorado),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 60,
                        color: AppColors.textoGris.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Aún no hay jugadores\n¡Regístralos para comenzar!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textoGris),
                      ),
                    ],
                  ),
                );
              }

              final jugadores = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: jugadores.length,
                itemBuilder: (context, index) {
                  final j = jugadores[index];
                  final puesto = index + 1;

                  // Configuración visual por puesto
                  Color colorMedalla;
                  IconData iconoMedalla;
                  Color colorBorde;
                  double tamanoLetra;

                  if (puesto == 1) {
                    colorMedalla = const Color(0xFFFFD700); // Oro
                    iconoMedalla = Icons.emoji_events;
                    colorBorde = const Color(0xFFFFD700);
                    tamanoLetra = 17;
                  } else if (puesto == 2) {
                    colorMedalla = const Color(0xFFC0C0C0); // Plata
                    iconoMedalla = Icons.emoji_events;
                    colorBorde = const Color(0xFFC0C0C0);
                    tamanoLetra = 16;
                  } else if (puesto == 3) {
                    colorMedalla = const Color(0xFFCD7F32); // Bronce
                    iconoMedalla = Icons.emoji_events;
                    colorBorde = const Color(0xFFCD7F32);
                    tamanoLetra = 15;
                  } else {
                    colorMedalla = AppColors.textoGris;
                    iconoMedalla = Icons.person;
                    colorBorde = AppColors.dorado.withOpacity(0.15);
                    tamanoLetra = 14;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerDetailPage(
                            participantId: j['id'],
                            nombre: j['name'],
                            puntos: j['points'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.fondoTarjeta,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorBorde,
                          width: puesto <= 3 ? 1.5 : 1,
                        ),
                        boxShadow: puesto <= 3
                            ? [
                                BoxShadow(
                                  color: colorMedalla.withOpacity(0.15),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Número de puesto
                            SizedBox(
                              width: 30,
                              child: Text(
                                "$puesto",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorMedalla,
                                ),
                              ),
                            ),

                            // Icono medalla (solo top 3)
                            if (puesto <= 3)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  iconoMedalla,
                                  color: colorMedalla,
                                  size: 22,
                                ),
                              )
                            else
                              const SizedBox(width: 32),

                            // Nombre del jugador
                            Expanded(
                              child: Text(
                                j['name'],
                                style: TextStyle(
                                  fontSize: tamanoLetra,
                                  fontWeight: puesto <= 3
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: AppColors.textoBlanco,
                                ),
                              ),
                            ),

                            // Puntos
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorMedalla.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorMedalla.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                "${j['points']} pts",
                                style: TextStyle(
                                  color: colorMedalla,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            // Botón eliminar
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.rojo.withOpacity(0.6),
                                size: 18,
                              ),
                              onPressed: () {
                                _confirmarEliminacionJugador(
                                  context,
                                  j['id'],
                                  j['name'],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Botón registrar jugador
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("REGISTRAR JUGADOR"),
              onPressed: () => _mostrarDialogoJugador(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccionPartidos() {
    final grupos = [
      'Todos',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
    ];

    return Column(
      children: [
        // --- BLOQUE DE ESTADÍSTICAS ---
        FutureBuilder<Map<String, int>>(
          future: DatabaseHelper.instance.getMatchStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final stats = snapshot.data!;
            return Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green[900]!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green[900]!, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _itemEstadistica("Total", stats['total']!, Colors.white),
                  _itemEstadistica(
                    "Jugados",
                    stats['jugados']!,
                    Colors.greenAccent,
                  ),
                  _itemEstadistica(
                    "Pendientes",
                    stats['pendientes']!,
                    Colors.amberAccent,
                  ),
                ],
              ),
            );
          },
        ),

        // --- BOTONES ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final yaCargado = await DatabaseHelper.instance
                    .fixtureYaCargado();
                if (yaCargado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ Ya hay partidos cargados."),
                    ),
                  );
                  return;
                }
                await DatabaseHelper.instance.cargarFixtureMundial(
                  WorldCupData.getFixture(),
                );
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Fixture del Mundial 2026 cargado!"),
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text("Cargar Mundial"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoPartido(context),
              icon: const Icon(Icons.add),
              label: const Text("Partido Manual"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // --- BARRA DE BÚSQUEDA ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Buscar equipo...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _filtroBusqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _filtroBusqueda = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) => setState(() => _filtroBusqueda = value),
          ),
        ),

        const SizedBox(height: 8),

        // --- FILTRO POR GRUPO ---
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final grupo = grupos[index];
              final seleccionado = _filtroGrupo == grupo;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(grupo),
                  selected: seleccionado,
                  selectedColor: Colors.green[700],
                  onSelected: (_) => setState(() => _filtroGrupo = grupo),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),
        const Center(child: AdBannerWidget()),
        const SizedBox(height: 6),

        // --- LISTA DE PARTIDOS ---
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _obtenerPartidos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No has creado partidos todavía"),
                );
              }

              // Aplicar filtros
              final partidos = snapshot.data!.where((p) {
                final teamA = (p['team_a'] as String).toLowerCase();
                final teamB = (p['team_b'] as String).toLowerCase();
                final busqueda = _filtroBusqueda.toLowerCase();

                final coincideBusqueda =
                    busqueda.isEmpty ||
                    teamA.contains(busqueda) ||
                    teamB.contains(busqueda);

                final coincideGrupo =
                    _filtroGrupo == 'Todos' ||
                    (p['group_name'] != null &&
                        p['group_name'] == _filtroGrupo);

                return coincideBusqueda && coincideGrupo;
              }).toList();

              if (partidos.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay partidos que coincidan con la búsqueda",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: partidos.length,
                itemBuilder: (context, index) {
                  final p = partidos[index];
                  return FlipMatchCard(
                    partido: p,
                    onApostar: p['score_a'] == null
                        ? () => _mostrarDialogoApuesta(
                            context,
                            p['id'],
                            p['team_a'],
                            p['team_b'],
                          )
                        : null,
                    onIngresarResultado: p['score_a'] == null
                        ? () => _mostrarDialogoResultadoReal(
                            context,
                            p['id'],
                            p['team_a'],
                            p['team_b'],
                          )
                        : null,
                    onEliminar: () => _confirmarEliminacionPartido(
                      context,
                      p['id'],
                      "${p['team_a']} vs ${p['team_b']}",
                    ),
                    onVerApuestas: p['score_a'] != null
                        ? () => _mostrarApuestasFinalizadas(
                            context,
                            p['id'],
                            p['team_a'],
                            p['team_b'],
                            p['score_a'] as int,
                            p['score_b'] as int,
                          )
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- DIÁLOGOS ---
  void _mostrarDialogoJugador(BuildContext context) {
    String nombre = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚽ Nuevo Participante'),
        content: TextField(
          decoration: const InputDecoration(hintText: "Nombre del amigo"),
          onChanged: (v) => nombre = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _agregarJugador(nombre);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoPartido(BuildContext context) {
    String local = "";
    String visitante = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏟️ Programar Partido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Equipo A'),
              onChanged: (v) => local = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Equipo B'),
              onChanged: (v) => visitante = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _agregarPartido(local, visitante);
              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoApuesta(
    BuildContext context,
    int matchId,
    String equipoA,
    String equipoB,
  ) async {
    // 1. Obtenemos la lista de jugadores para el Dropdown
    List<Map<String, dynamic>> jugadores = await _obtenerParticipantes();

    if (jugadores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Primero debes registrar al menos un jugador"),
        ),
      );
      return;
    }

    int? jugadorSeleccionadoId;
    int golesA = 0;
    int golesB = 0;

    showDialog(
      context: context,
      builder: (context) {
        // PUNTO 1: La llave se define fuera del StatefulBuilder para que persista
        Key futureKey = UniqueKey();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // PUNTO 2: Controladores para poder limpiar los cuadros de texto
            // Los inicializamos con el valor actual de golesA y golesB
            final TextEditingController ctrlA = TextEditingController(
              text: golesA.toString(),
            );
            final TextEditingController ctrlB = TextEditingController(
              text: golesB.toString(),
            );

            return AlertDialog(
              title: Text('Apuesta: $equipoA vs $equipoB'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("¿Quién apuesta?"),
                    DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text("Selecciona jugador"),
                      value: jugadorSeleccionadoId,
                      items: jugadores.map((j) {
                        return DropdownMenuItem<int>(
                          value: j['id'],
                          child: Text(j['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          jugadorSeleccionadoId = value;
                          // PUNTO 2: Al cambiar de jugador, limpiamos los campos
                          golesA = 0;
                          golesB = 0;
                          ctrlA.clear();
                          ctrlB.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(equipoA, style: const TextStyle(fontSize: 12)),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: ctrlA, // ASIGNAMOS CONTROLADOR
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (v) => golesA = int.tryParse(v) ?? 0,
                              ),
                            ),
                          ],
                        ),
                        const Text("VS"),
                        Column(
                          children: [
                            Text(equipoB, style: const TextStyle(fontSize: 12)),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: ctrlB, // ASIGNAMOS CONTROLADOR
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (v) => golesB = int.tryParse(v) ?? 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text(
                      "Apuestas registradas:",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      key: futureKey, // PUNTO 1: Aplicamos la llave aquí
                      future: _obtenerApuestasDelPartido(matchId),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data!.isEmpty) {
                          return const Text(
                            "Nadie ha apostado aún",
                            style: TextStyle(fontSize: 11),
                          );
                        }
                        return Column(
                          children: snap.data!
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    "${a['name']}: ${a['predict_score_a']} - ${a['predict_score_b']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (jugadorSeleccionadoId != null) {
                      await _guardarApuesta(
                        jugadorSeleccionadoId!,
                        matchId,
                        golesA,
                        golesB,
                      );

                      // PUNTO 1: Cambiamos la Key para forzar al FutureBuilder a recargar
                      setDialogState(() {
                        futureKey = UniqueKey();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("¡Apuesta registrada/actualizada!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirmar Apuesta'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoResultadoReal(
    BuildContext context,
    int matchId,
    String equipoA,
    String equipoB,
  ) {
    int resultadoRealA = 0;
    int resultadoRealB = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🏁 Resultado Oficial: $equipoA vs $equipoB'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ingresa cómo quedó el partido en la realidad:",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(equipoA),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (v) => resultadoRealA = int.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
                const Text("-"),
                Column(
                  children: [
                    Text(equipoB),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (v) => resultadoRealB = int.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _finalizarPartido(matchId, resultadoRealA, resultadoRealB);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Puntos calculados y Ranking actualizado 🏆"),
                ),
              );
            },
            child: const Text(
              'Finalizar Partido',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _eliminarPartido(int id) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Verificar si el partido ya estaba finalizado
    final partido = await db.query('matches', where: 'id = ?', whereArgs: [id]);
    if (partido.isNotEmpty && partido.first['score_a'] != null) {
      int resA = partido.first['score_a'] as int;
      int resB = partido.first['score_b'] as int;

      // 2. Buscar apuestas de ese partido para restar puntos
      final apuestas = await db.query(
        'predictions',
        where: 'match_id = ?',
        whereArgs: [id],
      );
      for (var apuesta in apuestas) {
        int puntosARestar = 0;
        int predA = apuesta['predict_score_a'] as int;
        int predB = apuesta['predict_score_b'] as int;
        int idJugador = apuesta['participant_id'] as int;

        // Calcular cuánto ganó en ese momento
        if (predA == resA && predB == resB) {
          puntosARestar = 3;
        } else {
          int ganReal = (resA > resB) ? 1 : (resA < resB ? -1 : 0);
          int ganPred = (predA > predB) ? 1 : (predA < predB ? -1 : 0);
          if (ganReal == ganPred) puntosARestar = 1;
        }

        // Restar los puntos al jugador
        if (puntosARestar > 0) {
          await db.rawUpdate(
            'UPDATE participants SET points = MAX(0, points - ?) WHERE id = ?',
            [puntosARestar, idJugador],
          );
        }
      }
    }

    // 3. Ahora sí, borrar el partido y sus apuestas
    await db.delete('matches', where: 'id = ?', whereArgs: [id]);
    await db.delete('predictions', where: 'match_id = ?', whereArgs: [id]);
    setState(() {});
  }

  void _reiniciarTodo() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('predictions'); // Borra todas las apuestas
    await db.delete('matches'); // Borra todos los partidos
    await db.delete(
      'participants',
    ); // ¡ESTO ES LO QUE FALTABA! Borra los jugadores
    setState(() {});
    print("🔥 Todo el torneo ha sido eliminado");
  }

  // ... aquí terminan tus otras funciones ...

  Widget _itemEstadistica(String titulo, int valor, Color color) {
    return Column(
      children: [
        Text(
          "$valor",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _mostrarApuestasFinalizadas(
    BuildContext context,
    int matchId,
    String equipoA,
    String equipoB,
    int resultadoA,
    int resultadoB,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final apuestas = await db.rawQuery(
      '''
    SELECT participants.name, predictions.predict_score_a, predictions.predict_score_b 
    FROM predictions 
    JOIN participants ON predictions.participant_id = participants.id
    WHERE predictions.match_id = ?
  ''',
      [matchId],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 $equipoA vs $equipoB'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Resultado oficial
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Resultado oficial: $resultadoA - $resultadoB",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
              // Lista de apuestas
              if (apuestas.isEmpty)
                const Text(
                  "Nadie apostó en este partido",
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...apuestas.map((a) {
                  int predA = a['predict_score_a'] as int;
                  int predB = a['predict_score_b'] as int;

                  // Calcular puntos que ganó
                  int puntos = 0;
                  if (predA == resultadoA && predB == resultadoB) {
                    puntos = 3;
                  } else {
                    int ganReal = resultadoA > resultadoB
                        ? 1
                        : resultadoA < resultadoB
                        ? -1
                        : 0;
                    int ganPred = predA > predB
                        ? 1
                        : predA < predB
                        ? -1
                        : 0;
                    if (ganReal == ganPred) puntos = 1;
                  }

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: puntos == 3
                          ? Colors.amber
                          : puntos == 1
                          ? Colors.blue
                          : Colors.grey[800],
                      child: Text(
                        "+$puntos",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(a['name'] as String),
                    subtitle: Text("Apostó: $predA - $predB"),
                    trailing: puntos == 3
                        ? const Text(
                            "🎯 Exacto",
                            style: TextStyle(color: Colors.amber, fontSize: 12),
                          )
                        : puntos == 1
                        ? const Text(
                            "✅ Ganador",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                            ),
                          )
                        : const Text(
                            "❌ Falló",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
}
