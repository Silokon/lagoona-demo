import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data.dart';

/// Иллюстрация купальника: рисуется кодом, без фото, поэтому любой цвет и узор.
class SwimArt extends StatelessWidget {
  final SwimType type;
  final ColorVariant variant;
  final double radius;
  final bool showBubbles;

  const SwimArt({
    super.key,
    required this.type,
    required this.variant,
    this.radius = 20,
    this.showBubbles = true,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = variant.main;
    final top = Color.lerp(base, dark ? const Color(0xFF0E1A24) : Colors.white, dark ? 0.72 : 0.78)!;
    final bottom = Color.lerp(variant.accent, dark ? const Color(0xFF0E1A24) : Colors.white, dark ? 0.65 : 0.62)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [top, bottom],
          ),
        ),
        child: CustomPaint(
          painter: _SwimPainter(type, variant, showBubbles, dark),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SwimPainter extends CustomPainter {
  final SwimType type;
  final ColorVariant v;
  final bool bubbles;
  final bool dark;
  _SwimPainter(this.type, this.v, this.bubbles, this.dark);

  static const _w = 100.0;
  static const _h = 112.0;

  @override
  void paint(Canvas canvas, Size size) {
    // на первом кадре размер бывает нулевым: без этой проверки цикл волны бесконечен
    if (size.width < 1 || size.height < 1) return;
    if (bubbles) _paintBackdrop(canvas, size);

    final scale = math.min(size.width / _w, size.height / _h) * 0.78;
    final dx = (size.width - _w * scale) / 2;
    final dy = (size.height - _h * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final parts = _shape();
    // мягкая тень под вещью
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final p in parts) {
      canvas.drawPath(p.shift(const Offset(2, 4)), shadow);
    }

    for (final p in parts) {
      canvas.drawPath(p, Paint()..color = v.main);
      canvas.save();
      canvas.clipPath(p);
      _paintPrint(canvas, p.getBounds());
      _paintSheen(canvas, p.getBounds());
      canvas.restore();
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Color.lerp(v.main, Colors.black, 0.25)!,
      );
    }
    _paintStrings(canvas);
    canvas.restore();
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final rnd = math.Random(v.name.hashCode ^ type.index);
    final c = Paint()..color = Colors.white.withValues(alpha: dark ? 0.06 : 0.35);
    for (var i = 0; i < 6; i++) {
      final r = size.shortestSide * (0.04 + rnd.nextDouble() * 0.09);
      canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), r, c);
    }
    // волна внизу
    final wave = Path()..moveTo(0, size.height * 0.86);
    for (var x = 0.0; x <= size.width; x += size.width / 40) {
      wave.lineTo(x, size.height * 0.86 + math.sin(x / size.width * math.pi * 4) * size.height * 0.025);
    }
    wave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave, Paint()..color = Colors.white.withValues(alpha: dark ? 0.05 : 0.28));
  }

  List<Path> _shape() {
    switch (type) {
      case SwimType.onePiece:
        return [_onePiece()];
      case SwimType.monokini:
        final body = _onePiece();
        final cuts = Path()
          ..addOval(const Rect.fromLTWH(27, 46, 16, 20))
          ..addOval(const Rect.fromLTWH(57, 46, 16, 20));
        return [Path.combine(PathOperation.difference, body, cuts)];
      case SwimType.bikini:
        final left = Path()
          ..moveTo(31, 16)
          ..lineTo(48, 42)
          ..quadraticBezierTo(36, 47, 23, 44)
          ..quadraticBezierTo(24, 28, 31, 16)
          ..close();
        final right = Path()
          ..moveTo(69, 16)
          ..lineTo(52, 42)
          ..quadraticBezierTo(64, 47, 77, 44)
          ..quadraticBezierTo(76, 28, 69, 16)
          ..close();
        final bottom = Path()
          ..moveTo(22, 70)
          ..quadraticBezierTo(50, 76, 78, 70)
          ..quadraticBezierTo(70, 88, 56, 102)
          ..lineTo(44, 102)
          ..quadraticBezierTo(30, 88, 22, 70)
          ..close();
        return [left, right, bottom];
      case SwimType.tankini:
        final top = Path()
          ..moveTo(31, 8)
          ..lineTo(38, 8)
          ..quadraticBezierTo(50, 28, 62, 8)
          ..lineTo(69, 8)
          ..quadraticBezierTo(74, 30, 76, 62)
          ..quadraticBezierTo(50, 68, 24, 62)
          ..quadraticBezierTo(26, 30, 31, 8)
          ..close();
        final shorts = Path()
          ..moveTo(25, 70)
          ..quadraticBezierTo(50, 74, 75, 70)
          ..lineTo(78, 104)
          ..lineTo(55, 104)
          ..lineTo(50, 92)
          ..lineTo(45, 104)
          ..lineTo(22, 104)
          ..close();
        return [top, shorts];
      case SwimType.sport:
        return [
          Path()
            ..moveTo(33, 6)
            ..lineTo(41, 6)
            ..quadraticBezierTo(50, 20, 59, 6)
            ..lineTo(67, 6)
            ..quadraticBezierTo(74, 22, 72, 40)
            ..quadraticBezierTo(70, 56, 66, 70)
            ..lineTo(73, 98)
            ..quadraticBezierTo(60, 100, 54, 108)
            ..lineTo(46, 108)
            ..quadraticBezierTo(40, 100, 27, 98)
            ..lineTo(34, 70)
            ..quadraticBezierTo(30, 56, 28, 40)
            ..quadraticBezierTo(26, 22, 33, 6)
            ..close()
        ];
      case SwimType.pareo:
        return [
          Path()
            ..moveTo(18, 22)
            ..quadraticBezierTo(50, 14, 82, 22)
            ..quadraticBezierTo(88, 64, 72, 106)
            ..quadraticBezierTo(50, 100, 28, 106)
            ..quadraticBezierTo(12, 64, 18, 22)
            ..close()
        ];
    }
  }

  Path _onePiece() => Path()
    ..moveTo(31, 6)
    ..lineTo(38, 6)
    ..quadraticBezierTo(42, 30, 50, 36)
    ..quadraticBezierTo(58, 30, 62, 6)
    ..lineTo(69, 6)
    ..quadraticBezierTo(73, 24, 71, 40)
    ..quadraticBezierTo(69, 58, 66, 70)
    ..quadraticBezierTo(72, 84, 78, 92)
    ..quadraticBezierTo(62, 96, 55, 108)
    ..lineTo(45, 108)
    ..quadraticBezierTo(38, 96, 22, 92)
    ..quadraticBezierTo(28, 84, 34, 70)
    ..quadraticBezierTo(31, 58, 29, 40)
    ..quadraticBezierTo(27, 24, 31, 6)
    ..close();

  void _paintPrint(Canvas canvas, Rect b) {
    final p = Paint()..color = v.accent;
    switch (v.pattern) {
      case Print.solid:
        // контрастная окантовка
        canvas.drawRect(Rect.fromLTWH(b.left, b.top, b.width, 3), p);
        break;
      case Print.stripes:
        for (var y = b.top; y < b.bottom; y += 9) {
          canvas.drawRect(Rect.fromLTWH(b.left, y, b.width, 4), p);
        }
        break;
      case Print.dots:
        var row = 0;
        for (var y = b.top + 3; y < b.bottom; y += 8) {
          for (var x = b.left + (row.isEven ? 3 : 7); x < b.right; x += 8) {
            canvas.drawCircle(Offset(x, y), 1.9, p);
          }
          row++;
        }
        break;
      case Print.tropic:
        final rnd = math.Random(7);
        final leaf = Paint()..color = v.accent.withValues(alpha: 0.9);
        final vein = Paint()
          ..color = Color.lerp(v.accent, Colors.black, 0.3)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        for (var i = 0; i < 16; i++) {
          final c = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(rnd.nextDouble() * math.pi);
          canvas.drawOval(const Rect.fromLTWH(-7, -3, 14, 6), leaf);
          canvas.drawLine(const Offset(-6, 0), const Offset(6, 0), vein);
          canvas.restore();
        }
        break;
      case Print.waves:
        final s = Paint()
          ..color = v.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        for (var y = b.top + 4; y < b.bottom; y += 10) {
          final w = Path()..moveTo(b.left, y);
          for (var x = b.left; x <= b.right; x += 2) {
            w.lineTo(x, y + math.sin((x - b.left) / 5) * 2.2);
          }
          canvas.drawPath(w, s);
        }
        break;
    }
  }

  void _paintSheen(Canvas canvas, Rect b) {
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.18),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(b);
    canvas.drawRect(b, sheen);
  }

  void _paintStrings(Canvas canvas) {
    final s = Paint()
      ..color = Color.lerp(v.main, Colors.black, 0.2)!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    switch (type) {
      case SwimType.bikini:
        canvas.drawPath(
            Path()
              ..moveTo(31, 16)
              ..quadraticBezierTo(40, 2, 50, 4)
              ..quadraticBezierTo(60, 2, 69, 16),
            s);
        canvas.drawLine(const Offset(23, 44), const Offset(14, 46), s);
        canvas.drawLine(const Offset(77, 44), const Offset(86, 46), s);
        canvas.drawLine(const Offset(22, 70), const Offset(14, 78), s);
        canvas.drawLine(const Offset(78, 70), const Offset(86, 78), s);
        break;
      case SwimType.pareo:
        canvas.drawCircle(const Offset(50, 19), 5, Paint()..color = v.accent);
        canvas.drawCircle(const Offset(50, 19), 5, s);
        for (var x = 30.0; x <= 70; x += 4) {
          canvas.drawLine(Offset(x, 104), Offset(x, 110), s);
        }
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SwimPainter old) =>
      old.type != type || old.v != v || old.dark != dark || old.bubbles != bubbles;
}

/// Мини-график истории цены.
class PriceSparkline extends StatelessWidget {
  final List<int> values;
  final Color color;
  const PriceSparkline({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SparkPainter(values, color, Theme.of(context).colorScheme.onSurfaceVariant),
        size: Size.infinite,
      );
}

class _SparkPainter extends CustomPainter {
  final List<int> v;
  final Color color;
  final Color label;
  _SparkPainter(this.v, this.color, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = v.reduce(math.max).toDouble();
    final minV = v.reduce(math.min).toDouble();
    final span = (maxV - minV) == 0 ? 1 : maxV - minV;
    Offset pt(int i) => Offset(
          i / (v.length - 1) * size.width,
          8 + (1 - (v[i] - minV) / span) * (size.height - 16),
        );
    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < v.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(pt(v.length - 1), 4.5, Paint()..color = color);
    canvas.drawCircle(pt(v.length - 1), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.v != v || old.color != color;
}

/// Стилизованная карта с магазинами (без внешних карт и ключей).
class StoresMap extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const StoresMap({super.key, required this.selected, required this.onSelect});

  static const _spots = [
    Offset(0.30, 0.38),
    Offset(0.62, 0.28),
    Offset(0.74, 0.62),
    Offset(0.22, 0.72),
    Offset(0.50, 0.82),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, c) {
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter(dark))),
        // «Вы здесь»
        Positioned(
          left: c.maxWidth * 0.46 - 11,
          top: c.maxHeight * 0.52 - 11,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF00B4D8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: const Color(0xFF00B4D8).withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 6)],
            ),
          ),
        ),
        for (var i = 0; i < stores.length; i++)
          Positioned(
            left: c.maxWidth * _spots[i].dx - 18,
            top: c.maxHeight * _spots[i].dy - 40,
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedScale(
                scale: i == selected ? 1.25 : 1,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.location_on_rounded, size: 40, color: stores[i].color, shadows: const [Shadow(blurRadius: 6, color: Colors.black26)]),
              ),
            ),
          ),
      ]);
    });
  }
}

class _MapPainter extends CustomPainter {
  final bool dark;
  _MapPainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final land = dark ? const Color(0xFF1C2A36) : const Color(0xFFEFF6F1);
    final park = dark ? const Color(0xFF1F3A33) : const Color(0xFFCDEFD9);
    final sea = dark ? const Color(0xFF123047) : const Color(0xFFBDE8F5);
    final road = dark ? const Color(0xFF2E4253) : Colors.white;
    canvas.drawRect(Offset.zero & size, Paint()..color = land);
    // море справа снизу
    final seaPath = Path()
      ..moveTo(size.width, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.55, size.width * 0.9, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(seaPath, Paint()..color = sea);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.06, size.height * 0.08, size.width * 0.22, size.height * 0.2), const Radius.circular(18)),
        Paint()..color = park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.55, size.height * 0.45, size.width * 0.14, size.height * 0.16), const Radius.circular(14)),
        Paint()..color = park);
    final r = Paint()
      ..color = road
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.52), Offset(size.width, size.height * 0.45), r);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.4, size.height), r);
    canvas.drawLine(Offset(size.width * 0.05, size.height * 0.9), Offset(size.width * 0.8, size.height * 0.15), r..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.dark != dark;
}
