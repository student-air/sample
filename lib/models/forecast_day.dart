class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String iconCode;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
  });
}
