import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {

  final Widget icon;
  final Function onPressed;
  final EdgeInsets padding;

  CircleIconButton({
    @required this.icon,
    @required this.onPressed,
    this.padding = const EdgeInsets.all(15.0)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: RawMaterialButton(
        shape: CircleBorder(),
        child: Padding(
          padding: padding,
          child: icon
        ),
        fillColor: Colors.black.withOpacity(0.15),
        elevation: 0.0,
        onPressed: onPressed
      )
    );
  }

}
