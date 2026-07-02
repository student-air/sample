import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast_day.dart';
import '../models/hourly_forecast.dart';
import '../utils/constants.dart';

class WeatherService {
  Future<Weather> fetchCurrentWeather(String city) async {
    final url = Uri.parse(
      '$kBaseWeatherUrl?q=$city&appid=$kOpenWeatherMapApiKey&units=metric',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Weather.fromJson(data);
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to fetch weather'));
    }
  }

  /// Returns the next [maxHours] worth of 3-hour-step forecast entries
  /// (defaults to 24 hours / 8 entries) for the hourly carousel.
  Future<List<HourlyForecast>> fetchHourlyForecast(
    String city, {
    int maxEntries = 8,
  }) async {
    final url = Uri.parse(
      '$kBaseForecastUrl?q=$city&appid=$kOpenWeatherMapApiKey&units=metric',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to fetch hourly forecast'));
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>;
    final result = <HourlyForecast>[];
    for (var item in list.take(maxEntries)) {
      final main = item['main'] as Map<String, dynamic>;
      final weatherList = item['weather'] as List<dynamic>;
      final w = weatherList.isNotEmpty ? weatherList[0] : null;
      final dtTxt = item['dt_txt'] as String;
      final time = DateTime.parse(dtTxt);
      final pop = ((item['pop'] as num?) ?? 0).toDouble();
      result.add(
        HourlyForecast(
          time: time,
          temp: (main['temp'] as num).toDouble(),
          description: w != null ? (w['description'] as String) : '',
          iconCode: w != null ? (w['icon'] as String) : '',
          pop: (pop * 100).round(),
        ),
      );
    }
    return result;
  }

  /// Returns up to [days] daily summaries built from the 5-day / 3-hour API.
  Future<List<ForecastDay>> fetchDailyForecast(String city, {int days = 5}) async {
    final url = Uri.parse(
      '$kBaseForecastUrl?q=$city&appid=$kOpenWeatherMapApiKey&units=metric',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>;
      // Group by date string (YYYY-MM-DD) using dt_txt
      final Map<String, List<dynamic>> byDate = {};
      for (var item in list) {
        final dtTxt = item['dt_txt'] as String; // e.g. "2025-11-20 12:00:00"
        final dateStr = dtTxt.split(' ')[0];
        byDate.putIfAbsent(dateStr, () => []).add(item);
      }
      final dates = byDate.keys.toList();
      if (dates.isEmpty) throw Exception('No forecast data available');

      final result = <ForecastDay>[];
      final count = dates.length >= days ? days : dates.length;
      for (int i = 0; i < count; i++) {
        final dateKey = dates[i];
        final dayItems = byDate[dateKey]!;
        double minTemp = double.infinity;
        double maxTemp = -double.infinity;
        final Map<String, int> descCount = {};
        final Map<String, String> iconByDesc = {};
        for (var entry in dayItems) {
          final main = entry['main'] as Map<String, dynamic>;
          final weatherList = entry['weather'] as List<dynamic>;
          final w = weatherList.isNotEmpty ? weatherList[0] : null;
          final temp = (main['temp'] as num).toDouble();
          if (temp < minTemp) minTemp = temp;
          if (temp > maxTemp) maxTemp = temp;
          if (w != null) {
            final desc = (w['description'] as String);
            final icon = (w['icon'] as String);
            descCount[desc] = (descCount[desc] ?? 0) + 1;
            iconByDesc[desc] = icon;
          }
        }
        if (minTemp == double.infinity) minTemp = 0.0;
        if (maxTemp == -double.infinity) maxTemp = 0.0;
        String chosenDesc = '';
        int bestCount = -1;
        for (var e in descCount.entries) {
          if (e.value > bestCount) {
            bestCount = e.value;
            chosenDesc = e.key;
          }
        }
        final chosenIcon = chosenDesc != '' ? iconByDesc[chosenDesc] ?? '' : '';
        final dateParts = dateKey.split('-');
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        result.add(
          ForecastDay(
            date: date,
            minTemp: minTemp,
            maxTemp: maxTemp,
            description: chosenDesc,
            iconCode: chosenIcon,
          ),
        );
      }
      return result;
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to fetch forecast'));
    }
  }

  // Kept for backwards compatibility with older call sites.
  Future<List<ForecastDay>> fetch3DayForecast(String city) =>
      fetchDailyForecast(city, days: 3);

  String _extractMessage(String body, String fallback) {
    try {
      final data = json.decode(body) as Map<String, dynamic>?;
      if (data != null && data.containsKey('message')) {
        return data['message'] as String;
      }
    } catch (_) {
      // ignore parse errors, fall through to fallback
    }
    return fallback;
  }
}
