import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/weather_visuals.dart';

/// Full-bleed animated background that gives the app its "spatial" feel:
/// a drifting gradient, several depth-layered blurred orbs that float on
/// independent orbits (parallax), and a particle layer for rain/snow/haze.
class AnimatedBackdrop extends StatefulWidget {
  final String condition;
  final bool isDay;
  final Offset parallaxShift; // subtle pointer/scroll-driven offset, -1..1

  const AnimatedBackdrop({
    super.key,
    required this.condition,
    required this.isDay,
    this.parallaxShift = Offset.zero,
  });

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = visualFor(widget.condition, widget.isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: visual.gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Depth layer 1 — slow, large, furthest away.
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              final t = _orbitController.value * 2 * math.pi;
              final dx = math.cos(t) * 40 + widget.parallaxShift.dx * 12;
              final dy = math.sin(t) * 30 + widget.parallaxShift.dy * 12;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: _Orb(
                  color: visual.gradient.last.withValues(alpha: 0.35),
                  size: 320,
                  alignment: const Alignment(-0.7, -0.8),
                ),
              );
            },
          ),
          // Depth layer 2 — medium speed, mid distance.
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              final t = -_orbitController.value * 2 * math.pi * 1.6;
              final dx = math.cos(t) * 55 + widget.parallaxShift.dx * 22;
              final dy = math.sin(t) * 45 + widget.parallaxShift.dy * 22;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: _Orb(
                  color: visual.gradient.first.withValues(alpha: 0.4),
                  size: 260,
                  alignment: const Alignment(0.8, 0.6),
                ),
              );
            },
          ),
          // Depth layer 3 — fastest, nearest, smallest drift radius.
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              final t = _orbitController.value * 2 * math.pi * 2.3;
              final dx = math.cos(t) * 25 + widget.parallaxShift.dx * 34;
              final dy = math.sin(t) * 20 + widget.parallaxShift.dy * 34;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: _Orb(
                  color: visual.gradient[1].withValues(alpha: 0.3),
                  size: 180,
                  alignment: const Alignment(0.1, -0.3),
                ),
              );
            },
          ),
          if (visual.particles != ParticleType.none)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    type: visual.particles,
                  ),
                );
              },
            ),
          // Subtle vignette so foreground glass content stays legible.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Colors.transparent, Color(0x66000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const _Orb({
    required this.color,
    required this.size,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final ParticleType type;
  static final math.Random _rand = math.Random(7);
  static final List<Offset> _seeds = List.generate(
    70,
    (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
  );

  _ParticlePainter({required this.progress, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.55);

    if (type == ParticleType.rain) {
      paint.strokeWidth = 1.6;
      for (final seed in _seeds) {
        final fallProgress = (progress + seed.dx) % 1.0;
        final x = seed.dx * size.width;
        final y = fallProgress * (size.height + 60) - 30;
        canvas.drawLine(
          Offset(x, y),
          Offset(x - 4, y + 16),
          paint,
        );
      }
    } else if (type == ParticleType.snow) {
      for (final seed in _seeds) {
        final fallProgress = (progress * 0.4 + seed.dx) % 1.0;
        final sway = math.sin((progress * 6) + seed.dy * 10) * 10;
        final x = seed.dx * size.width + sway;
        final y = fallProgress * (size.height + 20) - 10;
        canvas.drawCircle(Offset(x, y), 2.2, paint);
      }
    } else if (type == ParticleType.drift) {
      paint.color = Colors.white.withValues(alpha: 0.08);
      for (final seed in _seeds.take(18)) {
        final driftProgress = (progress + seed.dx) % 1.0;
        final x = (driftProgress * (size.width + 200)) - 100;
        final y = seed.dy * size.height;
        canvas.drawCircle(Offset(x, y), 40 + seed.dx * 30, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.type != type;
}
