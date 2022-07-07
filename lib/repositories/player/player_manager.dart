import 'dart:async';

import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/player/player_manager_repository.dart';

class PlayerManager extends PlayerManagerRepository {
  // singleton
  static final PlayerManager _singleton = PlayerManager._internal();
  factory PlayerManager() {
    return _singleton;
  }
  PlayerManager._internal();
  // end singleton

  StreamController<double> _volumeController =
      StreamController<double>.broadcast();
  StreamController<AudioItem> _backgroundAudioController =
      StreamController<AudioItem>.broadcast();
  StreamController<int> _currentStoryController =
      StreamController<int>.broadcast();
  StreamController<double> _durationProgressController =
      StreamController<double>.broadcast();
  StreamController<bool> _bgSounsStatusController =
      StreamController<bool>.broadcast();
  StreamController<AudioItem> _audioStatusController =
      StreamController<AudioItem>.broadcast();

  double volumeValue = 50;
  AudioItem backgroundAudio;
  int currentStoryIndex = 0;
  double durationProgress = 0;
  bool bgSounsStatus = false;
  AudioItem audioStatus;

  @override
  void changeVolumeValue(double value) {
    volumeValue = value;
    _volumeController.add(value);
  }

  @override
  void changeBackgroundAudio(AudioItem value) {
    backgroundAudio = value;
    _backgroundAudioController.add(value);
  }

  @override
  void changeCurrentStoryIndex(int value) {
    currentStoryIndex = value;
    _currentStoryController.add(value);
  }

  @override
  void changeDurationProgress(double value) {
    durationProgress = value;
    _durationProgressController.add(value);
  }

  @override
  void changeBgSoundsStatus(bool value) {
    bgSounsStatus = value;
    _bgSounsStatusController.add(value);
  }

  @override
  void changeAudioStatus(AudioItem value) {
    audioStatus = value;
    _audioStatusController.add(value);
  }

  @override
  Stream<double> getVolumeValue() {
    return _volumeController.stream;
  }

  @override
  Stream<AudioItem> getBackgroundAudio() {
    return _backgroundAudioController.stream;
  }

  @override
  Stream<int> getCurrentStoryIndex() {
    return _currentStoryController.stream;
  }

  @override
  Stream<double> getDurationProgress() {
    return _durationProgressController.stream;
  }

  @override
  Stream<bool> getBgSoundsStatus() {
    return _bgSounsStatusController.stream;
  }

  @override
  Stream<AudioItem> getAudioStatus() {
    return _audioStatusController.stream;
  }
}
