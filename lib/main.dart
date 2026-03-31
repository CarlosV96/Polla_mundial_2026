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

  void _confirmarEliminacionJugador(
    BuildContext context,
    int id,
    String nombre,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.rojo.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.rojo.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rojo.withOpacity(0.12),
                  border: Border.all(color: AppColors.rojo.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.rojo,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "ELIMINAR JUGADOR",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rojo,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoGris,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "¿Eliminar a "),
                    TextSpan(
                      text: nombre,
                      style: const TextStyle(
                        color: AppColors.textoBlanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: "?\nSe borrarán sus puntos y todas sus apuestas.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.textoGris.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _eliminarJugador(id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.rojo.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.rojo.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rojo.withOpacity(0.12),
                  border: Border.all(color: AppColors.rojo.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: AppColors.rojo,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "ELIMINAR PARTIDO",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rojo,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoGris,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "Se eliminará el partido\n"),
                    TextSpan(
                      text: equipos,
                      style: const TextStyle(
                        color: AppColors.textoBlanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          "\ny todas sus apuestas.\nSi ya tenía resultado, los puntos serán revertidos.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.textoGris.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _eliminarPartido(id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.fondoSecundario,
                          AppColors.fondoTarjeta,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.rojo.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rojo.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícono de advertencia
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.rojo.withOpacity(0.12),
                            border: Border.all(
                              color: AppColors.rojo.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.rojo,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "¡REINICIAR TORNEO!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.rojo,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Esta acción eliminará TODOS los jugadores, partidos, apuestas y puntos.\n\nEsta acción no se puede deshacer.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textoGris,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón cancelar full width
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.textoGris.withOpacity(0.3),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: AppColors.textoGris),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Botón confirmar full width
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _reiniciarTodo();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.rojo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "SÍ, REINICIAR TODO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    final TextEditingController ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dorado.withOpacity(0.12),
                  border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: AppColors.dorado,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              // Título
              const Text(
                "NUEVO PARTICIPANTE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Ingresa el nombre del jugador",
                style: TextStyle(fontSize: 12, color: AppColors.textoGris),
              ),

              const SizedBox(height: 20),

              // TextField
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textoBlanco),
                decoration: InputDecoration(
                  hintText: "Nombre del participante",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.dorado,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.fondoPrincipal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.dorado,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => nombre = v,
                onSubmitted: (_) {
                  _agregarJugador(nombre);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.textoGris.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _agregarJugador(nombre);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dorado,
                        foregroundColor: AppColors.fondoPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Registrar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoPartido(BuildContext context) {
    String local = "";
    String visitante = "";
    final TextEditingController ctrlLocal = TextEditingController();
    final TextEditingController ctrlVisitante = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dorado.withOpacity(0.12),
                  border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: AppColors.dorado,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "NUEVO PARTIDO",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Ingresa los equipos que se enfrentan",
                style: TextStyle(fontSize: 12, color: AppColors.textoGris),
              ),

              const SizedBox(height: 24),

              // Equipo A
              TextField(
                controller: ctrlLocal,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textoBlanco),
                decoration: InputDecoration(
                  hintText: "Equipo local",
                  prefixIcon: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.dorado,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.fondoPrincipal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.dorado,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => local = v,
              ),

              const SizedBox(height: 12),

              // VS separador
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.dorado.withOpacity(0.2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dorado.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.dorado.withOpacity(0.2)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Equipo B
              TextField(
                controller: ctrlVisitante,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textoBlanco),
                decoration: InputDecoration(
                  hintText: "Equipo visitante",
                  prefixIcon: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.acento,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.fondoPrincipal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dorado.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.dorado,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => visitante = v,
                onSubmitted: (_) {
                  _agregarPartido(local, visitante);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.textoGris.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _agregarPartido(local, visitante);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dorado,
                        foregroundColor: AppColors.fondoPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Crear Partido",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoApuesta(
    BuildContext context,
    int matchId,
    String equipoA,
    String equipoB,
  ) async {
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
    Key futureKey = UniqueKey();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.dorado.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── TÍTULO ──────────────────────────────────────────
                    const Icon(
                      Icons.casino_outlined,
                      color: AppColors.dorado,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "REALIZAR APUESTA",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dorado,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SELECTOR DE JUGADOR ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.fondoPrincipal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.25),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text(
                            "¿Quién apuesta?",
                            style: TextStyle(
                              color: AppColors.textoGris,
                              fontSize: 13,
                            ),
                          ),
                          value: jugadorSeleccionadoId,
                          dropdownColor: AppColors.fondoSecundario,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.dorado,
                          ),
                          items: jugadores.map((j) {
                            return DropdownMenuItem<int>(
                              value: j['id'],
                              child: Text(
                                j['name'],
                                style: const TextStyle(
                                  color: AppColors.textoBlanco,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              jugadorSeleccionadoId = value;
                              golesA = 0;
                              golesB = 0;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── MARCADOR TIPO ESTADIO ────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fondoPrincipal,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Equipo A
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  equipoA,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoBlanco,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Botones +/-
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _botonGol(
                                      icono: Icons.remove,
                                      onTap: () => setDialogState(() {
                                        if (golesA > 0) golesA--;
                                      }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        "$golesA",
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dorado,
                                        ),
                                      ),
                                    ),
                                    _botonGol(
                                      icono: Icons.add,
                                      onTap: () => setDialogState(() {
                                        golesA++;
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Separador VS
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.dorado.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.dorado.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Text(
                                    "VS",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dorado,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Equipo B
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  equipoB,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoBlanco,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _botonGol(
                                      icono: Icons.remove,
                                      onTap: () => setDialogState(() {
                                        if (golesB > 0) golesB--;
                                      }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        "$golesB",
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dorado,
                                        ),
                                      ),
                                    ),
                                    _botonGol(
                                      icono: Icons.add,
                                      onTap: () => setDialogState(() {
                                        golesB++;
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── APUESTAS REGISTRADAS ─────────────────────────────
                    FutureBuilder<List<Map<String, dynamic>>>(
                      key: futureKey,
                      future: _obtenerApuestasDelPartido(matchId),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data!.isEmpty) {
                          return Text(
                            "Nadie ha apostado aún",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textoGris,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "APUESTAS REGISTRADAS",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoGris,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...snap.data!.map(
                              (a) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.fondoPrincipal,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.verde.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: AppColors.textoGris,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          a['name'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textoBlanco,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${a['predict_score_a']} — ${a['predict_score_b']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.verde,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── BOTONES ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.textoGris.withOpacity(0.3),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: AppColors.textoGris),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: jugadorSeleccionadoId == null
                                ? null
                                : () async {
                                    await _guardarApuesta(
                                      jugadorSeleccionadoId!,
                                      matchId,
                                      golesA,
                                      golesB,
                                    );
                                    setDialogState(() {
                                      futureKey = UniqueKey();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("¡Apuesta registrada!"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dorado,
                              foregroundColor: AppColors.fondoPrincipal,
                              disabledBackgroundColor: AppColors.dorado
                                  .withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Confirmar",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── HELPER botón +/− ─────────────────────────────────────────────────────────
  Widget _botonGol({
    required IconData icono,
    required VoidCallback onTap,
    Color color = AppColors.dorado, // ← parámetro opcional con default
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icono, color: color, size: 16),
      ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.verde.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.verde.withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── TÍTULO ──────────────────────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.verde.withOpacity(0.12),
                      border: Border.all(
                        color: AppColors.verde.withOpacity(0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_score,
                      color: AppColors.verde,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "RESULTADO OFICIAL",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verde,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "$equipoA vs $equipoB",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoGris,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── MARCADOR ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fondoPrincipal,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.verde.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Equipo A
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                equipoA,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoBlanco,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _botonGol(
                                    icono: Icons.remove,
                                    onTap: () => setDialogState(() {
                                      if (resultadoRealA > 0) resultadoRealA--;
                                    }),
                                    color: AppColors.verde,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      "$resultadoRealA",
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.verde,
                                      ),
                                    ),
                                  ),
                                  _botonGol(
                                    icono: Icons.add,
                                    onTap: () => setDialogState(() {
                                      resultadoRealA++;
                                    }),
                                    color: AppColors.verde,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Separador
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.verde.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.verde.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              "—",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.verde,
                              ),
                            ),
                          ),
                        ),

                        // Equipo B
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                equipoB,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoBlanco,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _botonGol(
                                    icono: Icons.remove,
                                    onTap: () => setDialogState(() {
                                      if (resultadoRealB > 0) resultadoRealB--;
                                    }),
                                    color: AppColors.verde,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      "$resultadoRealB",
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.verde,
                                      ),
                                    ),
                                  ),
                                  _botonGol(
                                    icono: Icons.add,
                                    onTap: () => setDialogState(() {
                                      resultadoRealB++;
                                    }),
                                    color: AppColors.verde,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Aviso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: AppColors.textoGris,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Esta acción calculará los puntos automáticamente",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── BOTONES ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.textoGris.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: AppColors.textoGris),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _finalizarPartido(
                              matchId,
                              resultadoRealA,
                              resultadoRealB,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "🏆 Puntos calculados y ranking actualizado",
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            foregroundColor: AppColors.fondoPrincipal,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Finalizar",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fondoSecundario, AppColors.fondoTarjeta],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.acento.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.acento.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── TÍTULO ────────────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.acento.withOpacity(0.12),
                  border: Border.all(color: AppColors.acento.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.acento,
                  size: 30,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "RESUMEN DEL PARTIDO",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.acento,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "$equipoA vs $equipoB",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoGris,
                ),
              ),

              const SizedBox(height: 16),

              // ── RESULTADO OFICIAL ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.verde.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      equipoA,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBlanco,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "$resultadoA — $resultadoB",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.verde,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    Text(
                      equipoB,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBlanco,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── LISTA DE APUESTAS ──────────────────────────────────────
              if (apuestas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Nadie apostó en este partido",
                    style: TextStyle(color: AppColors.textoGris),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: apuestas.length,
                    itemBuilder: (context, index) {
                      final a = apuestas[index];
                      final predA = a['predict_score_a'] as int;
                      final predB = a['predict_score_b'] as int;

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

                      Color resultColor;
                      String resultLabel;
                      IconData resultIcon;

                      if (puntos == 3) {
                        resultColor = const Color(0xFFFFD700);
                        resultLabel = "Exacto";
                        resultIcon = Icons.gps_fixed;
                      } else if (puntos == 1) {
                        resultColor = AppColors.acento;
                        resultLabel = "Ganador";
                        resultIcon = Icons.check_circle_outline;
                      } else {
                        resultColor = AppColors.rojo;
                        resultLabel = "Falló";
                        resultIcon = Icons.cancel_outlined;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: resultColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Puntos
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: resultColor.withOpacity(0.15),
                                border: Border.all(
                                  color: resultColor.withOpacity(0.5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "+$puntos",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: resultColor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Nombre y apuesta
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoBlanco,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Apostó: $predA — $predB",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textoGris,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Etiqueta resultado
                            Row(
                              children: [
                                Icon(resultIcon, size: 14, color: resultColor),
                                const SizedBox(width: 4),
                                Text(
                                  resultLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: resultColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // ── BOTÓN CERRAR ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acento,
                    foregroundColor: AppColors.fondoPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
