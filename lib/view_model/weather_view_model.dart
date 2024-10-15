import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:superior_weather/model/weather_model.dart';
import 'package:superior_weather/model/weather_model2.dart';
import 'package:superior_weather/view_model/services/weather_services.dart';

class WeatherProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  WeatherModel? _weatherCondition;
  WeatherData2? _weatherCondition2;
  List<IconData> _temperatureIcons = []; // List to store temperature icons

  IconData _weatherIcon = FontAwesomeIcons.cloud;

  WeatherModel? get weather => _weatherCondition;
  WeatherData2? get weather2 => _weatherCondition2;
  List<IconData> get temperatureIcons =>
      _temperatureIcons; // Getter for temperature icons
  IconData get weatherIcon => _weatherIcon;

  final WeatherService _weatherService = WeatherService();

  // State variable to manage expanded view for the 14-day forecast
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners(); // Notify listeners about the change
  }

  Future fetchWeatherData(String location) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners immediately

    try {
      debugPrint('Fetching Weather Data');
      _weatherCondition = await _weatherService.fetchWeather(location);

      // Set weather icon based on the current weather description
      if (_weatherCondition != null) {
        String condition = _weatherCondition!.weather![0].main!;
        _weatherIcon = _getWeatherIcon(condition);

        // Fetch latitude and longitude from the weather data
        double latitude = _weatherCondition!.coord!.lat!;
        double longitude = _weatherCondition!.coord!.lon!;

        // Call the function to fetch data from Open Meteo
        debugPrint('Fetching Open Meteo Data');
        _weatherCondition2 = await _weatherService.fetchWeatherFromOpenMeteoApi(
            latitude, longitude);
        fetchWeatherFromOpenMeteo(_weatherCondition2!);
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error fetching weather',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    _isLoading = false;
    notifyListeners(); // Notify listeners after loading is done
  }

  Future<void> fetchWeatherFromOpenMeteo(WeatherData2 weatherModel) async {
    // Clear previous icons
    _temperatureIcons.clear();

    for (var hourlyData in weatherModel.hourly) {
      double temperature = hourlyData.temperature;
      DateTime time = hourlyData.time;

      // Get icon based on temperature and time
      IconData icon = getIconForTemperatureAndTime(temperature, time);
      _temperatureIcons.add(icon); // Store icons based on temperature and time
    }
  }

  // Method to get the icon based on temperature and time
  IconData getIconForTemperatureAndTime(double temperature, DateTime time) {
    // Determine if it's day or night based on the hour
    bool isNight =
        time.hour < 6 || time.hour >= 18; // Night is from 6 PM to 6 AM

    if (isNight) {
      // Nighttime icons
      if (temperature < 32) {
        // Below freezing
        return FontAwesomeIcons
            .snowflake; // Snow icon for freezing temperatures
      } else if (temperature < 50) {
        // Cool temperatures
        return FontAwesomeIcons
            .cloudMoon; // Cloud with moon icon for cool nights
      } else if (temperature < 70) {
        // Mild temperatures
        return FontAwesomeIcons.moon; // Half-moon icon for mild nights
      } else {
        return FontAwesomeIcons.moon; // Full moon for warmer nights
      }
    } else {
      // Daytime icons
      if (temperature < 50) {
        // Cold temperatures
        return FontAwesomeIcons.cloud; // Cloud icon for cold daytime
      } else if (temperature < 70) {
        // Mild temperatures
        return FontAwesomeIcons.sun; // Sun icon for mild daytime
      } else if (temperature < 85) {
        // Warm temperatures
        return FontAwesomeIcons.solidSun; // Solid sun icon for warm daytime
      } else {
        return FontAwesomeIcons.sun; // Bright sun for hot temperatures
      }
    }
  }

  // Method to get the icon based on the weather condition
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return FontAwesomeIcons.sun;
      case 'rain':
        return FontAwesomeIcons.cloudRain;
      case 'clouds':
        return FontAwesomeIcons.cloud;
      case 'snow':
        return FontAwesomeIcons.snowflake;
      case 'thunderstorm':
        return FontAwesomeIcons.bolt;
      case 'drizzle':
        return FontAwesomeIcons.cloudShowersHeavy;
      case 'mist':
      case 'fog':
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.cloud;
    }
  }
}
