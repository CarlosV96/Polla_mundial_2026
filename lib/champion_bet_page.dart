import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'app_settings.dart';
import 'database_helper.dart';
import 'world_cup_data.dart';
import 'premium_service.dart';
import 'package:sqflite/sqlite_api.dart';

class ChampionBetPage extends StatefulWidget {
  const ChampionBetPage({super.key});

  @override
  State<ChampionBetPage> createState() => _ChampionBetPageState();
}

class _ChampionBetPageState extends State<ChampionBetPage> {

  // Lista de todos los equipos del mundial
  final List<String> _equipos = WorldCupData.getFixture()
      .expand((p) => [p['team_a']!, p['team_b']!])
      .toSet()
      .toList()
    ..sort();

  Future<List<Map<String, dynamic>>> _obtenerDatos() async {
    final db = await DatabaseHelper.instance.database;
    final jugadores = await db.query('participants', orderBy: 'points DESC');
    final apuestas  = await db.query('champion_bets');

    // Mapa participantId → equipo apostado
    final mapaApuestas = {
      for (var a in apuestas)
        a['participant_id'] as int: a['team'] as String
    };

    return jugadores.map((j) => {
      ...j,
      'champion_pick': mapaApuestas[j['id'] as int],
    }).toList();
  }

  Future<void> _guardarApuesta(int participantId, String equipo) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'champion_bets',
      {'participant_id': participantId, 'team': equipo},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    setState(() {});
  }

  Future<void> _declararCampeon(String equipo) async {
    // 1. Guardar el campeón
    await AppSettings.instance.declararCampeon(equipo);

    // 2. Dar puntos a quienes acertaron
    final db  = await DatabaseHelper.instance.database;
    final pts = AppSettings.instance.puntosChampion;
    final apuestas = await db.query(
      'champion_bets', where: 'team = ?', whereArgs: [equipo],
    );

    for (final a in apuestas) {
      final idJugador = a['participant_id'] as int;
      await db.rawUpdate(
        'UPDATE participants SET points = points + ? WHERE id = ?',
        [pts, idJugador],
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.campeonDeclaradoMsg)),
      );
    }
    setState(() {});
  }

  Future<void> _resetearCampeon() async {
    // 1. Restar puntos a quienes habían acertado
    final db     = await DatabaseHelper.instance.database;
    final pts    = AppSettings.instance.puntosChampion;
    final campeon = AppSettings.instance.champion;

    final apuestas = await db.query(
      'champion_bets', where: 'team = ?', whereArgs: [campeon],
    );
    for (final a in apuestas) {
      await db.rawUpdate(
        'UPDATE participants SET points = MAX(0, points - ?) WHERE id = ?',
        [pts, a['participant_id']],
      );
    }

    // 2. Resetear el campeón
    await AppSettings.instance.resetearCampeon();
    setState(() {});
  }

  void _mostrarSelectorEquipo(int participantId, String nombre) {
    String? seleccion;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.fondoSecundario,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dorado,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.apuestaCampeonDesc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _equipos.length,
                  itemBuilder: (_, i) {
                    final equipo = _equipos[i];
                    final elegido = seleccion == equipo;
                    return GestureDetector(
                      onTap: () => setSheet(() => seleccion = equipo),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: elegido
                              ? AppColors.dorado.withOpacity(0.12)
                              : AppColors.fondoTarjeta,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: elegido
                                ? AppColors.dorado.withOpacity(0.6)
                                : AppColors.dorado.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                equipo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: elegido
                                      ? AppColors.dorado
                                      : AppColors.textoBlanco,
                                  fontWeight: elegido
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (elegido)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.dorado,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: seleccion == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            _guardarApuesta(participantId, seleccion!);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dorado,
                      foregroundColor: AppColors.fondoPrincipal,
                      disabledBackgroundColor:
                          AppColors.dorado.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.confirmar,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDeclararCampeon() {
    String? seleccion;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.fondoSecundario,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.verde.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/trophy.png',
                      width: 50, height: 50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.declararCampeon,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.verde,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _equipos.length,
                  itemBuilder: (_, i) {
                    final equipo = _equipos[i];
                    final elegido = seleccion == equipo;
                    return GestureDetector(
                      onTap: () => setSheet(() => seleccion = equipo),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: elegido
                              ? AppColors.verde.withOpacity(0.12)
                              : AppColors.fondoTarjeta,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: elegido
                                ? AppColors.verde.withOpacity(0.6)
                                : AppColors.dorado.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                equipo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: elegido
                                      ? AppColors.verde
                                      : AppColors.textoBlanco,
                                  fontWeight: elegido
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (elegido)
                              const Icon(
                                Icons.emoji_events,
                                color: AppColors.verde,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: seleccion == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            _declararCampeon(seleccion!);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: AppColors.fondoPrincipal,
                      disabledBackgroundColor:
                          AppColors.verde.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.declararCampeon,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campeonDeclarado = AppSettings.instance.championDeclarado;
    final campeon = AppSettings.instance.champion;
    final pts = AppSettings.instance.puntosChampion;

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Text(AppStrings.apuestaCampeon),
        backgroundColor: AppColors.fondoPrincipal,
        iconTheme: const IconThemeData(color: AppColors.dorado),
        actions: [
          // Resetear campeón si ya fue declarado
          if (campeonDeclarado)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.rojo),
              tooltip: AppStrings.resetearCampeon,
              onPressed: () => _resetearCampeon(),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F2E), Color(0xFF0D1333), Color(0xFF0A0F2E)],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _obtenerDatos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.dorado),
              );
            }

            final jugadores = snapshot.data!;

            return Column(
              children: [
                // ── Banner puntos ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.dorado.withOpacity(0.15),
                        AppColors.dorado.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.dorado.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/trophy.png',
                        width: 44, height: 44,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.apuestaCampeonDesc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textoBlanco,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              campeonDeclarado
                                  ? '${AppStrings.campeonActual}: $campeon'
                                  : '${AppStrings.puntosBonusCampeon}: $pts pts',
                              style: TextStyle(
                                fontSize: 11,
                                color: campeonDeclarado
                                    ? AppColors.verde
                                    : AppColors.dorado,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ajustar puntos (solo si no hay campeón declarado)
                      if (!campeonDeclarado) ...[
                        _botonPts(
                          Icons.remove,
                          pts > 1
                              ? () => AppSettings.instance
                                    .cambiarPuntosChampion(pts - 1)
                                    .then((_) => setState(() {}))
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$pts',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dorado,
                            ),
                          ),
                        ),
                        _botonPts(
                          Icons.add,
                          pts < 20
                              ? () => AppSettings.instance
                                    .cambiarPuntosChampion(pts + 1)
                                    .then((_) => setState(() {}))
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Lista jugadores ────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: jugadores.length,
                    itemBuilder: (_, i) {
                      final j = jugadores[i];
                      final pick = j['champion_pick'] as String?;
                      final acerto = campeonDeclarado && pick == campeon;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: acerto
                              ? AppColors.verde.withOpacity(0.08)
                              : AppColors.fondoTarjeta,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: acerto
                                ? AppColors.verde.withOpacity(0.4)
                                : AppColors.dorado.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Nombre
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    j['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoBlanco,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    pick ?? AppStrings.sinApuestaCampeon,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: pick != null
                                          ? (acerto
                                              ? AppColors.verde
                                              : AppColors.dorado)
                                          : AppColors.textoGris,
                                      fontWeight: acerto
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Badge acertó
                            if (acerto)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.verde.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.verde.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  '+$pts pts',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.verde,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // Botón editar (solo si no hay campeón)
                            if (!campeonDeclarado) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _mostrarSelectorEquipo(
                                  j['id'] as int,
                                  j['name'] as String,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.dorado.withOpacity(0.12),
                                    border: Border.all(
                                      color: AppColors.dorado.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.dorado,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Botón declarar campeón ─────────────────────────────────
                if (!campeonDeclarado)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Image.asset(
                          'assets/images/trophy.png',
                          width: 20, height: 20,
                        ),
                        label: Text(AppStrings.declararCampeon),
                        onPressed: _mostrarDeclararCampeon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verde,
                          foregroundColor: AppColors.fondoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _botonPts(IconData icono, VoidCallback? onTap) {
    final activo = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.dorado.withOpacity(activo ? 0.12 : 0.04),
          border: Border.all(
            color: AppColors.dorado.withOpacity(activo ? 0.4 : 0.1),
          ),
        ),
        child: Icon(
          icono,
          color: AppColors.dorado.withOpacity(activo ? 1.0 : 0.3),
          size: 14,
        ),
      ),
    );
  }
}