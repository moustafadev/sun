import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/screens/player/audio_player_screen.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/global/navigation_util.dart';

class CollapsedPlayer extends StatefulWidget {
  final AudioItem item;
  CollapsedPlayer({Key key, this.item}) : super(key: key);

  @override
  _CollapsedPlayerState createState() => _CollapsedPlayerState();
}

class _CollapsedPlayerState extends State<CollapsedPlayer>
    with TickerProviderStateMixin {
  bool isClosed = false;
  double playerHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playerHeight = MediaQuery.maybeOf(context).size.height * 0.07;
    AudioPlayerTask().playbackState.listen(
      (event) {
        if (mounted) {
          if (event.processingState != AudioProcessingState.idle) {
            setState(() {
              playerHeight = MediaQuery.maybeOf(context).size.height * 0.07;
            });
          } else {
            setState(() {
              playerHeight = 0;
            });
          }
        }
      },
    );
  }

  Future<void> onPlayTap() async {
    if (!AudioPlayerTask().playbackState.value.playing) {
      AudioPlayerTask().play();
      AudioPlayersUtil.bgSoundPlayer.pause();
      AudioPlayersUtil.isPlayingBackground = false;
    } else {
      AudioPlayerTask().pause();
      AudioPlayersUtil.bgSoundPlayer.play();
      AudioPlayersUtil.isPlayingBackground = true;
    }
    setState(() {});
  }

  Future<void> onCloseTap() async {
    setState(() {
      isClosed = true;
      playerHeight = 0;
      AudioPlayerTask().stop();
      AudioPlayersUtil.bgSoundPlayer.play();
      AudioPlayersUtil.isPlayingBackground = true;
      PlayerManager().changeAudioStatus(null);
      AudioPlayerTask().setCurrentAudioUrl('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.maybeOf(context).size;
    return GestureDetector(
      onTap: () {
        NavigationUtil().push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Hero(
                tag: 'collapsed',
                transitionOnUserGestures: true,
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  return Container(
                    child: Image.network(
                      widget.item.coverImage,
                      fit: BoxFit.cover,
                      width: screenSize.width,
                      height: screenSize.height,
                    ),
                  );
                },
                child: AudioPlayerScreen(
                  item: widget.item,
                  heroTag: 'collapsed',
                ),
              );
            },
            settings: RouteSettings(
              name: AudioPlayerScreen.routeName,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: playerHeight,
        child: Container(
          color: Color.fromRGBO(27, 27, 27, 1),
          padding: EdgeInsets.only(
            right: screenSize.width * 0.04,
          ),
          child: Row(
            children: [
              Hero(
                tag: 'collapsed',
                child: Image.network(
                  widget.item.coverImage,
                  width: screenSize.width * 0.2,
                  height: screenSize.height,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: screenSize.width * 0.04,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenSize.width * 0.45,
                    child: Text(
                      widget.item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: screenSize.width * 0.038,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.005,
                  ),
                  Container(
                    width: screenSize.width * 0.45,
                    child: Text(
                      widget.item.categoryName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.032,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  onPlayTap();
                },
                child: Icon(
                  !AudioPlayerTask().playbackState.value.playing
                      ? Icons.play_arrow
                      : Icons.pause,
                  color: Colors.white,
                  size: screenSize.width * 0.09,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  onCloseTap();
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: screenSize.width * 0.09,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
