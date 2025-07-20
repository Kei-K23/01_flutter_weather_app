import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String _apiKey = dotenv.env['OPEN_WEATHER_API_KEY']!;
  static const String _baseUrl =
      "https://api.openweathermap.org/data/2.5/weather";

  Future<Position> _getCurrentLocation() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    final position = await _getCurrentLocation();
    final url =
        "$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey";

    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }
}
