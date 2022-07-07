import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/screens/profile/widgets/custom_dropdown_item.dart';
import 'package:meditation/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:meditation/util/notifications/notifications_utils.dart';

class CustomDropdown extends StatefulWidget {
  final bool showReminder;

  const CustomDropdown(this.showReminder);
  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  NotificationsFrequency _frequency = NotificationsFrequency.everyDay;

  String getStringFromFrequency(NotificationsFrequency frequency) {
    switch (frequency) {
      case NotificationsFrequency.everyDay:
        return 'Every day';
      case NotificationsFrequency.weekday:
        return 'Weekday';
      case NotificationsFrequency.weekend:
        return 'Weekend';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(11.5)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11.5),
                    bottomLeft: Radius.circular(11.5)),
                border: Border.all(color: primaryColor),
              ),
              height: 35.0,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<NotificationsFrequency>(
                    value: _frequency,
                    isExpanded: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: SvgPicture.asset(Images.icArrowDown,
                          color: textColor, height: 9.0, width: 9.0),
                    ),
                    dropdownColor: primaryColor,
                    onChanged: widget.showReminder
                        ? (value) {
                            setState(() {
                              _frequency = value;
                            });
                          }
                        : null,
                    items: NotificationsFrequency.values
                        .map((frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Center(
                                child: Text(
                                  getStringFromFrequency(frequency),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                    underline: SizedBox(),
                  ),
                ),
              ),
            ),
          ),
          CustomDropdownItem(
            backgroundColor: whiteColor.withOpacity(0.8),
            textColor: primaryColor,
            type: DropdownItemType.time,
            frequency: _frequency,
            showReminder: widget.showReminder,
          ),
        ],
      ),
    );
  }
}
