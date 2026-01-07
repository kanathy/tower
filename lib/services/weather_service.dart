import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String? apiKey = dotenv.env['OPENWEATHER_API_KEY'];
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    print('WeatherService: Fetching for $lat, $lon');
    if (apiKey == null || apiKey!.isEmpty) {
      print('WeatherService ERROR: API key is missing from .env');
      return null;
    }

    final url = '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    print('WeatherService: Request URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('WeatherService: Success');
        return json.decode(response.body);
      } else {
        print('WeatherService ERROR: HTTP ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Weather service exception: $e');
      return null;
    }
  }
}
