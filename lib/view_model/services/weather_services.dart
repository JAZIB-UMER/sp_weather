import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:superior_weather/model/weather_model.dart'; // Original model
import 'package:superior_weather/model/weather_model2.dart'; // New WeatherData2 model

class WeatherService {
  // Function to fetch weather from OpenWeatherMap
  Future<WeatherModel> fetchWeather(String location) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=488fffb1a4ac695d5d1c04229a742c6c&units=imperial'),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to load weather data from OpenWeatherMap');
      throw Exception('Failed to load weather data from OpenWeatherMap');
    }
  }

  // Function to fetch weather from Open Meteo
  Future<WeatherData2> fetchWeatherFromOpenMeteoApi(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m&temperature_unit=fahrenheit&forecast_days=14&timezone=auto'),
    );

    if (response.statusCode == 200) {
      return WeatherData2.fromJson(json.decode(response.body));
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to load weather data from Open Meteo');
      throw Exception('Failed to load weather data from Open Meteo');
    }
  }
}
