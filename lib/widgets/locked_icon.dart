import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';

class LockedIcon extends StatelessWidget {
  const LockedIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor.withOpacity(0.5),
      child: Center(
        child: SvgPicture.asset(
          Images.lock,
          height: MediaQuery.maybeOf(context).size.width * 0.15,
          width: MediaQuery.maybeOf(context).size.width * 0.15,
          color: whiteColor,
        ),
      ),
    );
  }
}
