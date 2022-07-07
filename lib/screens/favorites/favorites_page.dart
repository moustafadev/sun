import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/core/extensions/categories_enum_extension.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/models/category.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/favorites/favorites_repository.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/player/audio_player_screen.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:meditation/util/string_utils.dart';
import 'package:meditation/widgets/custom_filter.dart';
import 'package:meditation/widgets/loading_widget.dart';
import 'package:meditation/widgets/stream_handler.dart';
import 'package:provider/provider.dart';
import 'package:meditation/core/extensions/audio_item_extension.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<PageType> _stubFilters = [
    PageType.guided,
    PageType.sleep,
    PageType.music,
  ];
  PageType _selectedStubFilter = PageType.guided;
  int currentTrack = 0;
  bool _isAudioPlaying = false;

  final FavoritesRepository favoritesRepository = FavoritesRepository();
  final HomeScreenNavigation navigation = HomeScreenNavigation();

  List<AudioItem> _favorites = [];
  List<Stream<List<CategoryItem>>> getCategoriesByType = [];
  List<AudioItem> tracksList = [];
  AudioPlayer player = AudioPlayer();

  bool checkCategoryInType(List<CategoryItem> categories, int index) {
    final res = categories.indexWhere(
      (element) => element.name == _favorites[index].categoryName,
    );
    return res != -1;
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.mainBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 45.0),
                _buildTitleWidget(),
                const SizedBox(height: 26.0),
                _buildFiltersWidget(),
                const SizedBox(height: 38.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: StreamHandler(
                      initial: Provider.of<ContentRepositoryFirebase>(context)
                          .categoriesCache,
                      stream: Provider.of<ContentRepositoryFirebase>(context)
                          .categories,
                      builder: (data) {
                        return FutureBuilder(
                          future: favoritesRepository.favourites,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return LoadingWidget();
                            _favorites = snapshot.data;
                            return _buildFavouritesList(data.data);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              navigation.changePageIndex(0);
            },
            child: SvgPicture.asset(
              Images.icBack,
              height: 32.0,
              width: 32.0,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Favorite tracks',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersWidget() {
    final filters = _stubFilters.map((e) => e.asProductionString()).toList();
    return CustomFilter(
      filters,
      (index) => _onFilterTap(index),
    );
  }

  void _onFilterTap(int index) {
    setState(() {
      _selectedStubFilter = _stubFilters[index];
    });
  }

  Widget _buildFavouritesList(List<CategoryItem> categories) {
    final categoriesData = categories
        .where((element) => element.type == _selectedStubFilter)
        .toList();
    tracksList = [];
    for (var i = 0; i < _favorites.length; i++) {
      if (checkCategoryInType(categoriesData, i)) {
        tracksList.add(_favorites[i]);
      }
    }

    if (tracksList.length == 0) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.maybeOf(context).size.height * 0.13),
        child: Center(
          child: Text(
            Strings.noFavorites,
            style: TextStyle(
                color: whiteColor,
                fontSize: MediaQuery.maybeOf(context).size.width * 0.07),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildFavouriteAudioWidget(
              tracksList[index],
              index,
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 17.0);
          },
          itemCount: tracksList.length,
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }

  Widget _buildFavouriteAudioWidget(AudioItem item, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async => await _onTrackSelect(item, index),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Text(
                  '${(index + 1).toString().padLeft(2, '0')}.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: whiteColor.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        if (currentTrack == index &&
                            AudioPlayersUtil.currentAudioUrl ==
                                item.getFileUrl() &&
                            AudioPlayerTask().playbackState.value.playing)
                          Image.asset(
                            Images.favouritesPlay,
                          )
                      ],
                    ),
                  ),
                ),
                FutureBuilder(
                  future: item.duration(),
                  initialData: const Duration(seconds: 0),
                  builder:
                      (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                    return Text(
                      StringUtils()
                          .formatSeconds(snapshot.data.inSeconds, divider: ":"),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: whiteColor.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Divider(
          thickness: 1,
          height: 1,
          color: currentTrack == index &&
                  AudioPlayersUtil.currentAudioUrl == item.getFileUrl() &&
                  AudioPlayerTask().playbackState.value.playing
              ? whiteColor
              : grey2Color.withOpacity(0.5),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Future<void> _onTrackSelect(AudioItem item, int index) async {
    setState(() {
      currentTrack = index;
    });
    await NavigationUtil().push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            AudioPlayerScreen(item: item, heroTag: item.id ?? item.name),
        settings: RouteSettings(
          name: AudioPlayerScreen.routeName,
        ),
      ),
    );
    setState(() {});
  }
}
