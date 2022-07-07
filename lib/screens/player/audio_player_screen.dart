import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/favorites/favorites_repository.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/repositories/local/local_repository.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/screens/player/widgets/animated_background_image.dart';
import 'package:meditation/screens/player/widgets/favourite_icon_widget.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:meditation/util/string_utils.dart';
import 'package:meditation/widgets/seek_bar.dart';

class AudioPlayerScreen extends StatefulWidget {
  static const String routeName = '/audio-player-screen';

  final AudioItem item;
  final String heroTag;
  final bool isPlaylist;

  AudioPlayerScreen({
    @required this.item,
    @required this.heroTag,
    this.isPlaylist = false,
  });
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final LocalRepository favoritesRepository = FavoritesRepository();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeScreenNavigation navigation = HomeScreenNavigation();
  final AudioPlayerTask _audioPlayerTask = AudioPlayerTask();
  bool _favorite = false;

  /// check internet is available or not
  checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Oops! Internet lost'),
              content: Text(
                  'Sorry, Please check your internet connection and then try again'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  onPressed: () {
                    checkConnectivity();
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else if (result == ConnectivityResult.mobile) {
    } else if (result == ConnectivityResult.wifi) {}
  }

  @override
  void initState() {
    super.initState();
    AudioPlayersUtil.bgSoundPlayer.pause();
    PlayerManager().changeAudioStatus(widget.item);
    if (AudioPlayerTask.currentAudioUrl == '') {
      _audioPlayerTask.start(
        {
          'uri': widget.item.file,
          'categoryName': widget.item.categoryName,
          'name': widget.item.name,
          'description': widget.item.description,
          'image': widget.item.coverImage,
        },
      ).then((value) => setState(() {}));
      _audioPlayerTask.setCurrentAudioUrl(widget.item.file);
    } else if (AudioPlayerTask.currentAudioUrl != widget.item.file) {
      AudioPlayerTask().updateMediaItem(
        MediaItem(
          id: widget.item.file,
          album: widget.item.categoryName,
          title: widget.item.name,
          extras: {
            'uri': widget.item.file,
            'categoryName': widget.item.categoryName,
            'name': widget.item.name,
            'description': widget.item.description,
            'image': widget.item.coverImage,
          },
        ),
      );
      _audioPlayerTask.setCurrentAudioUrl(widget.item.file);
    }

    getFavouritesTracks();
  }

  Future<void> getFavouritesTracks() async {
    final item = await favoritesRepository.get(widget.item.id);
    if (item != null) _favorite = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.maybeOf(context).size;
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: StreamBuilder<PlaybackState>(
        stream: AudioPlayerTask().playbackState,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return SizedBox();
          }
          return Stack(
            children: <Widget>[
              Container(
                foregroundDecoration: BoxDecoration(color: Colors.black26),
                height: double.infinity,
                width: double.infinity,
                child: AnimatedBackgroundImageWidget(
                  imageUrl: widget.item.getCoverImageFullPath(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenSize.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackButtonWidget(),
                      _buildBackgroundSoundWidget(),
                      FavouriteIconWidget(
                          favorite: _favorite, item: widget.item),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.2),
                  _buildNameWidget(),
                  SizedBox(height: screenSize.height * 0.009),
                  _buildDescriptionWidget(),
                  Spacer(),
                  StreamBuilder<AudioProcessingState>(
                    stream: AudioPlayerTask()
                        .playbackState
                        .map((state) => state.processingState)
                        .distinct(),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          _buildProgressBarWidget(),
                          _buildProgressTimesWidget(),
                          SizedBox(
                            height: screenSize.height * 0.02,
                          ),
                          _buildControlsWidget(),
                          SizedBox(
                            height: screenSize.height * 0.05,
                          )
                        ],
                      );
                    },
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundSoundWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.005,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromRGBO(65, 139, 160, 0.8),
        ),
        child: Column(
          children: [
            Text(
              'Background sounds',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenSize.width * 0.03,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'Calmness',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        navigation.changePageIndex(5);
        NavigationUtil().pop(context);
      },
    );
  }

  Widget _buildBackButtonWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: GestureDetector(
        child: Container(
          child: SvgPicture.asset(
            Images.icBack,
            color: Colors.white,
            width: screenSize.width * 0.09,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildNameWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
      ),
      child: Center(
        child: Text(widget.item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenSize.width * 0.11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildDescriptionWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: Center(
        child: Text(
          widget.item.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenSize.width * 0.057,
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildControlsWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return StreamBuilder<bool>(
      stream: AudioPlayerTask()
          .playbackState
          .map((state) => state.playing)
          .distinct(),
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildReplay10Button(),
              SizedBox(
                width: screenSize.width * 0.03,
              ),
              playing ? _buildPauseButton() : _buildPlayButton(),
              SizedBox(
                width: screenSize.width * 0.03,
              ),
              _buildForward10Button(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplay10Button() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return StreamBuilder<MediaState>(
      stream: _audioPlayerTask.mediaStateStream,
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        final position = mediaState?.position ?? Duration.zero;
        return IconButton(
          iconSize: screenSize.width * 0.12,
          icon: SvgPicture.asset(
            Images.replay10IconSvg,
            color: position.inSeconds > 0 ? Colors.white : Colors.white54,
            width: screenSize.width * 0.11,
          ),
          onPressed:
              position.inSeconds > 0 ? () => _replay10Seconds(position) : null,
          color: Colors.white,
        );
      },
    );
  }

  void _replay10Seconds(Duration position) {
    final newPosition = position - const Duration(seconds: 10);

    if (newPosition < const Duration(seconds: 0))
      AudioPlayerTask().seek(const Duration(seconds: 0));
    else
      AudioPlayerTask().seek(newPosition);
  }

  Widget _buildForward10Button() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return StreamBuilder<MediaState>(
      stream: _audioPlayerTask.mediaStateStream,
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        final position = mediaState?.position ?? Duration.zero;
        final duration = mediaState?.mediaItem?.duration ?? Duration.zero;
        return IconButton(
          iconSize: screenSize.width * 0.12,
          icon: SvgPicture.asset(
            Images.forward10IconSvg,
            color: position.inSeconds < duration.inSeconds
                ? Colors.white
                : Colors.white54,
            width: screenSize.width * 0.11,
          ),
          onPressed: position.inSeconds < duration.inSeconds
              ? () => _forward10Seconds(position, duration)
              : null,
          color: Colors.white,
        );
      },
    );
  }

  void _forward10Seconds(Duration position, Duration duration) {
    final newPosition = position + const Duration(seconds: 10);

    if (newPosition > duration)
      AudioPlayerTask().seek(duration);
    else
      AudioPlayerTask().seek(newPosition);
  }

  Widget _buildPlayButton() {
    final screenSize = MediaQuery.maybeOf(context).size;
    return IconButton(
      iconSize: screenSize.width * 0.24,
      icon: SvgPicture.asset(
        Images.play,
        color: Colors.white,
        width: screenSize.width * 0.29,
        height: screenSize.width * 0.29,
      ),
      onPressed: () => play(AudioPlayersUtil.position),
      color: Colors.white,
    );
  }

  Widget _buildPauseButton() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return IconButton(
      iconSize: screenSize.width * 0.24,
      icon: SvgPicture.asset(Images.pause, color: Colors.white),
      onPressed: pause,
      color: Colors.white,
    );
  }

  Widget _buildProgressBarWidget() {
    return StreamBuilder<MediaState>(
      stream: _audioPlayerTask.mediaStateStream,
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        return SeekBar(
          duration: mediaState?.mediaItem?.duration ?? Duration.zero,
          position: mediaState?.position ?? Duration.zero,
          onChangeEnd: (newPosition) {
            AudioPlayerTask().seek(newPosition);
          },
        );
      },
    );
  }

  Widget _buildProgressTimesWidget() {
    return StreamBuilder<MediaState>(
      stream: _audioPlayerTask.mediaStateStream,
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StringUtils().formatSeconds(
                  (mediaState?.position ?? Duration.zero).inSeconds,
                  divider: ":",
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.038,
                ),
              ),
              Text(
                StringUtils().formatSeconds(
                  (mediaState?.mediaItem?.duration ?? Duration.zero).inSeconds,
                  divider: ":",
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.038,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void pause() {
    AudioPlayerTask().pause();
    AudioPlayersUtil.bgSoundPlayer.play();
    AudioPlayersUtil.isPlayingBackground = true;
  }

  Future<void> play([int position = 0]) async {
    AudioPlayerTask().play();
    AudioPlayersUtil.bgSoundPlayer.pause();
    AudioPlayersUtil.isPlayingBackground = false;

    await Amplitude.getInstance(instanceName: "sunmeditation").logEvent(
      'play',
      eventProperties: widget.item.toMap(),
    );
  }
}
