import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A frosted glass card that gently tilts in 3D toward the user's drag/hover,
/// giving panels a sense of physical depth ("spatial" UI).
class GlassPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool interactive3D;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 28,
    this.interactive3D = true,
  });

  @override
  State<GlassPanel> createState() => _GlassPanelState();
}

class _GlassPanelState extends State<GlassPanel>
    with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;

  void _updateTilt(Offset localPosition, Size size) {
    if (!widget.interactive3D) return;
    final normalizedX = (localPosition.dx / size.width) - 0.5; // -0.5..0.5
    final normalizedY = (localPosition.dy / size.height) - 0.5;
    setState(() {
      _tiltY = normalizedX * 0.12; // rotateY responds to horizontal drag
      _tiltX = -normalizedY * 0.12; // rotateX responds to vertical drag
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) => _updateTilt(
            details.localPosition,
            Size(constraints.maxWidth, constraints.maxHeight),
          ),
          onPanEnd: (_) => _resetTilt(),
          onPanCancel: _resetTilt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: widget.margin,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016) // perspective
              ..rotateX(_tiltX)
              ..rotateY(_tiltY),
            transformAlignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppColors.glassHighlight,
                        blurRadius: 1,
                        spreadRadius: -1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
