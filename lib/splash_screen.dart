import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Controladores ─────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textoCtrl;
  late final AnimationController _dotsCtrl;

  // ── Logo: fade + scale ────────────────────────────────────────────────────
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // ── Título: fade + slide up ───────────────────────────────────────────────
  late final Animation<double> _textoFade;
  late final Animation<Offset> _textoSlide;

  @override
  void initState() {
    super.initState();

    // ── Logo (arranca de inmediato, dura 800ms) ────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // ── Texto (arranca 400ms después, dura 600ms) ──────────────────────────
    _textoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textoCtrl, curve: Curves.easeOut),
    );
    _textoSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textoCtrl, curve: Curves.easeOutCubic),
    );

    // ── Dots (arranca 800ms después, dura 900ms, repite) ───────────────────
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // ── Secuencia de arranque ──────────────────────────────────────────────
    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textoCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _dotsCtrl.repeat();
    });

    // ── Navegar al HomePage después de 2.6s ───────────────────────────────
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textoCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0F2E),
              Color(0xFF0D1333),
              Color(0xFF0A0F2E),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Relleno superior (40% de la pantalla) ───────────────────
              const Spacer(flex: 4),

              // ── Trophy animado ───────────────────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/images/trophy.png',
                    width: 140,
                    height: 140,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Título animado ───────────────────────────────────────────
              FadeTransition(
                opacity: _textoFade,
                child: SlideTransition(
                  position: _textoSlide,
                  child: Column(
                    children: [
                      // Línea decorativa superior
                      _LineaDorada(),

                      const SizedBox(height: 14),

                      Text(
                        AppStrings.appNombre,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dorado,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '2026',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.doradoClaro,
                          letterSpacing: 8,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Línea decorativa inferior
                      _LineaDorada(),
                    ],
                  ),
                ),
              ),

              // ── Relleno central ──────────────────────────────────────────
              const Spacer(flex: 3),

              // ── Dots de carga ────────────────────────────────────────────
              FadeTransition(
                opacity: _textoFade,   // aparecen junto al texto
                child: _LoadingDots(controller: _dotsCtrl),
              ),

              // ── Relleno inferior ─────────────────────────────────────────
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget: líneas doradas decorativas ────────────────────────────────────────

class _LineaDorada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _segmento(40, 0.15),
        _segmento(20, 0.35),
        _segmento(8,  0.7),
        const SizedBox(width: 8),
        // Pelota central
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.dorado,
          ),
        ),
        const SizedBox(width: 8),
        _segmento(8,  0.7),
        _segmento(20, 0.35),
        _segmento(40, 0.15),
      ],
    );
  }

  Widget _segmento(double ancho, double opacidad) {
    return Container(
      width: ancho,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.dorado.withOpacity(opacidad),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ── Widget: tres puntos con pulso secuencial ───────────────────────────────────

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Cada dot tiene un intervalo distinto dentro del ciclo de 900ms
    final delays = [0.0, 0.33, 0.66];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final anim = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.35, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.35)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: ConstantTween(0.35),
            weight: 40,
          ),
        ]).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(delays[i], (delays[i] + 0.6).clamp(0.0, 1.0)),
          ),
        );

        return AnimatedBuilder(
          animation: anim,
          builder: (_, __) => Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dorado.withOpacity(anim.value),
            ),
          ),
        );
      }),
    );
  }
}