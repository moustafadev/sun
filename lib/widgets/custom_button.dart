import 'package:flutter/material.dart';
import 'package:meditation/util/color.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool enabled;
  final Function() onTap;

  CustomButton(
      {@required this.title, @required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.maybeOf(context).size;
    return SizedBox(
      height: 28.0,
      child: TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.005,
              horizontal: screenSize.width * 0.036,
            ),
            backgroundColor: primaryColor.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(11.5)),
              side: BorderSide(color: primaryColor),
            )),
        child: Container(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                // fontWeight: FontWeight.w800,
                color: textColor,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
