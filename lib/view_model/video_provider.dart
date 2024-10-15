import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  final List<String> videoUrls;
  List<VideoPlayerController> videoControllers = [];
  int currentVideoIndex = 0;

  VideoProvider(this.videoUrls) {
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var url in videoUrls) {
      VideoPlayerController controller =
          VideoPlayerController.networkUrl(url as Uri)
            ..initialize().then((_) {
              notifyListeners();
            });
      videoControllers.add(controller);
    }
  }

  void setVideoIndex(int index) {
    currentVideoIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
