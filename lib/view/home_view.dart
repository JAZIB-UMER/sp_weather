import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superior_weather/resources/components/large_weather_container.dart';
import 'package:superior_weather/utils/routes/routes_name.dart';
import 'package:superior_weather/view/components/home_components.dart';
import 'package:superior_weather/view/components/video_slider.dart';
import 'package:superior_weather/view_model/weather_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../view_model/video_provider.dart';

class HomeView extends StatefulWidget {
  bool isConnected = true;

  HomeView({super.key, isConnected}); // Variable to track internet connectivity
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late WebViewController _webViewController;
  late bool isConnectedLocal;
  late String backgroundImage;

  @override
  void initState() {
    super.initState();

    // Assign a value to backgroundImage based on some condition
    if (widget.isConnected) {
      isConnectedLocal = true;
    } else {
      isConnectedLocal = false; // Example path
    }

    // Initialize WebView controller
    _setBackgroundImage();

    // Initialize WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://live365.com/embed/player.html?station=a06810&s=sm&m=dark'));
  }

  void _setBackgroundImage() {
    // Get current hour
    int currentHour = DateTime.now().hour;

    // Set background image based on time of day
    backgroundImage = (currentHour >= 6 && currentHour < 18)
        ? 'assets/images/day_background.jpg' // Daytime image
        : 'assets/images/background_image.png'; // Nighttime image
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final List<String> videoUrls = [
      'https://www.youtube.com/watch?v=_5TiTfuvotc&pp=ygUOd2VhdGhlciBhbGVydHM%3D',
      'https://www.youtube.com/watch?v=5UFTaluS7Gc&pp=ygUOd2VhdGhlciBhbGVydHM%3D',
    ];

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ChangeNotifierProvider(
        create: (_) => VideoProvider(videoUrls), // Initialize VideoProvider
        child: Stack(
          children: [
            // Background Image
            Container(
              width: 807.12,
              height: 1211,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Main Content
            isConnectedLocal
                ? weatherProvider.isLoading == false
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP BAR
                              buildTopBar(height, context),

                              // Watch Live and Listen Live section
                              Container(
                                height: 1,
                                width: width,
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                              ),
                              buildLiveWatchAndListenRow(
                                  context, _webViewController),
                              Container(
                                height: 1,
                                width: width,
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                              ),
                              const SizedBox(height: 10),

                              // Video Slider Section
                              const SizedBox(height: 20),

                              const SizedBox(height: 10),

                              // City and Weather Info with shimmer effect
                              const SizedBox(height: 20),
                              buildWeatherInfoWithShimmer(weatherProvider),

                              const SizedBox(height: 20),
                              // Hourly forecast section

                              WeatherCard(
                                weatherProvider: weatherProvider,
                              ),
                              const SizedBox(height: 20),
                              buildHourlyForecast(weatherProvider),

                              const SizedBox(height: 10),
                              buildSectionTitle('Video Slider'),
                              SizedBox(
                                height: 200, // Control height for slider
                                child: VideoSlider(),
                              ),
                              const SizedBox(height: 10),
                              buildSectionTitle('Live Map'),
                              buildLiveRadar(
                                  'Go to Map',
                                  'assets/images/world-wind-map.png',
                                  context, onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesName.mapView);
                              }),

                              const SizedBox(height: 10),
                              buildSectionTitle('Live Radar'),
                              buildLiveRadar(
                                  'Go to live Radar',
                                  'assets/images/radar.jpg',
                                  context, onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesName.radarView);
                              }),
                              const SizedBox(height: 10),
                              buildSectionTitle('Weather Forecast'),
                              buildLiveRadar(
                                  'Go to Live Forecast View',
                                  'assets/images/dailyForecast.jpg',
                                  context, onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesName.dailyForecast);
                              }),
                            ],
                          ),
                        ),
                      )
                    : const Center(
                        child:
                            CircularProgressIndicator(), // Show loading spinner
                      )
                : const Center(
                    child: Text(
                      'No Internet Connection',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
