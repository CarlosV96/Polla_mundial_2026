import 'package:flutter/material.dart';
import 'app_colors.dart';

class PodiumWidget extends StatefulWidget {
  final String? primerNombre;
  final String? segundoNombre;
  final String? tercerNombre;
  final int primerPuntos;
  final int segundoPuntos;
  final int tercerPuntos;

  const PodiumWidget({
    super.key,
    this.primerNombre,
    this.segundoNombre,
    this.tercerNombre,
    this.primerPuntos = 0,
    this.segundoPuntos = 0,
    this.tercerPuntos = 0,
  });

  @override
  State<PodiumWidget> createState() => _PodiumWidgetState();
}

class _PodiumWidgetState extends State<PodiumWidget>
    with TickerProviderStateMixin {
  late AnimationController _controladorEntrada;
  late AnimationController _controladorBrillo;

  late Animation<double> _animSegundo;
  late Animation<double> _animPrimero;
  late Animation<double> _animTercero;
  late Animation<double> _animBrillo;

  @override
  void initState() {
    super.initState();

    // Controlador de entrada con stagger
    _controladorEntrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Controlador de brillo continuo
    _controladorBrillo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Animaciones escalonadas — primero 2do, luego 1ro, luego 3ro
    _animSegundo = CurvedAnimation(
      parent: _controladorEntrada,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _animPrimero = CurvedAnimation(
      parent: _controladorEntrada,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    );
    _animTercero = CurvedAnimation(
      parent: _controladorEntrada,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    );

    _animBrillo = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controladorBrillo, curve: Curves.easeInOut),
    );

    // Iniciar animación de entrada
    _controladorEntrada.forward();
  }

  @override
  void dispose() {
    _controladorEntrada.dispose();
    _controladorBrillo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controladorEntrada, _controladorBrillo]),
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 2do LUGAR ---
              _buildPodiumColumn(
                nombre: widget.segundoNombre ?? "-",
                puntos: widget.segundoPuntos,
                altura: 100,
                color: const Color(0xFFC0C0C0),
                emoji: "🥈",
                puesto: "2",
                animacion: _animSegundo,
                brillo: _animBrillo.value,
              ),

              const SizedBox(width: 8),

              // --- 1er LUGAR ---
              _buildPodiumColumn(
                nombre: widget.primerNombre ?? "-",
                puntos: widget.primerPuntos,
                altura: 140,
                color: const Color(0xFFFFD700),
                emoji: "🥇",
                puesto: "1",
                animacion: _animPrimero,
                brillo: _animBrillo.value,
                esPrimero: true,
              ),

              const SizedBox(width: 8),

              // --- 3er LUGAR ---
              _buildPodiumColumn(
                nombre: widget.tercerNombre ?? "-",
                puntos: widget.tercerPuntos,
                altura: 75,
                color: const Color(0xFFCD7F32),
                emoji: "🥉",
                puesto: "3",
                animacion: _animTercero,
                brillo: _animBrillo.value,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodiumColumn({
    required String nombre,
    required int puntos,
    required double altura,
    required Color color,
    required String emoji,
    required String puesto,
    required Animation<double> animacion,
    required double brillo,
    bool esPrimero = false,
  }) {
    return Transform.scale(
      scale: animacion.value,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: esPrimero ? 110 : 95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Avatar con emoji
            if (esPrimero)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(brillo * 0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  "👑",
                  style: TextStyle(fontSize: esPrimero ? 22 : 0),
                ),
              ),

            const SizedBox(height: 4),

            // Nombre
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: esPrimero ? 13 : 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textoBlanco,
              ),
            ),

            const SizedBox(height: 2),

            // Puntos
            Text(
              "$puntos pts",
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Bloque del podio con efecto 3D
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspectiva 3D
                ..rotateX(-0.15),       // Inclinación 3D
              alignment: Alignment.bottomCenter,
              child: Container(
                height: altura,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.9),
                      color.withOpacity(0.5),
                      color.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(brillo * 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(
                    color: color.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: esPrimero ? 32 : 26),
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