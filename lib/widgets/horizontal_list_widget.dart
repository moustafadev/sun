import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/custom_button.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalListWidget<T> extends StatelessWidget {
  final String title;
  final String errorMessage;
  final double width;
  final double height;
  final bool hideIfNoContent;
  final Stream stream;
  final Widget Function(T item) itemBuilder;
  final double headerPadding;
  final bool headerButton;
  final String buttonText;
  final Function onButtonTap;
  final bool headerVisible;
  final List<T> audios;
  final List<T> initialData;

  HorizontalListWidget({
    @required this.errorMessage,
    @required this.width,
    @required this.height,
    @required this.itemBuilder,
    this.stream,
    this.audios,
    this.title,
    this.hideIfNoContent = true,
    this.headerPadding = 16.0,
    this.headerButton = false,
    this.buttonText,
    this.onButtonTap,
    this.headerVisible = true,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    if (audios != null) {
      return _buildStreamWidget(_buildListWidget(audios));
    }
    return StreamBuilder<List<T>>(
      initialData: initialData,
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStreamWidget(_buildErrorWidget(errorMessage));
        } else if (!snapshot.hasData) {
          return _buildStreamWidget(_buildLoadingWidget());
        } else if (snapshot.data.isEmpty && hideIfNoContent) {
          return Container();
        } else {
          return _buildStreamWidget(_buildListWidget(snapshot.data));
        }
      },
    );
  }

  Widget _buildStreamWidget(Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (headerVisible) ...[
          _buildHeaderWidget(title),
          SizedBox(height: headerPadding),
        ],
        Container(
          height: height,
          child: content,
        ),
      ],
    );
  }

  Widget _buildHeaderWidget(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: whiteColor,
            ),
          ),
        ),
        if (headerButton && buttonText != null && onButtonTap != null)
          CustomButton(
            title: buttonText,
            onTap: () => onButtonTap(),
          ),
      ],
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

  Widget _buildListWidget(List<T> data) {
    return ListView.separated(
        itemCount: data.length,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = data[index];
          return Container(width: width, child: itemBuilder(item));
        },
        separatorBuilder: (context, index) => const SizedBox(width: 11.0));
  }
}
