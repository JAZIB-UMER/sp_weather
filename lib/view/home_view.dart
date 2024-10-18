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
  final bool isConnected; // Properly declare final to avoid mutation

  // Initialize isConnected properly inside the constructor
  HomeView({super.key, this.isConnected = true});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late WebViewController _twitchWebViewController;
  late WebViewController _webViewController;
  late bool isConnectedLocal;
  late String backgroundImage;

  @override
  void initState() {
    super.initState();

    isConnectedLocal = widget.isConnected;
    _setBackgroundImage();
    _initializeWebViewControllers();
  }

  // Initialize the WebView Controllers
  void _initializeWebViewControllers() {
    _twitchWebViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_buildWebViewNavigationDelegate())
      ..loadRequest(Uri.parse(
          'https://player.twitch.tv/?channel=superiorweather&parent=localhost'));

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_buildWebViewNavigationDelegate())
      ..loadRequest(Uri.parse(
          'https://live365.com/embed/player.html?station=a06810&s=sm&m=dark'));
  }

  // Set background image based on time of day
  void _setBackgroundImage() {
    int currentHour = DateTime.now().hour;
    backgroundImage = (currentHour >= 6 && currentHour < 18)
        ? 'assets/images/day_background.jpg'
        : 'assets/images/background_image.png';
  }

  // Common WebView Navigation Delegate
  NavigationDelegate _buildWebViewNavigationDelegate() {
    return NavigationDelegate(
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
    );
  }

  // Embed Twitch Stream Widget
  Widget buildTwitchStream() {
    return SizedBox(
      height: 300,
      child: WebViewWidget(controller: _twitchWebViewController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final videoUrls = [
      'https://www.youtube.com/watch?v=EoZV2JvIiOo',
      'https://www.youtube.com/watch?v=xmpu_VHst_4',
      'https://www.youtube.com/watch?v=ZV3R5eR06cY',
      'https://www.youtube.com/watch?v=voVe7F8rRkU',
      'https://www.youtube.com/watch?v=ni0flPUmZjA',
    ];

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ChangeNotifierProvider(
        create: (_) => VideoProvider(videoUrls),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            isConnectedLocal
                ? weatherProvider.isLoading == false
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTopBar(height, context),
                            const SizedBox(height: 10),
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
                            buildWeatherInfoWithShimmer(weatherProvider),
                            const SizedBox(height: 10),
                            WeatherCard(weatherProvider: weatherProvider),
                            buildHourlyForecast(weatherProvider),
                            const SizedBox(height: 20),
                            buildSectionTitle('Superior Weather Live'),
                            const SizedBox(height: 10),
                            buildTwitchStream(),
                            const SizedBox(height: 20),
                            buildSectionTitle('Video Forecast'),
                            const SizedBox(height: 10),
                            buildLiveRadar(
                                'Go to Live Forecast View',
                                'assets/images/dailyForecast.jpg',
                                context, onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.dailyForecast);
                            }),
                            const SizedBox(height: 20),
                            buildSectionTitle('Hete°rology'),
                            SizedBox(
                              height: 300,
                              child: VideoSlider(),
                            ),
                            const SizedBox(height: 20),
                            buildSectionTitle('Live Map'),
                            buildLiveRadar(
                                'Go to Map',
                                'assets/images/world-wind-map.png',
                                context, onTap: () {
                              Navigator.pushNamed(context, RoutesName.mapView);
                            }),
                            const SizedBox(height: 20),
                            buildSectionTitle('Live Radar'),
                            buildLiveRadar('Go to live Radar',
                                'assets/images/radar.jpg', context, onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.radarView);
                            }),
                          ],
                        ),
                      )
                    : const Center(child: CircularProgressIndicator())
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

  @override
  void dispose() {
    _twitchWebViewController.clearCache();
    _webViewController.clearCache();
    super.dispose();
  }
}
