import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.paused;

  PlayerState get playerState => _playerState;

  AudioProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });
  }

  Future<void> play() async {
    await _audioPlayer.play(UrlSource(
        'https://live365.com/embed/player.html?station=a06810&s=sm&m=dark'));
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  void stop() {
    _audioPlayer.stop();
  }
}
