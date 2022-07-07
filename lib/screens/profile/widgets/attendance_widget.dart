import 'package:flutter/material.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/util/color.dart';

class AttendanceWidget extends StatelessWidget {
  static const int _length = 7;
  final int minutes;

  AttendanceWidget(this.minutes);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35.0),
      padding:
          EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.03),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Strings.last7Days,
                style: TextStyle(
                  fontSize: 18.0,
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5.0),
              Text(
                Strings.minutes.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15.0),
              Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      _length,
                      (index) =>
                          _buildAttendanceCharacter(_length - 1 - index)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCharacter(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Text(
            minutes.toString().length > index
                ? minutes.toString()[minutes.toString().length - 1 - index]
                : '',
            style: TextStyle(
              fontSize: 20.0,
              color: grey2Color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            height: 2.0,
            width: 18.0,
            decoration: BoxDecoration(
              color: grey2Color,
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        ],
      ),
    );
  }
}
