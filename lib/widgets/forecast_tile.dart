import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_day.dart';
import '../utils/theme.dart';

/// A glass daily-forecast row that performs a 3D flip on tap, revealing a
/// back face with a slightly larger icon and a min/max range bar.
class ForecastTile extends StatefulWidget {
  final ForecastDay day;
  final bool useFahrenheit;

  const ForecastTile({
    super.key,
    required this.day,
    required this.useFahrenheit,
  });

  @override
  State<ForecastTile> createState() => _ForecastTileState();
}

class _ForecastTileState extends State<ForecastTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  String _formatTemp(double celsius) {
    if (widget.useFahrenheit) {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(0)}°';
    }
    return '${celsius.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final dateLabel = DateFormat.E().add_MMMd().format(day.date);
    final iconUrl = day.iconCode.isNotEmpty
        ? 'https://openweathermap.org/img/wn/${day.iconCode}@2x.png'
        : null;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * math.pi;
          final showBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(day),
                  )
                : _buildFront(day, dateLabel, iconUrl),
          );
        },
      ),
    );
  }

  Widget _buildFront(ForecastDay day, String dateLabel, String? iconUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          iconUrl != null
              ? Image.network(
                  iconUrl,
                  width: 44,
                  height: 44,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.wb_cloudy, color: AppColors.primary),
                )
              : const Icon(Icons.wb_cloudy, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  day.description,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatTemp(day.maxTemp),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTemp(day.minTemp),
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.touch_app_outlined, size: 14, color: AppColors.secondaryText),
        ],
      ),
    );
  }

  Widget _buildBack(ForecastDay day) {
    final range = (day.maxTemp - day.minTemp).clamp(1, 100);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMEEEEd().format(day.date),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day.description.isNotEmpty
                ? day.description[0].toUpperCase() + day.description.substring(1)
                : '',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(_formatTemp(day.minTemp),
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: Colors.white.withValues(alpha: 0.08)),
                        FractionallySizedBox(
                          widthFactor: (range / 30).clamp(0.15, 1.0).toDouble(),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.accent, AppColors.primary],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(_formatTemp(day.maxTemp),
                  style: const TextStyle(color: AppColors.onBackground, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to flip back',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
