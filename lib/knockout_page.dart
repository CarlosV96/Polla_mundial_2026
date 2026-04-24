import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'database_helper.dart';
import 'flip_match_card.dart';
import 'ad_banner_widget.dart';
import 'premium_service.dart';
import 'premium_gate.dart';

class KnockoutPage extends StatefulWidget {
  final Function(int matchId, String teamA, String teamB) onApostar;
  final Function(int matchId, String teamA, String teamB) onIngresarResultado;
  final Function(int matchId, String equipos) onEliminarPartido;
  final Function(
    int matchId,
    String teamA,
    String teamB,
    int scoreA,
    int scoreB,
  ) onVerApuestas;

  const KnockoutPage({
    super.key,
    required this.onApostar,
    required this.onIngresarResultado,
    required this.onEliminarPartido,
    required this.onVerApuestas,
  });

  @override
  State<KnockoutPage> createState() => _KnockoutPageState();
}

class _KnockoutPageState extends State<KnockoutPage> {

  Future<List<Map<String, dynamic>>> _obtenerRondas() async {
    return await DatabaseHelper.instance.getKnockoutRounds();
  }

  Future<List<Map<String, dynamic>>> _obtenerPartidosRonda(
    int roundId,
  ) async {
    return await DatabaseHelper.instance.getMatchesByRound(roundId);
  }

  void _mostrarDialogoNuevaRonda(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NuevaRondaSheet(
        onCrear: (nombre) async {
          await DatabaseHelper.instance.crearKnockoutRound(nombre);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _mostrarDialogoNuevoPartido(
    BuildContext context,
    int roundId,
  ) {
    String teamA = '';
    String teamB = '';
    final ctrlA = TextEditingController();
    final ctrlB = TextEditingController();

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
              color: AppColors.acento.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_soccer,
                color: AppColors.acento,
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.nuevoPartido,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.acento,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Equipo A
              TextField(
                controller: ctrlA,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textoBlanco),
                decoration: InputDecoration(
                  hintText: AppStrings.equipoLocal,
                  prefixIcon: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.dorado,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.fondoPrincipal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.acento,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => teamA = v,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.acento.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.acento.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.acento.withOpacity(0.2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Equipo B
              TextField(
                controller: ctrlB,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textoBlanco),
                decoration: InputDecoration(
                  hintText: AppStrings.equipoVisitante,
                  prefixIcon: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.acento,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.fondoPrincipal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.acento,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => teamB = v,
              ),

              const SizedBox(height: 20),

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
                      child: Text(
                        AppStrings.cancelar,
                        style: const TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (teamA.trim().isEmpty || teamB.trim().isEmpty) {
                          return;
                        }
                        await DatabaseHelper.instance.insertKnockoutMatch(
                          teamA.trim(),
                          teamB.trim(),
                          roundId,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.acento,
                        foregroundColor: AppColors.fondoPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.crearPartido,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _confirmarEliminarRonda(BuildContext context, int roundId, String nombre) {
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
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.rojo,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.eliminarRonda,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rojo,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoBlanco,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.eliminarRondaMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoGris,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
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
                      child: Text(
                        AppStrings.cancelar,
                        style: const TextStyle(color: AppColors.textoGris),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await DatabaseHelper.instance
                            .eliminarKnockoutRound(roundId);
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.eliminar,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      child: _buildContenido(context),
    );
  }

  Widget _buildContenido(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Center(child: AdBannerWidget()),
        const SizedBox(height: 6),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _obtenerRondas(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.dorado),
                );
              }

              final rondas = snapshot.data!;

              if (rondas.isEmpty) {
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
                        AppStrings.sinRondas,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textoGris,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: rondas.length,
                itemBuilder: (context, index) {
                  final ronda = rondas[index];
                  return _RondaWidget(
                    ronda: ronda,
                    onAgregarPartido: () => _mostrarDialogoNuevoPartido(
                      context,
                      ronda['id'] as int,
                    ),
                    onEliminarRonda: () => _confirmarEliminarRonda(
                      context,
                      ronda['id'] as int,
                      ronda['name'] as String,
                    ),
                    onApostar: widget.onApostar,
                    onIngresarResultado: widget.onIngresarResultado,
                    onEliminarPartido: widget.onEliminarPartido,
                    onVerApuestas: widget.onVerApuestas,
                    onRefresh: () => setState(() {}),
                  );
                },
              );
            },
          ),
        ),

        // Botón nueva ronda
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(AppStrings.nuevaRonda),
              onPressed: () => _mostrarDialogoNuevaRonda(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acento,
                foregroundColor: AppColors.fondoPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widget de ronda expandible ────────────────────────────────────────────────
class _RondaWidget extends StatefulWidget {
  final Map<String, dynamic> ronda;
  final VoidCallback onAgregarPartido;
  final VoidCallback onEliminarRonda;
  final Function(int, String, String) onApostar;
  final Function(int, String, String) onIngresarResultado;
  final Function(int, String) onEliminarPartido;
  final Function(int, String, String, int, int) onVerApuestas;
  final VoidCallback onRefresh;

  const _RondaWidget({
    required this.ronda,
    required this.onAgregarPartido,
    required this.onEliminarRonda,
    required this.onApostar,
    required this.onIngresarResultado,
    required this.onEliminarPartido,
    required this.onVerApuestas,
    required this.onRefresh,
  });

  @override
  State<_RondaWidget> createState() => _RondaWidgetState();
}

class _RondaWidgetState extends State<_RondaWidget> {
  bool _expandida = true;

  @override
  Widget build(BuildContext context) {
    final nombre = widget.ronda['name'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.acento.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // ── Header de la ronda ─────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expandida = !_expandida),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.acento.withOpacity(0.15),
                    AppColors.acento.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(13),
                  bottom: _expandida
                      ? Radius.zero
                      : const Radius.circular(13),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.acento,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.acento,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Agregar partido
                  GestureDetector(
                    onTap: widget.onAgregarPartido,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.acento.withOpacity(0.15),
                        border: Border.all(
                          color: AppColors.acento.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.acento,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Eliminar ronda
                  GestureDetector(
                    onTap: widget.onEliminarRonda,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.rojo.withOpacity(0.12),
                        border: Border.all(
                          color: AppColors.rojo.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.rojo,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expandir/colapsar
                  Icon(
                    _expandida
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textoGris,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Partidos de la ronda ───────────────────────────────────────
          if (_expandida)
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getMatchesByRound(
                widget.ronda['id'] as int,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.acento,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final partidos = snapshot.data!;

                if (partidos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.sinPartidosRonda,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textoGris,
                      ),
                    ),
                  );
                }

                return Column(
                  children: partidos.map((p) {
                    return FlipMatchCard(
                      partido: p,
                      onApostar: p['score_a'] == null
                          ? () => widget.onApostar(
                              p['id'] as int,
                              p['team_a'] as String,
                              p['team_b'] as String,
                            )
                          : null,
                      onIngresarResultado: p['score_a'] == null
                          ? () => widget.onIngresarResultado(
                              p['id'] as int,
                              p['team_a'] as String,
                              p['team_b'] as String,
                            )
                          : null,
                      onEliminar: () => widget.onEliminarPartido(
                        p['id'] as int,
                        '${p['team_a']} vs ${p['team_b']}',
                      ),
                      onVerApuestas: p['score_a'] != null
                          ? () => widget.onVerApuestas(
                              p['id'] as int,
                              p['team_a'] as String,
                              p['team_b'] as String,
                              p['score_a'] as int,
                              p['score_b'] as int,
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ── Sheet para crear nueva ronda ──────────────────────────────────────────────
class _NuevaRondaSheet extends StatefulWidget {
  final Function(String) onCrear;

  const _NuevaRondaSheet({required this.onCrear});

  @override
  State<_NuevaRondaSheet> createState() => _NuevaRondaSheetState();
}

class _NuevaRondaSheetState extends State<_NuevaRondaSheet> {
  String _nombre = '';
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.fondoSecundario,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.acento.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.acento.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              AppStrings.nuevaRonda,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.acento,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 16),

            // Sugerencias rápidas
            Text(
              AppStrings.rondasPredefinidas,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textoGris,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AppStrings.rondasSugeridas.map((r) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _nombre = r;
                      _ctrl.text = r;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _nombre == r
                          ? AppColors.acento.withOpacity(0.15)
                          : AppColors.fondoTarjeta,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _nombre == r
                            ? AppColors.acento.withOpacity(0.6)
                            : AppColors.dorado.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      r,
                      style: TextStyle(
                        fontSize: 11,
                        color: _nombre == r
                            ? AppColors.acento
                            : AppColors.textoGris,
                        fontWeight: _nombre == r
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // TextField nombre personalizado
            TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppColors.textoBlanco),
              decoration: InputDecoration(
                hintText: AppStrings.nombreRonda,
                prefixIcon: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.acento,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.fondoPrincipal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.acento,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) => setState(() => _nombre = v),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nombre.trim().isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.onCrear(_nombre.trim());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.acento,
                  foregroundColor: AppColors.fondoPrincipal,
                  disabledBackgroundColor: AppColors.acento.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.crearPartido,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}