import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'database_helper.dart';

class TournamentHistoryPage extends StatelessWidget {
  const TournamentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Text(AppStrings.historialTorneos),
        backgroundColor: AppColors.fondoPrincipal,
        iconTheme: const IconThemeData(color: AppColors.dorado),
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
          future: DatabaseHelper.instance.getTournamentsArchivados(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.dorado),
              );
            }

            if (snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 60,
                      color: AppColors.textoGris.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.sinTorneosArchivados,
                      style: const TextStyle(color: AppColors.textoGris),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final torneo = snapshot.data![index];
                final fecha  = torneo['created_at'] as String;
                final fechaCorta = fecha.substring(0, 10);

                return GestureDetector(
                  onTap: () => _mostrarRankingFinal(
                    context,
                    torneo['id'] as int,
                    torneo['name'] as String,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.fondoTarjeta,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.dorado.withOpacity(0.12),
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.dorado,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                torneo['name'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoBlanco,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                fechaCorta,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textoGris,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textoGris,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarRankingFinal(
    BuildContext context,
    int torneoId,
    String nombre,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RankingFinalSheet(
        torneoId: torneoId,
        nombre: nombre,
      ),
    );
  }
}

class _RankingFinalSheet extends StatelessWidget {
  final int torneoId;
  final String nombre;

  const _RankingFinalSheet({
    required this.torneoId,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.fondoSecundario,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/trophy.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dorado,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.rankingFinal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getSnapshotTorneo(torneoId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.dorado),
                  );
                }

                final jugadores = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: jugadores.length,
                  itemBuilder: (context, index) {
                    final j      = jugadores[index];
                    final puesto = index + 1;

                    final Color color = puesto == 1
                        ? const Color(0xFFFFD700)
                        : puesto == 2
                            ? const Color(0xFFC0C0C0)
                            : puesto == 3
                                ? const Color(0xFFCD7F32)
                                : AppColors.textoGris;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fondoTarjeta,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withOpacity(puesto <= 3 ? 0.4 : 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$puesto',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              j['participant_name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textoBlanco,
                              ),
                            ),
                          ),
                          Text(
                            '${j['points']} pts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}