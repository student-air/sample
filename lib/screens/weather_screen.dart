import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';
import '../models/forecast_day.dart';
import '../models/hourly_forecast.dart';
import '../widgets/current_weather.dart';
import '../widgets/forecast_tile.dart';
import '../widgets/hourly_forecast_carousel.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/glass_panel.dart';
import '../widgets/unit_toggle.dart';
import '../widgets/recent_search_chips.dart';
import '../utils/theme.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();
  final _scrollController = ScrollController();

  Weather? _currentWeather;
  List<ForecastDay>? _forecast;
  List<HourlyForecast>? _hourly;
  bool _loading = false;
  String? _error;
  bool _useFahrenheit = false;
  List<String> _recentCities = [];

  Offset _parallaxShift = Offset.zero;

  static const String _kLastCityKey = 'last_city';
  static const String _kRecentCitiesKey = 'recent_cities';
  static const String _kUnitKey = 'use_fahrenheit';

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scrollController.addListener(_onScroll);
    _loadPrefsAndFetch();
  }

  void _onScroll() {
    // Drive a subtle backdrop parallax from vertical scroll position.
    final shiftY = (_scrollController.offset / 800).clamp(-1.0, 1.0);
    setState(() {
      _parallaxShift = Offset(_parallaxShift.dx, shiftY);
    });
  }

  Future<void> _loadPrefsAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastCityKey);
    _recentCities = prefs.getStringList(_kRecentCitiesKey) ?? [];
    _useFahrenheit = prefs.getBool(_kUnitKey) ?? false;
    if (mounted) setState(() {});
    if (last != null && last.isNotEmpty) {
      _cityController.text = last;
      await _fetchWeather(last);
    }
  }

  Future<void> _rememberCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCityKey, city);
    _recentCities.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    _recentCities.insert(0, city);
    if (_recentCities.length > 6) {
      _recentCities = _recentCities.sublist(0, 6);
    }
    await prefs.setStringList(_kRecentCitiesKey, _recentCities);
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _entranceController.reset();
    try {
      final results = await Future.wait([
        _weatherService.fetchCurrentWeather(city),
        _weatherService.fetchDailyForecast(city, days: 5),
        _weatherService.fetchHourlyForecast(city),
      ]);
      setState(() {
        _currentWeather = results[0] as Weather;
        _forecast = results[1] as List<ForecastDay>;
        _hourly = results[2] as List<HourlyForecast>;
        _loading = false;
      });
      _entranceController.forward();
      await _rememberCity(city);
      if (mounted) setState(() {});
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _currentWeather = null;
        _forecast = null;
        _hourly = null;
        _loading = false;
      });
    }
  }

  Future<void> _toggleUnit(bool fahrenheit) async {
    setState(() => _useFahrenheit = fahrenheit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUnitKey, fahrenheit);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _fetchWeather(city);
  }

  Animation<double> _stagger(int index, int total) {
    final start = (index / (total + 1)).clamp(0.0, 1.0);
    final end = ((index + 2) / (total + 1)).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _staggeredItem(int index, int total, Widget child) {
    final animation = _stagger(index, total);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 24),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _buildError(_error!);
    }
    if (_currentWeather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Search for a city to see the weather',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText.withValues(alpha: 0.9)),
          ),
        ),
      );
    }

    final sections = <Widget>[
      CurrentWeatherWidget(weather: _currentWeather!, useFahrenheit: _useFahrenheit),
      if (_hourly != null && _hourly!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: HourlyForecastCarousel(
            hours: _hourly!,
            useFahrenheit: _useFahrenheit,
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      if (_forecast != null && _forecast!.isNotEmpty)
        Column(
          children: _forecast!
              .map((d) => ForecastTile(day: d, useFahrenheit: _useFahrenheit))
              .toList(),
        )
      else
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Forecast not available',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      const SizedBox(height: 32),
    ];

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.spaceMid,
      onRefresh: () async {
        if (_currentWeather != null) {
          await _fetchWeather(_currentWeather!.cityName);
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            for (int i = 0; i < sections.length; i++)
              _staggeredItem(i, sections.length, sections[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassPanel(
          interactive3D: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.errorAccent),
              const SizedBox(height: 12),
              Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onBackground),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final city = _cityController.text.trim();
                  if (city.isNotEmpty) _fetchWeather(city);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final condition = _currentWeather?.condition ?? 'Clear';
    final isDay = _currentWeather?.isDay ?? true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackdrop(
              condition: condition,
              isDay: isDay,
              parallaxShift: _parallaxShift,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassPanel(
                          interactive3D: false,
                          borderRadius: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _cityController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _onSearch(),
                            style: const TextStyle(color: AppColors.onBackground),
                            decoration: InputDecoration(
                              hintText: 'Search a city…',
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                                onPressed: _onSearch,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      UnitToggle(useFahrenheit: _useFahrenheit, onChanged: _toggleUnit),
                    ],
                  ),
                ),
                if (_recentCities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RecentSearchChips(
                        cities: _recentCities,
                        onSelected: (city) {
                          _cityController.text = city;
                          _fetchWeather(city);
                        },
                      ),
                    ),
                  ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
