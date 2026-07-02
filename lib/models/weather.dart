class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String condition; // e.g. "Clear", "Rain", "Clouds", "Snow"
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String iconCode;
  final DateTime sunrise;
  final DateTime sunset;
  final bool isDay;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    required this.isDay,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final cityName = json['name'] as String;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.isNotEmpty ? weatherList[0] : null;
    final timezoneOffsetSeconds = (json['timezone'] as num?)?.toInt() ?? 0;

    DateTime toLocalStationTime(num? unixSeconds) {
      if (unixSeconds == null) return DateTime.now();
      final utc = DateTime.fromMillisecondsSinceEpoch(
        unixSeconds.toInt() * 1000,
        isUtc: true,
      );
      return utc.add(Duration(seconds: timezoneOffsetSeconds));
    }

    final iconCode = weather != null ? (weather['icon'] as String) : '';

    return Weather(
      cityName: cityName,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num?)?.toDouble() ??
          (main['temp'] as num).toDouble(),
      description: weather != null ? (weather['description'] as String) : '',
      condition: weather != null ? (weather['main'] as String) : 'Clear',
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: wind.containsKey('speed')
          ? (wind['speed'] as num).toDouble()
          : 0.0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      iconCode: iconCode,
      sunrise: toLocalStationTime(sys['sunrise'] as num?),
      sunset: toLocalStationTime(sys['sunset'] as num?),
      // OpenWeatherMap icon codes end in 'd' (day) or 'n' (night)
      isDay: iconCode.endsWith('d'),
    );
  }
}
