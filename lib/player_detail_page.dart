import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'app_colors.dart';

class PlayerDetailPage extends StatelessWidget {
  final int participantId;
  final String nombre;
  final int puntos;

  const PlayerDetailPage({
    super.key,
    required this.participantId,
    required this.nombre,
    required this.puntos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getPlayerHistory(participantId),
        builder: (context, snapshot) {
          final historial = snapshot.data ?? [];

          // Calcular estadísticas
          int exactos = 0;
          int ganadores = 0;
          int fallidos = 0;
          int pendientes = 0;

          for (final h in historial) {
            final predA = h['predict_score_a'] as int;
            final predB = h['predict_score_b'] as int;
            final realA = h['score_a'];
            final realB = h['score_b'];

            if (realA == null || realB == null) {
              pendientes++;
              continue;
            }

            if (predA == realA && predB == realB) {
              exactos++;
            } else {
              int ganReal = realA > realB ? 1 : realA < realB ? -1 : 0;
              int ganPred = predA > predB ? 1 : predA < predB ? -1 : 0;
              if (ganReal == ganPred) {
                ganadores++;
              } else {
                fallidos++;
              }
            }
          }

          final int jugados = exactos + ganadores + fallidos;
          final double precision =
              jugados > 0 ? (exactos + ganadores) / jugados * 100 : 0;

          return CustomScrollView(
            slivers: [
              // ── HEADER ─────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.fondoPrincipal,
                iconTheme:
                    const IconThemeData(color: AppColors.dorado),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A2255),
                          AppColors.fondoPrincipal,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Avatar con inicial
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.dorado,
                                AppColors.doradoClaro,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dorado.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              nombre[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.fondoPrincipal,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Nombre
                        Text(
                          nombre.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoBlanco,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Puntos totales
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            "$puntos puntos totales",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── ESTADÍSTICAS ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ESTADÍSTICAS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoGris,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid de stats
                      Row(
                        children: [
                          _StatCard(
                            valor: exactos,
                            label: "Exactos",
                            color: const Color(0xFFFFD700),
                            emoji: "🎯",
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            valor: ganadores,
                            label: "Ganador",
                            color: AppColors.acento,
                            emoji: "✅",
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            valor: fallidos,
                            label: "Fallos",
                            color: AppColors.rojo,
                            emoji: "❌",
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            valor: pendientes,
                            label: "Pendientes",
                            color: AppColors.textoGris,
                            emoji: "⏳",
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Barra de precisión
                      if (jugados > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Precisión",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textoGris,
                              ),
                            ),
                            Text(
                              "${precision.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dorado,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: precision / 100,
                            minHeight: 7,
                            backgroundColor:
                                AppColors.fondoTarjeta,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.dorado,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Título historial
                      const Text(
                        "HISTORIAL DE APUESTAS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoGris,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // ── LISTA DE HISTORIAL ──────────────────────────────────────
              snapshot.connectionState == ConnectionState.waiting
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.dorado,
                        ),
                      ),
                    )
                  : historial.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Este jugador aún no ha apostado.",
                          style: TextStyle(color: AppColors.textoGris),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final h = historial[index];
                            final predA = h['predict_score_a'] as int;
                            final predB = h['predict_score_b'] as int;
                            final realA = h['score_a'];
                            final realB = h['score_b'];
                            final bool finalizado =
                                realA != null && realB != null;

                            int puntosGanados = 0;
                            if (finalizado) {
                              if (predA == realA && predB == realB) {
                                puntosGanados = 3;
                              } else {
                                int ganReal = realA > realB
                                    ? 1
                                    : realA < realB
                                    ? -1
                                    : 0;
                                int ganPred = predA > predB
                                    ? 1
                                    : predA < predB
                                    ? -1
                                    : 0;
                                if (ganReal == ganPred) puntosGanados = 1;
                              }
                            }

                            Color resultColor = AppColors.textoGris;
                            String resultLabel = "⏳ Pendiente";
                            if (finalizado) {
                              if (puntosGanados == 3) {
                                resultColor = const Color(0xFFFFD700);
                                resultLabel = "🎯 Exacto";
                              } else if (puntosGanados == 1) {
                                resultColor = AppColors.acento;
                                resultLabel = "✅ Ganador";
                              } else {
                                resultColor = AppColors.rojo;
                                resultLabel = "❌ Falló";
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: AppColors.fondoTarjeta,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: resultColor.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Círculo de puntos
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          resultColor.withOpacity(0.15),
                                      border: Border.all(
                                        color: resultColor.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        finalizado
                                            ? "+$puntosGanados"
                                            : "?",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: resultColor,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Info partido
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${h['team_a']} vs ${h['team_b']}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textoBlanco,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Mi apuesta: $predA — $predB",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textoGris,
                                          ),
                                        ),
                                        if (finalizado)
                                          Text(
                                            "Resultado: $realA — $realB",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: resultColor
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Etiqueta resultado
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
                            );
                          },
                          childCount: historial.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}

// ── WIDGET STAT CARD ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final int valor;
  final String label;
  final Color color;
  final String emoji;

  const _StatCard({
    required this.valor,
    required this.label,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              "$valor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textoGris,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}