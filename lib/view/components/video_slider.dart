import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superior_weather/view_model/video_provider.dart';
import 'package:video_player/video_player.dart';

class VideoSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: videoProvider.videoUrls.length,
            onPageChanged: (index) => videoProvider.setVideoIndex(index),
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                controller: videoProvider.videoControllers[index],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            videoProvider.videoUrls.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: videoProvider.currentVideoIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: videoProvider.currentVideoIndex == index
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
