import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/util/appsflyer/appsflyer_service.dart';
import 'package:meditation/util/facebook/facebook_service.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_players_util.dart';

class AudioPlayerTask extends BaseAudioHandler with SeekHandler {
  static final AudioPlayerTask _singleton = AudioPlayerTask._internal();
  factory AudioPlayerTask() {
    return _singleton;
  }
  AudioPlayerTask._internal();

  List<MediaItem> _queue = [];
  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState _skipState;
  Seeker _seeker;
  StreamSubscription<PlaybackEvent> _eventSubscription;
  MediaItem _mediaItem;
  static String _currentAudioUrl = '';

  static String get currentAudioUrl => _currentAudioUrl;
  // List<MediaItem> get queue => _queue;
  int get index => _player.currentIndex;
  // MediaItem get mediaItem => _mediaItem;

  Stream<QueueState> get queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          queue, mediaItem, (queue, mediaItem) => QueueState(queue, mediaItem));

  Stream<MediaState> get mediaStateStream =>
      Rx.combineLatest2<MediaItem, Duration, MediaState>(
          mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  void setCurrentAudioUrl(String url) {
    _currentAudioUrl = url;
  }

  Future<void> start(Map<String, dynamic> params) async {
    final duration = await _player.setUrl(params['uri']);
    _mediaItem = MediaItem(
      id: params['uri'],
      album: params['categoryName'],
      title: params['name'],
      artist: params['description'],
      artUri: Uri.parse(params['image']),
      duration: duration ?? Duration.zero,
    );
    _player.positionStream.listen((event) async {
      print(event);
      await AudioPlayersUtil.onAudioPlayerTime(event.inSeconds);
    });
    _player.currentIndexStream.listen((index) {
      if (index != null) mediaItem.add(_mediaItem);
    });
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          start(params);
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          break;
      }
    });

    try {
      await _player.setAutomaticallyWaitsToMinimizeStalling(true);
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(params['uri']),
        ),
        preload: false,
      );
      play();
      await AppsflyerService().achievementUnlocked(params['name']);
      await FacebookService().logAchievementUnlocked(params['name']);
    } catch (e) {
      print("Error: $e");
      stop();
    }
  }

  @override
  Future<void> onTaskRemoved() {
    stop();
    return super.onTaskRemoved();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) {
    start(mediaItem.extras);
    return super.updateMediaItem(mediaItem);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() =>
      _seekRelative(AudioServiceConfig().fastForwardInterval);

  @override
  Future<void> rewind() => _seekRelative(-AudioServiceConfig().rewindInterval);

  @override
  Future<void> seekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> seekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> stop() async {
    await _player.stop();
    _eventSubscription.cancel();
    await _broadcastState();
    await super.stop();
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.value.duration)
      newPosition = mediaItem.value.duration;
    await _player.seek(newPosition);
  }

  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem.value)
        ..start();
    }
  }

  Future<void> _broadcastState() async {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.rewind,
        MediaAction.fastForward,
        MediaAction.play,
        MediaAction.pause,
      },
      // androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
    // playbackState.add(PlaybackState());
  }

  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

class Seeker {
  final AudioPlayer _player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this._player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = _player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
      _player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
