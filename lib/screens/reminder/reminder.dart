import 'package:flutter/material.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/reminder/clock/clock.dart';
import 'package:meditation/util/color.dart';

class Reminder extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Clock(),
        ),
        SizedBox(height: 40),
        Text(
          Strings.reminderScreenHeader,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w100,
            color: whiteColor
          )
        ),
        SizedBox(height: 10),
        Text(
          Strings.dailyReminder,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: whiteColor
          )
        ),
        SizedBox(height: 20)
      ]
    );
  }

}
