import 'package:flutter/cupertino.dart';

class AnimatedBackgroundImageWidget extends StatefulWidget {

  final String imageUrl;

  AnimatedBackgroundImageWidget({
    @required this.imageUrl
  });

  @override
  State createState() => AnimatedBackgroundImageWidgetState();

}

class AnimatedBackgroundImageWidgetState extends State<AnimatedBackgroundImageWidget> with SingleTickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this
    );
    animation = Tween<double>(begin: 1.0, end: 1.1).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      })
      ..addListener(() => setState(() { }));
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Image(
        image: NetworkImage(widget.imageUrl),
        fit: BoxFit.cover
      )
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

}
