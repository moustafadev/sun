import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/screens/home/widgets/recommendation_widget.dart';
import 'package:meditation/util/player/player_navigation_util.dart';
import 'package:provider/provider.dart';

class NoonLoopingCarousel extends StatefulWidget {
  final List<AudioItem> data;

  const NoonLoopingCarousel({Key key, this.data}) : super(key: key);

  @override
  _NoonLoopingCarouselState createState() => _NoonLoopingCarouselState();
}

class _NoonLoopingCarouselState extends State<NoonLoopingCarousel> {
  ContentRepositoryFirebase _repositoryFirebase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 1.22,
          enableInfiniteScroll: false,
          initialPage: 0,
          viewportFraction: 0.9,
        ),
        items: _buildRecommendations(widget.data),
      ),
    );
  }

  List<Widget> _buildRecommendations(List<AudioItem> audios) {
    List<Widget> sliderImages = [];
    PlayerNavigationUtil playerNavigationRepository = PlayerNavigationUtil();
    for (var audio in audios) {
      sliderImages.add(
        Container(
          margin: EdgeInsets.only(
            right: audios.indexOf(audio) != audios.length - 1
                ? MediaQuery.maybeOf(context).size.width * 0.015
                : 0,
            left: audios.indexOf(audio) != 0
                ? MediaQuery.maybeOf(context).size.width * 0.015
                : 0,
          ),
          child: RecommendationWidget(
            item: audio,
            heroTag:
                playerNavigationRepository.buildTag(audio, "recently_added"),
            onTap: (item) => playerNavigationRepository.navigateToAudio(
              item,
              playerNavigationRepository.buildTag(item, "recently_added"),
              context,
              _repositoryFirebase,
            ),
          ),
        ),
      );
    }
    return sliderImages;
  }
}
