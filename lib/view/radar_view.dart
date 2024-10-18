import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WeatherNerdsWebView extends StatefulWidget {
  const WeatherNerdsWebView({super.key});

  @override
  State<WeatherNerdsWebView> createState() => _WeatherNerdsWebViewState();
}

class _WeatherNerdsWebViewState extends State<WeatherNerdsWebView> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Initialize WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
        body: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}
