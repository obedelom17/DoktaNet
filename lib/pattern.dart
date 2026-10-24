import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Motif « pagne wax » : cercles concentriques et points, répétés en quinconce (filigrane).
class WaxPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;
  const WaxPainter({required this.color, this.opacity = 0.05, this.cell = 120});

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withOpacity(opacity);
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(opacity);
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / (cell * 0.86)).ceil() + 1;
    for (var r = 0; r < rows; r++) {
      final shift = r.isOdd ? cell / 2 : 0.0;
      for (var c = 0; c < cols; c++) {
        final center = Offset(c * cell + shift, r * cell * 0.86);
        canvas.drawCircle(center, cell * 0.40, ring);
        canvas.drawCircle(center, cell * 0.27, ring);
        canvas.drawCircle(center, cell * 0.14, ring);
        canvas.drawCircle(center, cell * 0.05, dot);
      }
    }
  }

  @override
  bool shouldRepaint(WaxPainter old) => old.color != color || old.opacity != opacity || old.cell != cell;
}

/// Grands anneaux concentriques coin de bandeau (corail et blanc), comme un motif de pagne.
class WaxRingsPainter extends CustomPainter {
  final Alignment anchor;
  final double maxRadius;
  const WaxRingsPainter({required this.anchor, this.maxRadius = 300});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset((anchor.x + 1) / 2 * size.width, (anchor.y + 1) / 2 * size.height);
    var k = 0;
    for (var r = 44.0; r <= maxRadius; r += 30) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = k.isEven ? 3.0 : 2.0
        ..color = k.isEven ? cAccent.withOpacity(0.34) : Colors.white.withOpacity(0.16);
      canvas.drawCircle(center, r, p);
      k++;
    }
    canvas.drawCircle(center, 12, Paint()..color = cAccent.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(WaxRingsPainter old) => old.anchor != anchor || old.maxRadius != maxRadius;
}

/// Frise en dents de scie (inspirée des tissages kente), signature visuelle de DoktaNet.
class KentePainter extends CustomPainter {
  const KentePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = cDark);
    const colors = [cAccent, Colors.white, cMint, cDark];
    final w = size.height * 2.3;
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + w / 2, 0)
        ..lineTo(x + w, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i % colors.length]);
      x += w;
      i++;
    }
  }

  @override
  bool shouldRepaint(KentePainter old) => false;
}

class KenteBar extends StatelessWidget {
  final double height;
  const KenteBar({super.key, this.height = 6});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: const CustomPaint(painter: KentePainter()),
      );
}

/// Trois losanges décalés : puce des titres de section.
class DiamondTrio extends StatelessWidget {
  const DiamondTrio({super.key});

  Widget _d(double left, double top, Color c) => Positioned(
        left: left,
        top: top,
        child: Transform.rotate(angle: math.pi / 4, child: Container(width: 8, height: 8, color: c)),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        height: 24,
        child: Stack(children: [_d(2, 8, cAccent), _d(11, 1, cTeal), _d(20, 8, cMid)]),
      );
}
