import 'package:flutter/material.dart';
import 'package:superior_weather/utils/routes/routes_name.dart';
import 'package:superior_weather/view/daily_forecast.dart';
import 'package:superior_weather/view/home_view.dart';
import 'package:superior_weather/view/map_view.dart';
import 'package:superior_weather/view/radar_view.dart';
import 'package:superior_weather/view/splashScreen.dart';

class Routes {
  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.home:
        return MaterialPageRoute(builder: (context) => HomeView());

      case RoutesName.mapView:
        return MaterialPageRoute(builder: (context) => WebViewExample());

      case RoutesName.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case RoutesName.radarView:
        return MaterialPageRoute(
            builder: (context) => const WeatherNerdsWebView());
      case RoutesName.dailyForecast:
        return MaterialPageRoute(builder: (context) => const DailyForecast());

      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('No Routes Defined'),
            ),
          );
        });
    }
  }
}
