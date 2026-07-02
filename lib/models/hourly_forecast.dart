class HourlyForecast {
  final DateTime time;
  final double temp;
  final String description;
  final String iconCode;
  final int pop; // probability of precipitation, 0-100

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.description,
    required this.iconCode,
    required this.pop,
  });
}
