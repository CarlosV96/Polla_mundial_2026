import 'package:flutter/material.dart';
import 'database_helper.dart';

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
      appBar: AppBar(
        title: Text(nombre),
        centerTitle: true,
        backgroundColor: Colors.green[900],
      ),
      body: Column(
        children: [
          // --- CABECERA CON PUNTOS ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.green[900]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green[700]!, width: 1),
            ),
            child: Column(
              children: [
                const Icon(Icons.person, size: 50, color: Colors.greenAccent),
                const SizedBox(height: 8),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$puntos puntos totales",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Historial de apuestas",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // --- LISTA DE HISTORIAL ---
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getPlayerHistory(participantId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Este jugador aún no ha apostado en ningún partido.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final h = snapshot.data![index];
                    final predA = h['predict_score_a'] as int;
                    final predB = h['predict_score_b'] as int;
                    final realA = h['score_a'];
                    final realB = h['score_b'];
                    final bool finalizado = realA != null && realB != null;

                    // Calcular puntos ganados
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

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        // Ícono de resultado
                        leading: CircleAvatar(
                          backgroundColor: !finalizado
                              ? Colors.grey[800]
                              : puntosGanados == 3
                              ? Colors.amber
                              : puntosGanados == 1
                              ? Colors.blue
                              : Colors.grey[800],
                          child: Text(
                            finalizado ? "+$puntosGanados" : "?",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Partido
                        title: Text(
                          "${h['team_a']} vs ${h['team_b']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Apuesta y resultado
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mi apuesta: $predA - $predB",
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (finalizado)
                              Text(
                                "Resultado real: $realA - $realB",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              const Text(
                                "Partido pendiente",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        // Etiqueta de resultado
                        trailing: !finalizado
                            ? const Icon(Icons.schedule, color: Colors.grey)
                            : puntosGanados == 3
                            ? const Text(
                                "🎯 Exacto",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                ),
                              )
                            : puntosGanados == 1
                            ? const Text(
                                "✅ Ganador",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
                                ),
                              )
                            : const Text(
                                "❌ Falló",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
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
