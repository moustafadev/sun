import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:meditation/models/story_category.dart';
import 'package:meditation/models/story_item.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/screens/home/home_screen.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/slide_down_route.dart';

class StoryWidget extends StatefulWidget {
  static const String routeName = '/story-widget';
  final StoryCategory storyData;

  const StoryWidget({Key key, this.storyData}) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animController;
  ScrollController _scrollController;
  int _currentIndex = 0;
  List<StoryItem> stories = [];
  bool isStoped = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    _scrollController = ScrollController();
    stories = widget.storyData.storyItems;
    final StoryItem firstStory = stories.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < stories.length) {
            _currentIndex += 1;
            _loadStory(story: stories[_currentIndex]);
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here

            // Navigator.push(context, SlideDownRoute(page: HomeScreen()));
            // Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
            Navigator.pop(context);

            // _currentIndex = 0;
            // _loadStory(story: stories[_currentIndex]);
          }
        });
      }
    });
  }

  void _loadStory({StoryItem story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();

    _animController.duration = Duration(seconds: 5);
    _animController.forward();

    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTapDown(TapDownDetails details, StoryItem story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < stories.length) {
          _currentIndex += 1;
          _loadStory(story: stories[_currentIndex]);
        } else {
          // Out of bounds - loop story
          // You can also Navigator.of(context).pop() here

          // Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
          // Navigator.push(context, SlideDownRoute(page: HomeScreen()));

          Navigator.pop(context);

          // _currentIndex = 0;
          // _loadStory(story: stories[_currentIndex]);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StoryItem story = stories[_currentIndex];
    final screenSize = MediaQuery.maybeOf(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: HoldDetector(
        onCancel: () {
          _animController.forward();
        },
        onHold: () {
          _animController.stop();
        },
        holdTimeout: const Duration(milliseconds: 50),
        child: GestureDetector(
          onTapDown: (details) => _onTapDown(details, story),
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: stories.length,
                itemBuilder: (context, i) {
                  final StoryItem story = stories[i];
                  return CachedNetworkImage(
                    imageUrl: story.imageUrl,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Container(
                height: MediaQuery.maybeOf(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.grey.withOpacity(0.5),
                      Colors.grey.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: [0.1, 0.2, 0.3],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.maybeOf(context).size.height * 0.06,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: stories
                      .asMap()
                      .map((i, e) {
                        return MapEntry(
                          i,
                          AnimatedBar(
                            animController: _animController,
                            position: i,
                            currentIndex: _currentIndex,
                            storyData: widget.storyData,
                          ),
                        );
                      })
                      .values
                      .toList(),
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
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: screenSize.height * 0.1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 57.0,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Text(
                    story.caption,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: whiteColor,
                      height: 1.23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: screenSize.height * 0.08,
                  ),
                  height: MediaQuery.of(context).size.height * 0.47,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.1,
                      ),
                      child: Text(
                        story.description,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: whiteColor,
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.maybeOf(context).size.height * 0.04,
                    left: MediaQuery.maybeOf(context).size.width * 0.04,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.translucent,
                    child: SvgPicture.asset(
                      Images.icExit,
                      color: Color(0xffC4C4C4),
                      width: 38.0,
                      height: 38.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;
  final StoryCategory storyData;

  const AnimatedBar({
    Key key,
    @required this.animController,
    @required this.position,
    @required this.currentIndex,
    @required this.storyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: _buildContainer(
                      MediaQuery.maybeOf(context).size.width * 0.08,
                      position < currentIndex ? Colors.white.withOpacity(0.5) : Colors.white,
                      position,
                    ),
                  ),
                  position == currentIndex
                      ? AnimatedBuilder(
                          animation: animController,
                          builder: (context, child) {
                            return _buildContainer(
                              MediaQuery.maybeOf(context).size.width * 0.08 * animController.value,
                              Colors.blue,
                              position,
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color, int index) {
    return Container(
      height: 9.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          width: 2.0,
          color: index == currentIndex ? Color(0xff619CAD) : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
