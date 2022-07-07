import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalListWidget<T> extends StatelessWidget {

  final String title;
  final String errorMessage;
  final double width;
  final double height;
  final bool hideIfNoContent;
  final Stream stream;
  final Widget Function(T item) itemBuilder;

  HorizontalListWidget({
    @required this.title,
    @required this.errorMessage,
    @required this.width,
    @required this.height,
    @required this.stream,
    @required this.itemBuilder,
    this.hideIfNoContent = true
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      initialData: null,
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStreamWidget(
            _buildErrorWidget(errorMessage)
          );
        } else if (!snapshot.hasData) {
          return _buildStreamWidget(
            _buildLoadingWidget()
          );
        } else if (snapshot.data.isEmpty && hideIfNoContent) {
          return Container();
        } else {
          return _buildStreamWidget(
            _buildListWidget(snapshot.data)
          );
        }
      }
    );
  }

  Widget _buildStreamWidget(Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: _buildHeaderWidget(title)
        ),
        Container(
          height: height,
          child: content
        )
      ]
    );
  }

  Widget _buildHeaderWidget(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: whiteColor,
        letterSpacing: 1.4
      )
    );
  }

  Widget _buildLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: darkPrimaryColor,
      child: Center(
        child: Image.asset(
          Images.logoSimple,
          height: 100.0
        )
      )
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.red,
          fontSize: 16.0
        )
      )
    );
  }

  Widget _buildListWidget(List<T> data) {
    return ListView.separated(
      itemCount: data.length,
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          width: width,
          child: itemBuilder(item)
        );
      },
      separatorBuilder: (context, index) => SizedBox(width: 10.0)
    );
  }

}
