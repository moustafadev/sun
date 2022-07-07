import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/util/color.dart';

// ignore: must_be_immutable
class CustomSwitch extends StatefulWidget {
  final Color activeBgColor;
  final Color activeFgColor;
  final Color inactiveBgColor;
  final Color inactiveFgColor;
  final List<String> labels;
  final List<String> icons;
  final double height;
  final double fontSize;
  final double iconSize;
  final Function(int index) onToggle;
  final bool changeOnTap;
  final EdgeInsetsGeometry padding;
  int initialLabelIndex;

  CustomSwitch({
    Key key,
    this.labels,
    this.icons,
    this.activeBgColor = primaryColor,
    this.activeFgColor = textColor,
    this.inactiveBgColor = textColor,
    this.inactiveFgColor = primaryColor,
    this.onToggle,
    this.initialLabelIndex = 0,
    this.height = 24.0,
    this.changeOnTap = true,
    this.fontSize = 12.0,
    this.iconSize = 15.0,
    this.padding,
  }) : super(key: key);
  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(11.5)),
      child: Container(
        height: widget.height,
        color: widget.inactiveBgColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.labels != null ? widget.labels.length : widget.icons.length,
            (index) {
              final active = index == widget.initialLabelIndex;
              final fgColor =
                  active ? widget.activeFgColor : widget.inactiveFgColor;
              var bgColor = Colors.transparent;
              if (active) {
                bgColor = widget.activeBgColor;
              }

              return GestureDetector(
                onTap: () => _handleOnTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(11.5),
                    ),
                    border: active ? Border.all(color: primaryColor) : null,
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: widget.padding != null ? widget.padding : EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06,
                    ),
                    child: widget.labels != null
                        ? Text(
                            widget.labels[index],
                            style: TextStyle(
                              color: fgColor,
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SvgPicture.asset(
                            widget.icons[index],
                            color: fgColor,
                            height: widget.iconSize,
                            width: widget.iconSize,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleOnTap(int index) async {
    if (widget.changeOnTap) {
      setState(() => widget.initialLabelIndex = index);
    }
    if (widget.onToggle != null) {
      widget.onToggle(index);
    }
  }
}
