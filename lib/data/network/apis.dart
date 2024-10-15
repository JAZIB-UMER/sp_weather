// import 'package:http/http.dart' as http;
//
// Future<void> _fetchWeatherData() async {
//   final response = await http.get(
//     Uri.parse(
//         'https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY&units=metric'),
//   );
//
//   if (response.statusCode == 200) {
//     final weatherData = jsonDecode(response.body);
//     setState(() {
//       _weatherCondition = weatherData['weather'][0]['main'];
//       _temperature = weatherData['main']['temp'];
//       _weatherIcon = _getWeatherIcon(_weatherCondition);
//     });
//   } else {
//     throw Exception('Failed to load weather data');
//   }
// }
