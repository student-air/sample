import 'package:flutter/material.dart';

enum ParticleType { none, rain, snow, drift }

class WeatherVisual {
  final List<Color> gradient;
  final IconData icon;
  final ParticleType particles;

  const WeatherVisual({
    required this.gradient,
    required this.icon,
    required this.particles,
  });
}

/// Maps an OpenWeatherMap `condition` (json['weather'][0]['main']) plus
/// day/night flag to a background gradient, hero icon, and particle style
/// used to drive the animated spatial backdrop.
WeatherVisual visualFor(String condition, bool isDay) {
  switch (condition) {
    case 'Clear':
      return isDay
          ? const WeatherVisual(
              gradient: [Color(0xFF2E6BFF), Color(0xFF6FB1FF), Color(0xFFFFD98A)],
              icon: Icons.wb_sunny_rounded,
              particles: ParticleType.none,
            )
          : const WeatherVisual(
              gradient: [Color(0xFF03040F), Color(0xFF0E1A3D), Color(0xFF243B7A)],
              icon: Icons.nightlight_round,
              particles: ParticleType.drift,
            );
    case 'Clouds':
      return WeatherVisual(
        gradient: isDay
            ? const [Color(0xFF5C6B8A), Color(0xFF8C9BC0), Color(0xFFC7D2EA)]
            : const [Color(0xFF0B0F1F), Color(0xFF232B47), Color(0xFF394770)],
        icon: Icons.cloud_rounded,
        particles: ParticleType.drift,
      );
    case 'Rain':
    case 'Drizzle':
      return const WeatherVisual(
        gradient: [Color(0xFF0D1524), Color(0xFF1D3153), Color(0xFF3A5C86)],
        icon: Icons.water_drop_rounded,
        particles: ParticleType.rain,
      );
    case 'Thunderstorm':
      return const WeatherVisual(
        gradient: [Color(0xFF07040F), Color(0xFF1B1330), Color(0xFF3B2E63)],
        icon: Icons.bolt_rounded,
        particles: ParticleType.rain,
      );
    case 'Snow':
      return const WeatherVisual(
        gradient: [Color(0xFF1B2338), Color(0xFF3B4A6B), Color(0xFFAFC3E0)],
        icon: Icons.ac_unit_rounded,
        particles: ParticleType.snow,
      );
    case 'Mist':
    case 'Fog':
    case 'Haze':
      return const WeatherVisual(
        gradient: [Color(0xFF232837), Color(0xFF4A5164), Color(0xFF7C8497)],
        icon: Icons.blur_on_rounded,
        particles: ParticleType.drift,
      );
    default:
      return const WeatherVisual(
        gradient: [Color(0xFF060A18), Color(0xFF0E1530), Color(0xFF1D2A55)],
        icon: Icons.cloud_queue_rounded,
        particles: ParticleType.drift,
      );
  }
}
