import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import 'glass_panel.dart';

class CurrentWeatherWidget extends StatefulWidget {
  final Weather weather;
  final bool useFahrenheit;

  const CurrentWeatherWidget({
    super.key,
    required this.weather,
    required this.useFahrenheit,
  });

  @override
  State<CurrentWeatherWidget> createState() => _CurrentWeatherWidgetState();
}

class _CurrentWeatherWidgetState extends State<CurrentWeatherWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  String _formatTemp(double celsius) {
    if (widget.useFahrenheit) {
      final f = celsius * 9 / 5 + 32;
      return '${f.toStringAsFixed(0)}°F';
    }
    return '${celsius.toStringAsFixed(0)}°C';
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.weather;
    final iconUrl = w.iconCode.isNotEmpty
        ? 'https://openweathermap.org/img/wn/${w.iconCode}@4x.png'
        : null;

    return GlassPanel(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Text(
            w.cityName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            w.description.isNotEmpty
                ? w.description[0].toUpperCase() + w.description.substring(1)
                : '',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // 3D-rotating hero icon on a floating orbit.
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, child) {
              final angle = _spinController.value * 2 * math.pi;
              final wobble = math.sin(angle) * 0.18;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateY(wobble)
                  ..rotateX(wobble * 0.4),
                child: child,
              );
            },
            child: iconUrl != null
                ? Image.network(
                    iconUrl,
                    width: 130,
                    height: 130,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.cloud, size: 100, color: AppColors.primary),
                  )
                : const Icon(Icons.cloud, size: 100, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: w.temperature),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              _formatTemp(value),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w200,
                color: AppColors.onBackground,
                height: 1,
              ),
            ),
          ),
          Text(
            'Feels like ${_formatTemp(w.feelsLike)}',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${w.humidity}%',
              ),
              _InfoChip(
                icon: Icons.air_rounded,
                label: 'Wind',
                value: '${w.windSpeed.toStringAsFixed(1)} m/s',
              ),
              _InfoChip(
                icon: Icons.speed_rounded,
                label: 'Pressure',
                value: '${w.pressure} hPa',
              ),
              _InfoChip(
                icon: Icons.wb_twilight_rounded,
                label: 'Sunrise',
                value: DateFormat.Hm().format(w.sunrise),
              ),
              _InfoChip(
                icon: Icons.nights_stay_outlined,
                label: 'Sunset',
                value: DateFormat.Hm().format(w.sunset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
