import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/util/color.dart';

class SubmitButton extends StatelessWidget {

  final String title;
  final bool enabled;
  final Function() onTap;

  SubmitButton({
    @required this.title,
    @required this.onTap,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 250,
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35)
          ),
          color: enabled ? submitButtonColor : submitButtonColor.withOpacity(0.5),
          elevation: 20.0,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontSize: 22.0,
                fontFamily: "roboto"
              )
            )
          )
        ),
        onTap: enabled ? onTap : null
      )
    );
  }

}
