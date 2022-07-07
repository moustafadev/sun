import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/util/color.dart';

class SubmitSmallButton extends StatelessWidget {

  final String title;
  final bool enabled;
  final Function() onTap;

  SubmitSmallButton({
    @required this.title,
    @required this.onTap,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 150,
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)
          ),
          color: enabled ? smallSubmitButtonColor : smallSubmitButtonColor.withOpacity(0.25),
          elevation: 0.0,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: enabled ? Colors.white : Colors.white38,
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
