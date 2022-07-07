import 'package:flutter/material.dart';
import 'package:meditation/core/extensions/categories_enum_extension.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/util/player/player_navigation_util.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/music/widgets/grid_view_widget.dart';
import 'package:meditation/screens/music/widgets/music_widget.dart';
import 'package:provider/provider.dart';

class CategoriesList extends StatefulWidget {
  final String categoryId;
  final PageType pageType;
  final Key key;

  CategoriesList(this.pageType, {this.categoryId, this.key});

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final PlayerNavigationUtil playerNavigationRepository =
      PlayerNavigationUtil();
  ContentRepositoryFirebase _repositoryFirebase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width / 2) - 40.0;
    double height = width * 1.6;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
      ),
      child: GridViewWidget<AudioItem>(
        width: width,
        height: height,
        initialData: Provider.of<ContentRepositoryFirebase>(context).categoryAudiosCache[widget.categoryId] ?? [],
        stream: Provider.of<ContentRepositoryFirebase>(context).categoryAudios(widget.categoryId),
        title: Strings.recentlyAdded,
        errorMessage: Strings.recentlyAddedLoadingError,
        itemsInLine: 2,
        itemBuilder: (item) {
          return MusicWidget(
            item: item,
            heroTag: '',
            onTap: (item) => playerNavigationRepository.navigateToAudio(
              item,
              playerNavigationRepository.buildTag(item),
              context,
              _repositoryFirebase,
            ),
          );
        },
      ),
    );
  }
}
