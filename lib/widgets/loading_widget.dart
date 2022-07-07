import 'package:flutter/material.dart';
import 'package:meditation/resources/images.dart';
import 'package:shimmer/shimmer.dart';
import 'package:meditation/util/color.dart';


class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: darkPrimaryColor,
      child: Center(
        child: Image.asset(Images.logoSimple, height: 100.0),
      ),
    );
  }
}