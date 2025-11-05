// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pashuu/models/weather_model.dart';

class WeatherService {
  final String _apiKey = 'be2773b2249dc033e5e9a74bb5c76fa7';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // For now, we'll fetch weather for a fixed city.
  // A future improvement would be to get the user's GPS location.
  Future<Weather> fetchWeather(String cityName) async {
    // We add '&units=metric' to get the temperature in Celsius directly.
    final url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print("Weather service connection error: $e");
      throw Exception('Failed to connect to the weather service.');
    }
  }
}