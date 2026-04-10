import 'package:flutter/material.dart';
import 'app_colors.dart';

class PodiumFIFA extends StatefulWidget {
  final String? primero;
  final String? segundo;
  final String? tercero;
  final int puntos1;
  final int puntos2;
  final int puntos3;

  const PodiumFIFA({
    super.key,
    this.primero,
    this.segundo,
    this.tercero,
    this.puntos1 = 0,
    this.puntos2 = 0,
    this.puntos3 = 0,
  });

  @override
  State<PodiumFIFA> createState() => _PodiumFIFAState();
}

class _PodiumFIFAState extends State<PodiumFIFA> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlayer(
            nombre: widget.segundo ?? "-",
            puntos: widget.puntos2,
            altura: 80,
            color: const Color(0xFFC0C0C0),
            delay: 0.2,
          ),
          const SizedBox(width: 10),
          _buildPlayer(
            nombre: widget.primero ?? "-",
            puntos: widget.puntos1,
            altura: 110,
            color: const Color(0xFFFFD700),
            esPrimero: true,
            delay: 0.0,
          ),
          const SizedBox(width: 10),
          _buildPlayer(
            nombre: widget.tercero ?? "-",
            puntos: widget.puntos3,
            altura: 65,
            color: const Color(0xFFCD7F32),
            delay: 0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer({
    required String nombre,
    required int puntos,
    required double altura,
    required Color color,
    bool esPrimero = false,
    required double delay,
  }) {
    final anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1, curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: anim,
      child: Container(
        width: esPrimero ? 110 : 95,
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 👑 Corona para el primero
            if (esPrimero) Image.asset('assets/images/crown.png', width: 32),

            const SizedBox(height: 2),

            // Nombre
            Text(
              nombre,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: esPrimero ? 13 : 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textoBlanco,
              ),
            ),

            Text(
              "$puntos pts",
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // 🧱 BLOQUE FIFA
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: altura,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),

                // 🎨 Gradiente FIFA
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.6),
                    color.withOpacity(0.3),
                  ],
                ),

                // ✨ Glow + sombra
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: esPrimero ? 20 : 10,
                    spreadRadius: esPrimero ? 3 : 1,
                    offset: const Offset(0, 4),
                  ),
                ],

                border: Border.all(color: color.withOpacity(0.8), width: 1.5),
              ),

              child: Center(
                child: Transform.translate(
                  offset: Offset(0, esPrimero ? -8 : 4),
                  child: Image.asset(
                    esPrimero
                        ? 'assets/images/medal_gold.png'
                        : color == const Color(0xFFC0C0C0)
                        ? 'assets/images/medal_silver.png'
                        : 'assets/images/medal_bronze.png',
                    width: esPrimero ? 36 : 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
