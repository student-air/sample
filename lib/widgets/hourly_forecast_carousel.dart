import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hourly_forecast.dart';
import '../utils/theme.dart';

/// A horizontally scrolling row of hourly forecast tiles that scale and
/// tilt in 3D based on their distance from the viewport center, producing
/// a carousel-in-space feel.
class HourlyForecastCarousel extends StatefulWidget {
  final List<HourlyForecast> hours;
  final bool useFahrenheit;

  const HourlyForecastCarousel({
    super.key,
    required this.hours,
    required this.useFahrenheit,
  });

  @override
  State<HourlyForecastCarousel> createState() =>
      _HourlyForecastCarouselState();
}

class _HourlyForecastCarouselState extends State<HourlyForecastCarousel> {
  final ScrollController _controller = ScrollController();
  double _offset = 0;

  static const double _itemWidth = 92;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _offset = _controller.offset);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTemp(double celsius) {
    if (widget.useFahrenheit) {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(0)}°';
    }
    return '${celsius.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hours.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 168,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.hours.length,
        itemBuilder: (context, index) {
          final hour = widget.hours[index];
          final itemCenter = index * _itemWidth + _itemWidth / 2;
          final viewportCenter = _offset + (MediaQuery.of(context).size.width / 2);
          final distance = (itemCenter - viewportCenter).abs();
          final normalized = (distance / 260).clamp(0.0, 1.0);
          final scale = 1.0 - normalized * 0.18;
          final angle = (itemCenter - viewportCenter) / 900;
          final iconUrl = hour.iconCode.isNotEmpty
              ? 'https://openweathermap.org/img/wn/${hour.iconCode}@2x.png'
              : null;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(angle)
              ..scale(scale),
            child: Opacity(
              opacity: 1.0 - normalized * 0.35,
              child: Container(
                width: _itemWidth - 12,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.Hm().format(hour.time),
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    iconUrl != null
                        ? Image.network(
                            iconUrl,
                            width: 40,
                            height: 40,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.cloud, size: 32, color: AppColors.primary),
                          )
                        : const Icon(Icons.cloud, size: 32, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      _formatTemp(hour.temp),
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (hour.pop > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.water_drop, size: 10, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            '${hour.pop}%',
                            style: const TextStyle(color: AppColors.accent, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
