import 'package:flutter/material.dart';
import 'package:superior_weather/resources/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WeatherNerdsWebView extends StatefulWidget {
  const WeatherNerdsWebView({super.key});

  @override
  State<WeatherNerdsWebView> createState() => _WeatherNerdsWebViewState();
}

class _WeatherNerdsWebViewState extends State<WeatherNerdsWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true; // Track the loading state
  int _progress = 0; // Track the progress percentage

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update the loading progress and state
            setState(() {
              _progress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Show loading when the page starts loading
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide loading when the page is fully loaded
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Prevents navigation to YouTube
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('Blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('Navigating to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://www.weathernerds.org/satellite/?initsatsrc=On&initsatname=GOES-E&initsattype=ir&initcscheme=ir1&initimdimx=1050&initimdimy=630&initrange=55.000:-130.000:20.000:-60.000&initloop=True&initnframes=20&initlightningge=On&initlightninggw=Off&initltngfed=Off&initltngtoe=Off&initinterstates=On&initwarnings=On&initlatlon=Off&initascatb=Off&initascatc=Off&initascatambb=Off&initascatambc=Off&initsst=Off&initecens=Off&initgefs=Off'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress / 100.0, // Show progress as percentage
                      backgroundColor: Colors.grey,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading: $_progress%',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor2,
          onPressed: () => _webViewController.reload(),
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
