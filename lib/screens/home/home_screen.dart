import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/models/story_category.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/screens/home/widgets/noon_looping_carousel.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/player/player_navigation_util.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/background_sound/background_sound_screen.dart';
import 'package:meditation/screens/favorites/favorites_page.dart';
import 'package:meditation/screens/home/old_widgets/bottom_nav_bar.dart';
import 'package:meditation/screens/home/widgets/popular_meditation_widget.dart';
import 'package:meditation/screens/meditation/meditation_page.dart';
import 'package:meditation/screens/music/music_page.dart';
import 'package:meditation/screens/profile/profile_page.dart';
import 'package:meditation/screens/sleep/sleep_page.dart';
import 'package:meditation/screens/text_guide/story_card.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/collapsed_player.dart';
import 'package:meditation/widgets/horizontal_list_widget.dart';
import 'package:meditation/widgets/stream_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  final bool checkSubscription;

  HomeScreen({this.checkSubscription = true});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Preferences preferences = Preferences();
  final HomeScreenNavigation navigation = HomeScreenNavigation();
  ContentRepositoryFirebase _repositoryFirebase;

  Stream<int> getHomePage;
  Stream<List<Duration>> getPopularAudiosDuration;
  List<Widget> pages = [];
  bool isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    getHomePage = navigation.getPageIndex();
    AudioService.init(
      builder: () => AudioPlayerTask(),
      config: AudioServiceConfig(
        androidNotificationChannelName: 'Audio Service Demo',
        notificationColor: Color(0xFF2196f3),
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidStopForegroundOnPause: true,
        androidNotificationOngoing: true,
      ),
    );
    AudioPlayerTask().playbackState.listen((event) {
      if (mounted) {
        setState(() {
          isAudioPlaying = event.processingState != AudioProcessingState.idle;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  Future<Duration> getAudioDuration(AudioItem item) async {
    AudioPlayer player = AudioPlayer();
    final duration = await player.setUrl(item.getFileUrl());
    return duration;
  }

  Widget getCurrentPage(int index) {
    if (index == 5) {
      return BackgroundSoundScreen();
    } else if (index == 6) {
      return FavoritesPage();
    } else {
      return pages[index];
    }
  }

  void onButtonBackButtonTap() {
    navigation.changePageIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.maybeOf(context);

    Widget _home = _buildHomeScreen();
    Widget _meditation = MeditationPage(onBackButtonTap: onButtonBackButtonTap);
    Widget _sleep = SleepPage(onBackButtonTap: onButtonBackButtonTap);
    Widget _music = MusicPage(onBackButtonTap: onButtonBackButtonTap);
    Widget _profile = ProfilePage();
    Widget _backgroundSound = BackgroundSoundScreen();
    Widget _favorites = FavoritesPage();
    pages = [
      _home,
      _meditation,
      _sleep,
      _music,
      _profile,
      _backgroundSound,
      _favorites,
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.mainBackground),
              fit: BoxFit.cover,
            ),
            color: Colors.black,
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: getHomePage,
                  initialData: navigation.homeScreenPageIndex,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Container(
                      margin: EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight +
                            mediaQuery.padding.bottom +
                            (isAudioPlaying
                                ? mediaQuery.size.height * 0.07
                                : 0),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: getCurrentPage(snapshot.data),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StreamBuilder(
                        stream: PlayerManager().getAudioStatus(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: CollapsedPlayer(
                              item: snapshot.data,
                            ),
                          );
                        },
                      ),
                      buildBottomNavigationBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Exit'),
              content: Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No')),
                TextButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: Text('Yes'))
              ]);
        });
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopButtonsWidget(),
          const SizedBox(height: 26.0),
          _buildWelcomeWidget(),
          const SizedBox(height: 31.0),
          _buildRecommendationsWidget(),
          const SizedBox(height: 38.0),
          _buildPopularWidget(),
          const SizedBox(height: 27.0),
          _buildStoryWidget(),
        ],
      ),
    );
  }

  Widget _buildTopButtonsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              navigation.changePageIndex(0);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => PlaylistPage()));
            },
            child: Image.asset(
              Images.logoTransparent,
              height: 36.0,
              width: 36.0,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: _onFavouriteTap,
            child: SvgPicture.asset(Images.icFavourites,
                height: 36.0, width: 36.0),
          ),
        ],
      ),
    );
  }

  void _onFavouriteTap() {
    navigation.changePageIndex(6);
  }

  Widget _buildWelcomeWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
              color: whiteColor,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Choose what you want to do today.',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamHandler(
        initial:
            Provider.of<ContentRepositoryFirebase>(context).bestOfTheWeekCache,
        stream: Provider.of<ContentRepositoryFirebase>(context).bestOfTheWeek,
        builder: (data) {
          return NoonLoopingCarousel(
            data: data.data,
          );
        },
      ),
    );
  }

  Widget _buildPopularWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;
    double width = (screenSize.width / 2.75) - screenSize.width * 0.05;
    PlayerNavigationUtil playerNavigationRepository = PlayerNavigationUtil();
    if (width < 110.0) {
      width = 110.0;
    } else if (width > 180.0) {
      width = 180.0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: HorizontalListWidget<AudioItem>(
        width: width,
        height: width + screenSize.height * 0.065,
        initialData:
            Provider.of<ContentRepositoryFirebase>(context).popularCache,
        stream: Provider.of<ContentRepositoryFirebase>(context).popular,
        title: Strings.popular,
        errorMessage: Strings.bestOfTheWeekLoadingError,
        itemBuilder: (item) {
          return PopularMeditationWidget(
            item: item,
            width: width,
            heroTag:
                playerNavigationRepository.buildTag(item, "best_of_the_week"),
            onTap: (item) => playerNavigationRepository.navigateToAudio(
              item,
              playerNavigationRepository.buildTag(item, "best_of_the_week"),
              context,
              _repositoryFirebase,
            ),
          );
        },
        headerButton: true,
        headerPadding: screenSize.height * 0.03,
        buttonText: 'Background sounds',
        onButtonTap: () {
          navigation.changePageIndex(5);
        },
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return StreamBuilder(
        stream: getHomePage,
        initialData: navigation.homeScreenPageIndex,
        builder: (context, snapshot) {
          return BottomNavBar(
            items: [
              NavItem(Strings.home, Images.icHome),
              NavItem(Strings.home, Images.icLotus),
              NavItem(Strings.home, Images.icSleep),
              NavItem(Strings.reminder, Images.icSound),
              NavItem(Strings.favorites, Images.icUser),
            ],
            onNavItemClick: (int index) => setState(
              () {
                navigation.changePageIndex(index);
              },
            ),
            selectedItem: snapshot.data < 5 ? snapshot.data : 0,
          );
        });
  }

  Widget _buildStoryWidget() {
    double width = MediaQuery.of(context).size.width * 0.5;
    if (width < 110.0) {
      width = 110.0;
    } else if (width > 180.0) {
      width = 180.0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: HorizontalListWidget<StoryCategory>(
        width: width,
        height: width + 45.0,
        headerPadding: 26.0,
        initialData: Provider.of<ContentRepositoryFirebase>(context)
            .storyCategoriesCache,
        stream: Provider.of<ContentRepositoryFirebase>(context).storyCategories,
        title: 'Before you start',
        errorMessage: 'No stories yet',
        itemBuilder: (item) {
          return StoryCard(
            storyData: item,
          );
        },
      ),
    );
  }
}
