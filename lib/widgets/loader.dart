import 'dart:math' as math;
import 'package:flutter/material.dart';

class BrandoLoader extends StatefulWidget {
  const BrandoLoader({super.key, this.size = 80, this.durationSeconds = 2.0});
  final double size;
  final double durationSeconds;

  @override
  State<BrandoLoader> createState() => _BrandoLoaderState();
}

class _BrandoLoaderState extends State<BrandoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.durationSeconds * 1000).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _BrandoPainter(angle: _ctrl.value * 2 * math.pi),
      ),
    );
  }
}

class _BrandoPainter extends CustomPainter {
  const _BrandoPainter({required this.angle});
  final double angle;

  static const _red = Color(0xFFCC1A1A);
  static const _white = Color(0xFFFFFFFF);
  static const _gold = Color(0xFFBF9020);
  static const _goldLight = Color(0xFFD4A830);
  static const _cream = Color(0xFFFFF5DC);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = math.min(cx, cy);

    // 1. Outer red disc
    canvas.drawCircle(Offset(cx, cy), R, Paint()..color = _red);

    // 2. White separator ring
    canvas.drawCircle(Offset(cx, cy), R * 0.855, Paint()..color = _white);

    // 3. Inner red band
    canvas.drawCircle(Offset(cx, cy), R * 0.840, Paint()..color = _red);

    // 4. White inner disc
    canvas.drawCircle(Offset(cx, cy), R * 0.775, Paint()..color = _white);

    // 5. ROTATING SUNBURST
    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: R * 0.770)),
    );
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    _drawSunburst(canvas, R);
    canvas.restore();

    // 8. Red centre disc
    canvas.drawCircle(Offset(cx, cy), R * 0.200, Paint()..color = _red);

    // 9. White thin ring
    canvas.drawCircle(
      Offset(cx, cy),
      R * 0.200,
      Paint()
        ..color = _white
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.014,
    );

    // 10. Letter B
    _drawB(canvas, cx, cy, R);

    // 11. "BRANDO" top arc
    _drawTopArcText(
      canvas: canvas,
      cx: cx,
      cy: cy,
      text: 'BRANDO',
      radius: R * 0.910,
      fontSize: R * 0.158,
    );

    // 12. "GLOBAL TECHNOLOGIES" bottom arc
    _drawBottomArcText(
      canvas: canvas,
      cx: cx,
      cy: cy,
      text: 'GLOBAL TECHNOLOGIES',
      radius: R * 0.900,
      fontSize: R * 0.094,
    );

    // 13. Stars
    _drawStar(canvas, cx - R * 0.590, cy + R * 0.105, R * 0.058);
    _drawStar(canvas, cx + R * 0.590, cy + R * 0.105, R * 0.058);
  }

  void _drawTopArcText({
    required Canvas canvas,
    required double cx,
    required double cy,
    required String text,
    required double radius,
    required double fontSize,
  }) {
    final chars = text.characters.toList();
    final n = chars.length;
    if (n == 0) return;

    const startDeg = 230.0;
    const endDeg = 310.0;
    final startRad = startDeg * math.pi / 180;
    final endRad = endDeg * math.pi / 180;
    final step = (endRad - startRad) / (n - 1);

    final style = TextStyle(
      color: _white,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      fontFamily: 'Georgia',
    );

    for (int i = 0; i < n; i++) {
      final a = startRad + i * step;
      canvas.save();
      canvas.translate(cx + radius * math.cos(a), cy + radius * math.sin(a));
      canvas.rotate(a + math.pi / 2);
      final tp = TextPainter(
        text: TextSpan(text: chars[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _drawBottomArcText({
    required Canvas canvas,
    required double cx,
    required double cy,
    required String text,
    required double radius,
    required double fontSize,
  }) {
    final chars = text.characters.toList().reversed.toList();
    final n = chars.length;
    if (n == 0) return;

    const startDeg = 50.0;
    const endDeg = 130.0;
    final startRad = startDeg * math.pi / 180;
    final endRad = endDeg * math.pi / 180;
    final step = (endRad - startRad) / (n - 1);

    final style = TextStyle(
      color: _white,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      fontFamily: 'Georgia',
    );

    for (int i = 0; i < n; i++) {
      final a = startRad + i * step;
      canvas.save();
      canvas.translate(cx + radius * math.cos(a), cy + radius * math.sin(a));
      canvas.rotate(a - math.pi / 2);
      final tp = TextPainter(
        text: TextSpan(text: chars[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _drawSunburst(Canvas canvas, double R) {
    const int rays = 16;
    final outerTip = R * 0.720;
    final innerHub = R * 0.215;
    final halfAngle = (2 * math.pi / rays) * 0.22;

    final path = Path();
    for (int i = 0; i < rays; i++) {
      final tipA = (2 * math.pi / rays) * i;
      final baseA = tipA + math.pi / rays;
      path
        ..moveTo(outerTip * math.cos(tipA), outerTip * math.sin(tipA))
        ..lineTo(
          innerHub * math.cos(baseA - halfAngle),
          innerHub * math.sin(baseA - halfAngle),
        )
        ..lineTo(
          innerHub * math.cos(baseA + halfAngle),
          innerHub * math.sin(baseA + halfAngle),
        )
        ..close();
    }
    canvas.drawPath(path, Paint()..color = _gold);
    canvas.drawCircle(Offset.zero, innerHub, Paint()..color = _gold);

    final shine = Paint()..color = _goldLight.withOpacity(0.45);
    for (int i = 0; i < rays; i += 2) {
      final tipA = (2 * math.pi / rays) * i;
      final baseA = tipA + math.pi / rays;
      final sp = Path()
        ..moveTo(
          outerTip * 0.92 * math.cos(tipA),
          outerTip * 0.92 * math.sin(tipA),
        )
        ..lineTo(
          innerHub * math.cos(baseA - halfAngle * 0.5),
          innerHub * math.sin(baseA - halfAngle * 0.5),
        )
        ..lineTo(innerHub * math.cos(baseA), innerHub * math.sin(baseA))
        ..close();
      canvas.drawPath(sp, shine);
    }
  }

  void _drawB(Canvas canvas, double cx, double cy, double R) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          color: _white,
          fontSize: R * 0.26,
          fontWeight: FontWeight.w900,
          fontFamily: 'Georgia',
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = -math.pi / 2 + i * 2 * math.pi / 5;
      final inner = outer + math.pi / 5;
      final op = Offset(cx + r * math.cos(outer), cy + r * math.sin(outer));
      final ip = Offset(
        cx + r * 0.40 * math.cos(inner),
        cy + r * 0.40 * math.sin(inner),
      );
      i == 0 ? path.moveTo(op.dx, op.dy) : path.lineTo(op.dx, op.dy);
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _white);
  }

  @override
  bool shouldRepaint(_BrandoPainter old) => old.angle != angle;
}
