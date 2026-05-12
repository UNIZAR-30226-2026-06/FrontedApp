import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/carta_model.dart';

enum EstiloCarta { basic, neon, gold, retro }

EstiloCarta estiloCartaDesdePerfil({
  String? id,
  String? nombre,
  String? image,
}) {
  final idNormalizado = id?.trim();
  if (idNormalizado == '2') return EstiloCarta.basic;
  if (idNormalizado == '3') return EstiloCarta.neon;
  if (idNormalizado == '4') return EstiloCarta.gold;
  if (idNormalizado == '5') return EstiloCarta.retro;

  final raw = [
    nombre,
    image,
  ].whereType<String>().join(' ').toLowerCase();

  if (raw.contains('neon')) return EstiloCarta.neon;
  if (raw.contains('gold') || raw.contains('dorado')) return EstiloCarta.gold;
  if (raw.contains('retro')) return EstiloCarta.retro;
  return EstiloCarta.basic;
}

class CartaWidget extends StatefulWidget {
  final Carta carta;
  final VoidCallback? onTap;
  final double width;
  final EstiloCarta estilo;

  const CartaWidget({
    super.key,
    required this.carta,
    this.onTap,
    this.width = 70,
    this.estilo = EstiloCarta.basic,
  });

  @override
  State<CartaWidget> createState() => _CartaWidgetState();
}

class _CartaWidgetState extends State<CartaWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.width * 1.5;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.82, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _CartaPainter(
                  carta: widget.carta,
                  estilo: widget.estilo,
                  tick: _controller.value,
                ),
                child: SizedBox(
                  width: widget.width,
                  height: height,
                  child: _CartaContenido(
                    carta: widget.carta,
                    estilo: widget.estilo,
                    width: widget.width,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CartaReversoWidget extends StatelessWidget {
  final double width;
  final EstiloCarta estilo;

  const CartaReversoWidget({
    super.key,
    this.width = 65,
    this.estilo = EstiloCarta.retro,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CartaReversoPainter(estilo: estilo),
      child: SizedBox(
        width: width,
        height: width * 1.46,
        child: Center(
          child: Transform.rotate(
            angle: -0.7,
            child: Text(
              'UNO',
              style: TextStyle(
                color: const Color(0xFFFFD200),
                fontSize: width * 0.26,
                fontWeight: FontWeight.w900,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaContenido extends StatelessWidget {
  final Carta carta;
  final EstiloCarta estilo;
  final double width;

  const _CartaContenido({
    required this.carta,
    required this.estilo,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final label = _valorCarta(carta);
    final textColor = estilo == EstiloCarta.gold
        ? const Color(0xFF3E2723)
        : Colors.white;

    return Stack(
      children: [
        Positioned(
          top: width * 0.08,
          left: width * 0.12,
          child: _corner(label, textColor),
        ),
        Center(child: _center(label, textColor)),
        Positioned(
          right: width * 0.12,
          bottom: width * 0.08,
          child: Transform.rotate(
            angle: math.pi,
            child: _corner(label, textColor),
          ),
        ),
      ],
    );
  }

  Widget _corner(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: width * 0.23,
        fontWeight: FontWeight.w900,
        height: 1,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
      ),
    );
  }

  Widget _center(String label, Color color) {
    if (carta.valor == CartaValor.reversa) {
      return Icon(
        Icons.compare_arrows_rounded,
        color: color,
        size: width * 0.82,
      );
    }
    if (carta.valor == CartaValor.saltar) {
      return Icon(Icons.block_rounded, color: color, size: width * 0.78);
    }
    if (carta.valor == CartaValor.cambiaColor) {
      return Container(
        width: width * 0.56,
        height: width * 0.56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 4),
          gradient: const SweepGradient(
            colors: [
              Colors.red,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
      );
    }

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: label.length > 2 ? width * 0.42 : width * 0.76,
        fontWeight: FontWeight.w900,
        height: 0.9,
        shadows: const [
          Shadow(color: Colors.black54, blurRadius: 0, offset: Offset(2, 3)),
          Shadow(color: Colors.black38, blurRadius: 8),
        ],
      ),
    );
  }
}

class _CartaPainter extends CustomPainter {
  final Carta carta;
  final EstiloCarta estilo;
  final double tick;

  _CartaPainter({
    required this.carta,
    required this.estilo,
    required this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(estilo == EstiloCarta.retro ? 10 : 14);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    final base = _colorCarta(carta);
    final special = carta.esEspecial;

    canvas.save();
    canvas.clipRRect(rrect);

    if (special && carta.color == CartaColor.especial) {
      _paintVortex(canvas, size);
    } else {
      final paint = Paint()..shader = _gradientFor(base).createShader(rect);
      canvas.drawRRect(rrect, paint);
    }

    if (estilo == EstiloCarta.retro) {
      canvas.drawColor(base, BlendMode.srcOver);
    }

    final ovalPaint = Paint()
      ..color = estilo == EstiloCarta.retro
          ? Colors.white
          : Colors.white.withOpacity(0.16);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.9);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 1.35,
        height: size.height * 0.58,
      ),
      ovalPaint,
    );
    canvas.restore();

    if (estilo == EstiloCarta.gold) {
      final shineX = -size.width + (size.width * 3 * tick);
      final shine = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(shineX, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(shineX, 0, size.width, size.height), shine);
    }

    canvas.restore();

    final borderColor = switch (estilo) {
      EstiloCarta.neon => _neonColor(carta),
      EstiloCarta.gold => Colors.white.withOpacity(0.75),
      EstiloCarta.retro => Colors.white,
      EstiloCarta.basic => base,
    };
    canvas.drawRRect(
      rrect.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = estilo == EstiloCarta.retro ? 5 : 4
        ..color = borderColor,
    );
  }

  void _paintVortex(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide;
    final colors = [
      const Color(0xFFFF2424),
      const Color(0xFFFFAD29),
      const Color(0xFF4ADE80),
      const Color(0xFF3B82F6),
      const Color(0xFFFF2424),
    ];
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tick * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: colors,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.restore();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withOpacity(0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _CartaPainter oldDelegate) {
    return oldDelegate.carta != carta ||
        oldDelegate.estilo != estilo ||
        oldDelegate.tick != tick;
  }
}

class _CartaReversoPainter extends CustomPainter {
  final EstiloCarta estilo;

  _CartaReversoPainter({required this.estilo});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    final fondo = switch (estilo) {
      EstiloCarta.neon => const Color(0xFF050816),
      EstiloCarta.gold => const Color(0xFF5F4300),
      EstiloCarta.retro => const Color(0xFF1A1A1A),
      EstiloCarta.basic => const Color(0xFF111827),
    };
    canvas.drawRRect(rrect, Paint()..color = fondo);

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.75);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 1.35,
        height: size.height * 0.58,
      ),
      Paint()
        ..color = switch (estilo) {
          EstiloCarta.neon => const Color(0xFF00CCFF),
          EstiloCarta.gold => const Color(0xFFFFD54F),
          EstiloCarta.retro => const Color(0xFFD72600),
          EstiloCarta.basic => const Color(0xFFD72600),
        },
    );
    canvas.restore();

    canvas.drawRRect(
      rrect.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = estilo == EstiloCarta.retro ? 3 : 4
        ..color = switch (estilo) {
          EstiloCarta.neon => const Color(0xFF00CCFF),
          EstiloCarta.gold => const Color(0xFFFFF8E1),
          EstiloCarta.retro => const Color(0xFFFDF5E6),
          EstiloCarta.basic => const Color(0xFFFDF5E6),
        },
    );
  }

  @override
  bool shouldRepaint(covariant _CartaReversoPainter oldDelegate) {
    return oldDelegate.estilo != estilo;
  }
}

Color _colorCarta(Carta carta) {
  return switch (carta.color) {
    CartaColor.rojo => const Color(0xFFD72600),
    CartaColor.azul => const Color(0xFF0956BF),
    CartaColor.verde => const Color(0xFF379711),
    CartaColor.amarillo => const Color(0xFFECD407),
    CartaColor.especial => Colors.black,
  };
}

Color _neonColor(Carta carta) {
  return switch (carta.color) {
    CartaColor.rojo => const Color(0xFFFF0033),
    CartaColor.azul => const Color(0xFF00CCFF),
    CartaColor.verde => const Color(0xFF33FF33),
    CartaColor.amarillo => const Color(0xFFFFFF00),
    CartaColor.especial => const Color(0xFF00CCFF),
  };
}

LinearGradient _gradientFor(Color base) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      base.withOpacity(0.95),
      Color.lerp(base, Colors.black, 0.55)!,
      Colors.black,
    ],
  );
}

String _valorCarta(Carta carta) {
  final raw = carta.rawValor.trim();
  if (raw.isNotEmpty && raw != 'null') {
    final normalized = raw.toLowerCase();
    if (normalized == 'reverse') return 'R';
    if (normalized == 'skip') return 'SKIP';
    if (normalized == 'wild') return 'WILD';
    return raw
        .replaceAll('mas', '+')
        .replaceAll('Mas', '+')
        .replaceAll('cambiaColor', 'WILD');
  }

  return switch (carta.valor) {
    CartaValor.cero => '0',
    CartaValor.uno => '1',
    CartaValor.dos => '2',
    CartaValor.tres => '3',
    CartaValor.cuatro => '4',
    CartaValor.cinco => '5',
    CartaValor.seis => '6',
    CartaValor.siete => '7',
    CartaValor.ocho => '8',
    CartaValor.nueve => '9',
    CartaValor.saltar => 'SKIP',
    CartaValor.reversa => 'R',
    CartaValor.masDos => '+2',
    CartaValor.cambiaColor => 'WILD',
    CartaValor.masCuatro => '+4',
  };
}
