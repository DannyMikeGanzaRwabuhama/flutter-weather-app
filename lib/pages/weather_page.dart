import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:lottie/lottie.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService('YOUR_OPENWEATHERMAP_API_KEY_HERE');
  Weather? _weather;
  String _errorMessage = ""; // Added error message state

  // fetch weather
  _fetchWeather() async {
    setState(() {
      _errorMessage = ""; // Clear any previous error
    });

    try {
      // Get the current city
      String cityName = await _weatherService.getCurrentCity();

      if (cityName.isEmpty) {
        setState(() {
          _errorMessage =
          "Could not determine location. Please ensure location services are enabled.";
        });
        return;
      }

      // Get weather for the city
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load weather data. Please try again later.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background color
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E1E1E), // Slightly lighter dark color
              const Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // City Name
              Text(
                _weather?.cityName ?? "Loading city...",
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.lato(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Animation
              SizedBox(
                height: 250, // Adjust height as needed
                child: Lottie.asset(WeatherUtils.getAnimation(_weather?.mainCondition)),
              ),
              const SizedBox(height: 24),

              // Temperature
              Text(
                '${_weather?.temperature.round() ?? 0} °C',
                style: GoogleFonts.lato(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}