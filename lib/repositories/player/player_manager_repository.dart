import 'dart:async';

import 'package:meditation/models/audio.dart';

abstract class PlayerManagerRepository{
  Stream<double> getVolumeValue();

  Stream<AudioItem> getBackgroundAudio();

  Stream<int> getCurrentStoryIndex();

  Stream<double> getDurationProgress();

  Stream<bool> getBgSoundsStatus();

  Stream<AudioItem> getAudioStatus();


  void changeVolumeValue(double value);

  void changeBackgroundAudio(AudioItem value);

  void changeCurrentStoryIndex(int value);

  void changeDurationProgress(double value);

  void changeBgSoundsStatus(bool value);

  void changeAudioStatus(AudioItem value);
}