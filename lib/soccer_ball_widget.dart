import 'package:flutter/material.dart';

class SoccerBallWidget extends StatefulWidget {
  final double size;
  const SoccerBallWidget({super.key, this.size = 60});

  @override
  State<SoccerBallWidget> createState() => _SoccerBallWidgetState();
}

class _SoccerBallWidgetState extends State<SoccerBallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotacion;
  late Animation<double> _rebote;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotacion = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _rebote = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticInOut),
      ),
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
        // Efecto de rebote vertical suave
        final offsetY = ((_rebote.value * 2 - 1).abs() - 0.5) * 8;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.rotate(
            angle: _rotacion.value * 2 * 3.14159,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _SoccerBallPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _SoccerBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Sombra
    final paintSombra = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center + const Offset(3, 3), radius, paintSombra);

    // Esfera blanca base con gradiente
    final paintBase = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white,
          const Color(0xFFE0E0E0),
          const Color(0xFFBDBDBD),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paintBase);

    // Pentágonos negros del balón
    final paintNegro = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;

    // Pentágono central
    _drawPentagono(canvas, center, radius * 0.28, 0, paintNegro);

    // Pentágonos alrededor
    final angulos = [0.0, 1.257, 2.513, 3.77, 5.026];
    for (final angulo in angulos) {
      final x = center.dx + radius * 0.52 * _cos(angulo - 0.3);
      final y = center.dy + radius * 0.52 * _sin(angulo - 0.3);
      _drawPentagono(canvas, Offset(x, y), radius * 0.22, angulo, paintNegro);
    }

    // Brillo superior
    final paintBrillo = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.5,
        colors: [
          Colors.white.withOpacity(0.7),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paintBrillo);

    // Borde
    final paintBorde = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 0.5, paintBorde);
  }

  void _drawPentagono(
    Canvas canvas,
    Offset center,
    double radio,
    double rotacion,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angulo = rotacion + (i * 2 * 3.14159 / 5) - 3.14159 / 2;
      final x = center.dx + radio * _cos(angulo);
      final y = center.dy + radio * _sin(angulo);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angulo) => angulo == 0
      ? 1
      : (angulo == 3.14159 ? -1 : _aproximarCos(angulo));

  double _sin(double angulo) => _aproximarSin(angulo);

  double _aproximarCos(double x) {
    x = x % (2 * 3.14159);
    double resultado = 1;
    double termino = 1;
    for (int i = 1; i <= 10; i++) {
      termino *= -x * x / ((2 * i - 1) * (2 * i));
      resultado += termino;
    }
    return resultado;
  }

  double _aproximarSin(double x) {
    x = x % (2 * 3.14159);
    double resultado = x;
    double termino = x;
    for (int i = 1; i <= 10; i++) {
      termino *= -x * x / ((2 * i) * (2 * i + 1));
      resultado += termino;
    }
    return resultado;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}