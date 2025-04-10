import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:weather_app/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const baseURL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  final loc.Location location = loc.Location();

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final uri = Uri.parse('$baseURL?q=$cityName&appid=$apiKey&units=metric');
    // print("Sending weather request to: $uri");

    try {
      final response = await http.get(uri);
      // print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw _handleHttpError(response.statusCode);
      }
    } catch (e) {
      print("Weather request error: $e");
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      final serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled && !await location.requestService()) {
        return ""; // fallback city
      }

      final permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied && await location.requestPermission() != loc.PermissionStatus.granted) {
        return ""; // fallback or throw if preferred
      }

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) throw Exception("Invalid coordinates");

      print("Coordinates: $lat, $lon");

      final placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.administrativeArea ?? "Unknown city";
        print("Detected city: $city");
        return city;
      } else {
        print("No placemarks found");
        return "";
      }
    } catch (e) {
      print("Error determining current city: $e");
      return ""; // fallback or return empty
    }
  }

  Exception _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 401:
        return Exception('Invalid API key');
      case 404:
        return Exception('City not found');
      case 429:
        return Exception('API request limit exceeded');
      default:
        return Exception('HTTP error $statusCode');
    }
  }
}
