// lib/models/weather_model.dart

class Weather {
  final String cityName;
  final double temperature;
  final String condition; // e.g., "Clear", "Clouds", "Rain"
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      // The API returns temperature, which we already requested in Celsius
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}