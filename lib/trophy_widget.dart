import 'dart:math' as math;
import 'package:flutter/material.dart';

class TrophyWidget extends StatefulWidget {
  final double size;
  const TrophyWidget({super.key, this.size = 100});

  @override
  State<TrophyWidget> createState() => _TrophyWidgetState();
}

class _TrophyWidgetState extends State<TrophyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brillo;
  late Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _brillo = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _escala = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _escala.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.25),
            painter: _TrophyPainter(brillo: _brillo.value),
          ),
        );
      },
    );
  }
}

class _TrophyPainter extends CustomPainter {
  final double brillo;
  _TrophyPainter({required this.brillo});

  static const Color _goldDark   = Color(0xFFA07800);
  static const Color _goldMid    = Color(0xFFD4AF37);
  static const Color _goldLight  = Color(0xFFF5D76E);
  static const Color _goldBright = Color(0xFFFFEE88);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── AURA / GLOW ───────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.40),
        width: w * 0.85,
        height: h * 0.58,
      ),
      Paint()
        ..color = _goldMid.withOpacity(0.18 * brillo)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // ── HANDLES ───────────────────────────────────────────────────────────
    _drawHandle(canvas, w, h, isLeft: true);
    _drawHandle(canvas, w, h, isLeft: false);

    // ── COPA ──────────────────────────────────────────────────────────────
    final cupPath = Path()
      ..moveTo(w * 0.17, h * 0.07)
      ..lineTo(w * 0.83, h * 0.07)
      ..quadraticBezierTo(w * 0.90, h * 0.28, w * 0.79, h * 0.42)
      ..quadraticBezierTo(w * 0.68, h * 0.53, w * 0.58, h * 0.56)
      ..lineTo(w * 0.58, h * 0.61)
      ..lineTo(w * 0.42, h * 0.61)
      ..lineTo(w * 0.42, h * 0.56)
      ..quadraticBezierTo(w * 0.32, h * 0.53, w * 0.21, h * 0.42)
      ..quadraticBezierTo(w * 0.10, h * 0.28, w * 0.17, h * 0.07)
      ..close();

    canvas.drawPath(
      cupPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _goldDark,
            _goldMid,
            _goldLight.withOpacity(0.85 + brillo * 0.15),
            _goldMid,
            _goldDark,
          ],
          stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Borde superior de la copa
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = _goldBright.withOpacity(0.45 + brillo * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── BRILLO INTERNO (shine) ────────────────────────────────────────────
    final shinePath = Path()
      ..moveTo(w * 0.27, h * 0.09)
      ..quadraticBezierTo(w * 0.31, h * 0.27, w * 0.37, h * 0.36);
    canvas.drawPath(
      shinePath,
      Paint()
        ..color = Colors.white.withOpacity(0.22 * brillo)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // ── STEM ──────────────────────────────────────────────────────────────
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.61, w * 0.16, h * 0.17),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      stemRect,
      Paint()
        ..shader = LinearGradient(
          colors: [_goldDark, _goldMid, _goldLight, _goldMid, _goldDark],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(w * 0.42, 0, w * 0.16, h)),
    );

    // ── BASE SHADOW ───────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.81, w * 0.72, h * 0.14),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // ── BASE ──────────────────────────────────────────────────────────────
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.78, w * 0.72, h * 0.14),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      baseRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_goldMid, _goldDark, _goldDark.withOpacity(0.75)],
        ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.14)),
    );

    // Línea de brillo en la base
    canvas.drawLine(
      Offset(w * 0.18, h * 0.80),
      Offset(w * 0.82, h * 0.80),
      Paint()
        ..color = _goldBright.withOpacity(0.4 + brillo * 0.35)
        ..strokeWidth = 1.0,
    );

    // ── ESTRELLA SUPERIOR ─────────────────────────────────────────────────
    _drawStar(
      canvas,
      Offset(w * 0.5, h * 0.025),
      w * 0.075,
      _goldBright.withOpacity(0.65 + brillo * 0.35),
    );
  }

  void _drawHandle(Canvas canvas, double w, double h, {required bool isLeft}) {
    final double xStart = isLeft ? w * 0.17 : w * 0.83;
    final double xCtrl  = isLeft ? w * 0.01 : w * 0.99;
    final double xEnd   = isLeft ? w * 0.21 : w * 0.79;

    final path = Path()
      ..moveTo(xStart, h * 0.11)
      ..cubicTo(xCtrl, h * 0.11, xCtrl, h * 0.39, xEnd, h * 0.39);

    canvas.drawPath(
      path,
      Paint()
        ..color = _goldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.058
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _goldLight.withOpacity(brillo * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.42;
      final p = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter old) => old.brillo != brillo;
}