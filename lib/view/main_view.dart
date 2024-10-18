import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superior_weather/view/daily_forecast.dart';
import 'package:superior_weather/view/home_view.dart';
import 'package:superior_weather/view/map_view.dart';
import 'package:superior_weather/view/radar_view.dart';
import 'package:superior_weather/view_model/bottom_nav_bar_model.dart';
import 'package:superior_weather/view_model/weather_view_model.dart';

class MainView extends StatelessWidget {
  final bool isConnectedValue;
  const MainView({super.key, required this.isConnectedValue});

  @override
  Widget build(BuildContext context) {
    final bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);

    final List<Widget> screens = [
      HomeView(
        isConnected: isConnectedValue,
      ), // Home Screen
      DailyForecast(), // Forecast Screen
      WeatherNerdsWebView(), // Radar Screen
      WebViewExample(), // Map Screen
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Display the selected screen based on current index
          IndexedStack(
            index: bottomNavigationProvider.currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 1.5,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent.withOpacity(0.8),
        currentIndex: bottomNavigationProvider.currentIndex,
        onTap: (index) {
          bottomNavigationProvider.changeIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
