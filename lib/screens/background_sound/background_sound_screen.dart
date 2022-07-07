import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/screens/user/content/user_content_screen.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:meditation/util/player/player_navigation_util.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/background_sound/background_sound_volume.dart';
import 'package:meditation/screens/music/widgets/grid_view_widget.dart';
import 'package:meditation/screens/music/widgets/music_widget.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:provider/provider.dart';

class BackgroundSoundScreen extends StatefulWidget {
  BackgroundSoundScreen({Key key}) : super(key: key);
  static const String routeName = '/background-sound-screen';

  @override
  _BackgroundSoundScreenState createState() => _BackgroundSoundScreenState();
}

class _BackgroundSoundScreenState extends State<BackgroundSoundScreen> {
  final PlayerNavigationUtil playerNavigationRepository =
      PlayerNavigationUtil();
  final PlayerManager _playerManager = PlayerManager();
  ContentRepositoryFirebase _repositoryFirebase;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    AudioPlayerTask().playbackState.listen((event) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = event.processingState != AudioProcessingState.idle;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final MediaQueryData mediaQuery = MediaQuery.maybeOf(context);
    double width = (MediaQuery.of(context).size.width / 2) - 40.0;
    double height = width * 1.6;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: screenSize.height * 0.05,
          left: screenSize.width * 0.04,
          right: screenSize.width * 0.04,
        ),
        child: Column(
          children: [
            BackgroundSoundVolume(
              showBackIcon: true,
            ),
            SizedBox(
              height: screenSize.height * 0.04,
            ),
            Container(
              width: double.infinity,
              child: Text(
                'Background Sound',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.052,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: screenSize.height * 0.025,
              ),
              child: GridViewWidget<AudioItem>(
                width: width,
                height: height,
                initialData: Provider.of<ContentRepositoryFirebase>(context)
                    .backgroundSoundsCache,
                stream: Provider.of<ContentRepositoryFirebase>(context)
                    .backgroundSounds,
                title: Strings.recentlyAdded,
                errorMessage: Strings.recentlyAddedLoadingError,
                itemsInLine: 3,
                itemBuilder: (item) {
                  return MusicWidget(
                    item: item,
                    heroTag: '',
                    onTap: (item) {
                      PaymentStatus paymentStatus = PaymentStatus();
                      final bool isLocked = paymentStatus.isLocked(
                          paymentStatus.paymentStatus, item.isPaid);
                      if (!_repositoryFirebase
                              .configCache.showSubscribeScreen &&
                          isLocked) {
                        ScaffoldMessenger.maybeOf(context).showSnackBar(
                          SnackBar(
                            content: Text(Strings.errorOccured),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (isLocked) {
                        NavigationUtil().push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return UserContentScreen(
                                  isOffer: true,
                                );
                              },
                              settings: RouteSettings(
                                name: UserContentScreen.routeName,
                              )),
                        );
                      } else {
                        if (AudioPlayerTask().playbackState.value.playing) {
                          AudioPlayerTask().pause();
                        }
                        AudioPlayersUtil.isPlayingBackground = true;
                        AudioPlayersUtil.changeBgAudioIndex(item);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
