import 'package:flutter/material.dart';
import 'package:superior_weather/view_model/weather_view_model.dart';
// Update with your actual import

class WeatherCard extends StatelessWidget {
  final WeatherProvider weatherProvider;

  WeatherCard({required this.weatherProvider});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Access the weather data from the provider
    final weatherData = weatherProvider.weather;

    if (weatherData == null) {
      return Container(); // Or some loading state
    }

    final coord = weatherData.coord;
    final weather = weatherData.weather?.isNotEmpty == true
        ? weatherData.weather!.first
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: width,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'lat: ${coord?.lat}, lon: ${coord?.lon} ',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Country : ${weatherData.sys?.country}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '${weatherData.main?.humidity?.toStringAsFixed(1)}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Humidity',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w200),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (weather != null)
                  Container(
                    width: 100,
                    height: 100,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors
                            .white, // Change this to any color you want to tint the image
                        BlendMode.srcATop,
                      ),
                      child: Image.network(
                        'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Placeholder for error case
                          return Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                Text(
                  weather?.description ?? 'N/A',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
