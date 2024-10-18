import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoProvider with ChangeNotifier {
  final List<String> videoUrls;
  List<YoutubePlayerController> videoControllers = [];
  int currentVideoIndex = 0;

  VideoProvider(this.videoUrls) {
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var url in videoUrls) {
      YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId:
            YoutubePlayer.convertUrlToId(url)!, // Extract YouTube video ID
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      videoControllers.add(controller);
    }
    notifyListeners(); // Notify after controllers are created
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
