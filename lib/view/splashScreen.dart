import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:superior_weather/view/home_view.dart';
import 'package:superior_weather/view/main_view.dart';
import 'package:superior_weather/view_model/city_suggestion_model.dart';
import 'package:superior_weather/view_model/weather_view_model.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    // Fetch weather data only after connectivity is confirmed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchWeatherData();
    });
    _controller = VideoPlayerController.asset('assets/intro_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(false);
      });

    // Navigate to the main screen after the video ends
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Use a fade transition to avoid the white flash
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainView(isConnectedValue: _isConnected),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  Future<void> _checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    }

    if (!_isConnected) {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _fetchWeatherData() async {
    final cityProvider =
        Provider.of<CitySuggestionProvider>(context, listen: false);
    // Wait for the last searched city to be updated if it's fetched asynchronously
    await cityProvider.loadLastSearchedCity();

    String cityToFetch = cityProvider.lastSearchedCity.isNotEmpty
        ? cityProvider.lastSearchedCity
        : 'los angeles'; // Default city if none stored

    if (_isConnected) {
      try {
        await Provider.of<WeatherProvider>(context, listen: false)
            .fetchWeatherData(cityToFetch);
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Failed to fetch weather data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
