import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:shimmer/shimmer.dart';

class GridViewWidget<T> extends StatelessWidget {
  final String title;
  final String errorMessage;
  final double width;
  final double height;
  final bool hideIfNoContent;
  final Stream stream;
  final List<T> initialData;
  final Widget Function(T item) itemBuilder;
  final int itemsInLine;

  GridViewWidget({
    @required this.title,
    @required this.errorMessage,
    @required this.width,
    @required this.height,
    @required this.stream,
    @required this.itemBuilder,
    this.initialData,
    this.hideIfNoContent = true,
    this.itemsInLine = 2,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
        initialData: initialData,
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
            // return _buildStreamWidget(_buildLoadingWidget());
          }
          if (snapshot.hasError) {
            return _buildStreamWidget(_buildErrorWidget(errorMessage));
          } else if (!snapshot.hasData) {
            return Container();
            // return _buildStreamWidget(_buildLoadingWidget());
          } else if (snapshot.data.isEmpty && hideIfNoContent) {
            return Container();
          } else {
            return _buildListWidget(snapshot.data, itemsInLine, context);
          }
        });
  }

  Widget _buildStreamWidget(Widget content) {
    return Container(
      height: height,
      child: content,
    );
  }

  Widget _buildLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: darkPrimaryColor,
      child: Center(
        child: Image.asset(Images.logoSimple, height: 100.0),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red, fontSize: 16.0),
      ),
    );
  }

  Widget _buildListWidget(List<T> data, int itemsInLine, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final k = size.width / size.height;
    final kDefault = 375 / 812;
    final kFinal = k / kDefault;
    return GridView.count(
      padding: EdgeInsets.only(bottom: 10.0),
      shrinkWrap: true,
      primary: false,
      crossAxisCount: itemsInLine,
      crossAxisSpacing: size.height * 0.025,
      mainAxisSpacing: size.height * 0.02,
      childAspectRatio: 0.61 * kFinal,
      physics: ScrollPhysics(),
      children: List.generate(
        data.length,
        (index) {
          final item = data[index];

          return Container(
            width: width,
            child: itemBuilder(item),
          );
        },
      ),
    );
  }
}
