import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/resources/shared_prefs_keys.dart';
import 'package:meditation/core/extensions/days_extension.dart';

class AudioPlayersUtil {
  static final AudioPlayer bgSoundPlayer = AudioPlayer();

  static final AudioPlayer audioPlayer = AudioPlayer();
  static final Preferences prefs = Preferences();
  static final PlayerManager playerManager = PlayerManager();

  static AudioItem currentAudio;
  static String currentAudioUrl = '';
  static Day today = Day(DateTime.now().weekday);
  static int prevPosition = 0;
  static bool isPlaying = false;
  static bool isPlayingBackground = false;
  static int duration = 0;
  static int position = 0;
  static bool isBgSoundListened = false;
  static int currentAudioIndex = 0;
  static bool isAudioClicked = false;
  static int totalListenedValue;
  static int daySeconds;

  static Future<void> onAudioPlayerTime(int position,
      {bool isPlaylist = false}) async {
    if (position == prevPosition) {
      return;
    }
    final isForward = position > prevPosition;

    if (isForward) {
      totalListenedValue = totalListenedValue == null
          ? await prefs.getInt(totalListenedMinutes, 0)
          : totalListenedValue;
      daySeconds = daySeconds == null
          ? await prefs.getInt(today.asString(), 0)
          : daySeconds;

      final difference = position - prevPosition;
      totalListenedValue += difference;
      daySeconds += difference;
      await prefs.setInt(totalListenedMinutes, totalListenedValue);
      var weekStr = today.asString();
      await prefs.setInt(weekStr, daySeconds);
    }

    prevPosition = position;

    if (isPlaylist) {
      playerManager.changeDurationProgress(
          playerManager.durationProgress - prevPosition + position);
    }
  }

  static Future<void> startBackgroundPlayer(AudioItem audio) async {
    await bgSoundPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(audio.file)),
      preload: false,
    );
    bgSoundPlayer.setLoopMode(LoopMode.one);
  }

  static Future<void> changeBgAudioIndex(AudioItem item,
      {bool isInit = false}) async {
    if (isInit) {
      playerManager.changeBackgroundAudio(currentAudio);
      return;
    }
    bgSoundPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(item.file),
      ),
      preload: false,
    );
    bgSoundPlayer.setLoopMode(LoopMode.one);
    currentAudio = item;
    playerManager.changeBackgroundAudio(currentAudio);
  }
}
