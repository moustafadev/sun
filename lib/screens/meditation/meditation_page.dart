import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meditation/core/extensions/categories_enum_extension.dart';
import 'package:meditation/models/category.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/screens/home/widgets/categories_list.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/widgets/custom_filter.dart';
import 'package:meditation/widgets/loading_widget.dart';
import 'package:meditation/widgets/stream_handler.dart';
import 'package:provider/provider.dart';

class MeditationPage extends StatefulWidget {
  final Function onBackButtonTap;

  const MeditationPage({Key key, this.onBackButtonTap}) : super(key: key);
  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  String categoryId = '';
  bool isInitialized = false;
  bool _isAudioPlaying = false;
  final HomeScreenNavigation navigation = HomeScreenNavigation();

  void _onFilterTap(int index, List<CategoryItem> categories) {
    setState(() {
      categoryId = categories[index].id;
    });
  }

  @override
  void initState() {
    AudioPlayerTask().playbackState.listen((event) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = event.processingState != AudioProcessingState.idle;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesListWidget = Container(
      key: Key(categoryId),
      child: CategoriesList(
        PageType.guided,
        categoryId: categoryId,
      ),
    );
    final MediaQueryData mediaQuery = MediaQuery.maybeOf(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),
        _buildTitleWidget(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        StreamHandler(
          initial: Provider.of<ContentRepositoryFirebase>(context)
                  .categoriesByTypeCache[PageType.guided.asString()] ??
              [],
          stream: Provider.of<ContentRepositoryFirebase>(context)
              .categoriesByType(PageType.guided),
          builder: (data) {
            if (data.data.isEmpty) return LoadingWidget();
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                if (!isInitialized) {
                  if (mounted)
                    setState(() {
                      categoryId = data.data[0].id;
                      isInitialized = true;
                    });
                }
              },
            );
            return CustomFilter(
              data.data.map((e) => e.name).toList(),
              (index) => _onFilterTap(index, data.data),
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        if (categoryId.isNotEmpty)
          Container(
            child: Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 100),
                child: categoriesListWidget,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: SvgPicture.asset(
              Images.icBack,
              height: 32.0,
              width: 32.0,
            ),
            onTap: widget.onBackButtonTap,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Guided Mediation',
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
}
