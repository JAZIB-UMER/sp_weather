import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MainView(isConnectedValue: _isConnected),
        ));
      }
    });
  }

  Future<void> _checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
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
    await cityProvider.loadLastSearchedCity();

    String cityToFetch = cityProvider.lastSearchedCity.isNotEmpty
        ? cityProvider.lastSearchedCity
        : 'los angeles'; // Default city

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
