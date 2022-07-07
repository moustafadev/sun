import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/models/story_category.dart';
import 'package:meditation/models/story_item.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/screens/guide/widgets/page_indicator_widget.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/loading_widget.dart';

class TextGuideScreen extends StatefulWidget {
  final StoryCategory category;

  const TextGuideScreen({Key key, this.category}) : super(key: key);

  @override
  _TextGuideScreenState createState() => _TextGuideScreenState();
}

class _TextGuideScreenState extends State<TextGuideScreen> {
  List<StoryItem> _storyItems;
  Stream<int> getCurrentStoryIndex;
  PageController _controller = PageController(initialPage: 0);
  final PlayerManager playerManager = PlayerManager();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _storyItems = widget.category.storyItems;
    getCurrentStoryIndex = playerManager.getCurrentStoryIndex();
  }

  @override
  Widget build(BuildContext context) {
    if (_storyItems.length == 0) {
      return ErrorWidget('No items in story');
    }
    return Scaffold(
      body: Container(
        foregroundDecoration: BoxDecoration(),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.mainBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
            stream: getCurrentStoryIndex,
            initialData: 0,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              }
              return PageView.builder(
                itemCount: _storyItems.length,
                controller: _controller,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        child: Image(
                          image: NetworkImage(
                            _storyItems[index].getCoverImageFullPath(),
                          ),
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black12, Colors.black87],
                            stops: [0, 0.5],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32.0),
                          _buildPageIndicatorWidget(context, index),
                          Spacer(),
                          _buildTitleBoxWidget(_storyItems[index].caption),
                          const SizedBox(height: 27.0),
                          _buildTextWidget(
                              _storyItems[index].description, context),
                          const SizedBox(height: 60.0),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }

  Widget _buildPageIndicatorWidget(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.translucent,
            child: SvgPicture.asset(
              Images.icExit,
              color: Color(0xffC4C4C4),
              width: 38.0,
              height: 38.0,
            ),
          ),
          Expanded(
            child: Center(
              child: PageIndicatorWidget(
                count: _storyItems.length,
                selectedIndex: index,
              ),
            ),
          ),
          const SizedBox(width: 38.0),
        ],
      ),
    );
  }

  Widget _buildTitleBoxWidget(String caption) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 42.0),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 57.0),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Text(
        caption,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          color: whiteColor,
          height: 1.23,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextWidget(String description, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42.0),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16.0,
              color: whiteColor,
              fontWeight: FontWeight.w500,
              height: 1.44,
            ),
          ),
        ),
      ),
    );
  }
}
