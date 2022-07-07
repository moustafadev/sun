import 'package:flutter/material.dart';
import 'package:meditation/util/color.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool enabled;
  final Function() onTap;
  final Color color;

  CustomButton({
    @required this.title,
    @required this.onTap,
    this.enabled = true,
    this.color = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          enabled ? color : color.withOpacity(0.6),
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        )),
      ),
      onPressed: enabled ? onTap : null,
      child: Container(
        height: 55.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: whiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
