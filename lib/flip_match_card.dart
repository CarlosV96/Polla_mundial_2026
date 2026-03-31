import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';

/// Tarjeta con efecto flip 3D para un partido de la polla.
/// - Cara frontal: info del partido (grupo, equipos, estado/marcador)
/// - Cara trasera: botones de acción (apostar, resultado, eliminar, cerrar)
class FlipMatchCard extends StatefulWidget {
  final Map<String, dynamic> partido;
  final VoidCallback? onApostar;
  final VoidCallback? onIngresarResultado;
  final VoidCallback onEliminar;
  final VoidCallback? onVerApuestas;

  const FlipMatchCard({
    super.key,
    required this.partido,
    this.onApostar,
    this.onIngresarResultado,
    required this.onEliminar,
    this.onVerApuestas,
  });

  @override
  State<FlipMatchCard> createState() => _FlipMatchCardState();
}

class _FlipMatchCardState extends State<FlipMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Animamos de 0 a 1 y mapeamos a 0..π en el build
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    _controller.value < 0.5
        ? _controller.animateTo(1.0)
        : _controller.animateTo(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool finalizado = widget.partido['score_a'] != null;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final angle = _anim.value * math.pi;
        final showingFront = _anim.value < 0.5;

        // Cara frontal: rotateY de 0 → π (desaparece en el borde a π/2)
        // Cara trasera: rotateY de (angle - π), va de -π/2 → 0 (aparece sin espejo)
        final transform = showingFront
            ? (Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle))
            : (Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle - math.pi));

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: showingFront
              ? _FrontFace(
                  partido: widget.partido,
                  finalizado: finalizado,
                  onFlip: _flip,
                )
              : _BackFace(
                  partido: widget.partido,
                  finalizado: finalizado,
                  onApostar: widget.onApostar,
                  onIngresarResultado: widget.onIngresarResultado,
                  onEliminar: widget.onEliminar,
                  onVerApuestas: widget.onVerApuestas,
                  onClose: _flip,
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// CARA FRONTAL
// ---------------------------------------------------------------------------

class _FrontFace extends StatelessWidget {
  final Map<String, dynamic> partido;
  final bool finalizado;
  final VoidCallback onFlip;

  const _FrontFace({
    required this.partido,
    required this.finalizado,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final String equipoA = partido['team_a'] as String;
    final String equipoB = partido['team_b'] as String;
    final String? grupo = partido['group_name'] as String?;

    // Colores según estado
    final Color borderColor = finalizado
        ? AppColors.verde.withOpacity(0.45)
        : AppColors.dorado.withOpacity(0.22);
    final Color headerStart = finalizado
        ? const Color(0xFF1B4332)
        : AppColors.fondoSecundario;
    final Color headerEnd = finalizado
        ? const Color(0xFF2D6A4F).withOpacity(0.7)
        : AppColors.fondoTarjeta;
    final Color statusColor =
        finalizado ? AppColors.verde : AppColors.textoGris;
    final IconData statusIcon =
        finalizado ? Icons.check_circle_outline : Icons.touch_app_outlined;
    final String statusLabel = finalizado ? AppStrings.finalizado : AppStrings.tocaParaAcciones;

    return GestureDetector(
      onTap: onFlip,
      child: Container(
        height: 112,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: (finalizado ? AppColors.verde : AppColors.dorado)
                  .withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header strip ──────────────────────────────────────────────
            Container(
              height: 26,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
                gradient: LinearGradient(colors: [headerStart, headerEnd]),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Grupo
                  if (grupo != null)
                    _GroupBadge(grupo: grupo, finalizado: finalizado)
                  else
                    const SizedBox.shrink(),

                  // Estado
                  Row(
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Contenido principal ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Equipo A
                    Expanded(
                      child: Text(
                        equipoA,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoBlanco,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // Centro: VS o marcador
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: finalizado
                          ? _ScoreBadge(
                              scoreA: partido['score_a'] as int,
                              scoreB: partido['score_b'] as int,
                            )
                          : _VsBadge(),
                    ),

                    // Equipo B
                    Expanded(
                      child: Text(
                        equipoB,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoBlanco,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupBadge extends StatelessWidget {
  final String grupo;
  final bool finalizado;

  const _GroupBadge({required this.grupo, required this.finalizado});

  @override
  Widget build(BuildContext context) {
    final Color color = finalizado ? AppColors.verde : AppColors.dorado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        "${AppStrings.grupo} $grupo",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _VsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dorado.withOpacity(0.07),
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: const Center(
        child: Text(
          "VS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.dorado,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int scoreA;
  final int scoreB;

  const _ScoreBadge({required this.scoreA, required this.scoreB});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.verde.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.verde.withOpacity(0.4), width: 1),
      ),
      child: Text(
        "$scoreA · $scoreB",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.verde,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CARA TRASERA
// ---------------------------------------------------------------------------

class _BackFace extends StatelessWidget {
  final Map<String, dynamic> partido;
  final bool finalizado;
  final VoidCallback? onApostar;
  final VoidCallback? onIngresarResultado;
  final VoidCallback onEliminar;
  final VoidCallback? onVerApuestas;
  final VoidCallback onClose;

  const _BackFace({
    required this.partido,
    required this.finalizado,
    this.onApostar,
    this.onIngresarResultado,
    required this.onEliminar,
    this.onVerApuestas,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.fondoSecundario,
            AppColors.fondoTarjeta,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dorado.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Etiqueta pequeña de equipo para contexto
          Text(
            "${partido['team_a']} vs ${partido['team_b']}",
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textoGris,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: finalizado
                ? _botonesFinalizados(context)
                : _botonesPendientes(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _botonesPendientes(BuildContext context) => [
        _ActionButton(
          icon: Icons.casino_outlined,
          label: AppStrings.apostar,
          color: AppColors.acento,
          onTap: onApostar,
        ),
        _ActionButton(
          icon: Icons.sports_score_outlined,
          label: AppStrings.resultado,
          color: AppColors.dorado,
          onTap: onIngresarResultado,
        ),
        _ActionButton(
          icon: Icons.delete_outline,
          label: AppStrings.eliminar,
          color: AppColors.rojo,
          onTap: onEliminar,
        ),
        _ActionButton(
          icon: Icons.keyboard_arrow_down_rounded,
          label: AppStrings.cerrar,
          color: AppColors.textoGris,
          onTap: onClose,
        ),
      ];

  List<Widget> _botonesFinalizados(BuildContext context) => [
        _ActionButton(
          icon: Icons.bar_chart_rounded,
          label: AppStrings.apuestas,
          color: AppColors.acento,
          onTap: onVerApuestas,
        ),
        _ActionButton(
          icon: Icons.delete_outline,
          label: AppStrings.eliminar,
          color: AppColors.rojo,
          onTap: onEliminar,
        ),
        _ActionButton(
          icon: Icons.keyboard_arrow_down_rounded,
          label: AppStrings.cerrar,
          color: AppColors.textoGris,
          onTap: onClose,
        ),
      ];
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final effectiveColor = enabled ? color : AppColors.textoGris.withOpacity(0.4);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveColor.withOpacity(0.13),
              border: Border.all(
                color: effectiveColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(icon, color: effectiveColor, size: 21),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: effectiveColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}