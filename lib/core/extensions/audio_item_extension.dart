import 'package:just_audio/just_audio.dart';
import 'package:meditation/models/audio.dart';

extension AudioItemExtension on AudioItem {
  static Map<String, Duration> _durations = {};
  Future<Duration> duration() async {
    if (_durations[this.file] == null) {
      AudioPlayer player = AudioPlayer();
      _durations[this.file] = await player.setUrl(this.file);
      await player.dispose();
    }
    return _durations[this.file];
  }
}
