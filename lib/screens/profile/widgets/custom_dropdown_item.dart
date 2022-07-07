import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/notifications/notifications_utils.dart';
import '../../../core/extensions/notifications_frequency_extension.dart';
import 'package:intl/intl.dart' as intl;

enum DropdownItemType {
  frequency,
  time,
}

class CustomDropdownItem extends StatefulWidget {
  final Color textColor;
  final Color backgroundColor;
  final DropdownItemType type;
  final NotificationsFrequency frequency;
  final bool showReminder;

  const CustomDropdownItem({
    Key key,
    this.textColor,
    this.backgroundColor,
    this.type,
    this.frequency,
    this.showReminder,
  }) : super(key: key);

  @override
  _CustomDropdownItemState createState() => _CustomDropdownItemState();
}

class _CustomDropdownItemState extends State<CustomDropdownItem> {
  NotificationsUtils _notificationsUtils = NotificationsUtils();
  DateTime _time = DateTime.now();

  String getTimePlaceholder(DateTime date) {
    String newDate = intl.DateFormat.jm().format(date);
    return newDate;
  }

  @override
  Widget build(BuildContext context) {
    final isFrequency = widget.type == DropdownItemType.frequency;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
        ),
        height: 35.0,
        child: Directionality(
          textDirection: isFrequency ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            height: 100,
            child: ButtonTheme(
              // alignedDropdown: true,
              child: DropdownButton(
                itemHeight: MediaQuery.of(context).size.height * 0.15,
                isExpanded: true,
                onChanged: widget.showReminder ? (value) {} : null,
                icon: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: SvgPicture.asset(
                    Images.icArrowDown,
                    color: textColor,
                    height: 9.0,
                    width: 9.0,
                  ),
                ),
                dropdownColor: whiteColor,
                hint: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 9.0,
                      width: 9.0,
                    ),
                    Text(
                      getTimePlaceholder(_time),
                      style: TextStyle(color: widget.textColor),
                    ),
                    SvgPicture.asset(
                      Images.icArrowDown,
                      color: widget.textColor,
                      height: 9.0,
                      width: 9.0,
                    ),
                  ],
                ),
                items: [
                  DropdownMenuItem(
                    value: '1',
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.maybeOf(context).size.height * 0.01,
                              ),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (value) {
                                  _time = value;
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: MediaQuery.maybeOf(context).size.width * 0.06,
                                ),
                                child: Container(
                                  height: MediaQuery.maybeOf(context).size.height * 0.03,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                                    ),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        fontSize: MediaQuery.maybeOf(context).size.width * 0.03,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final res = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Warning'),
                                            content: Text(
                                              'Do you really want to set reminder ${widget.frequency.notificationView()} at ${getTimePlaceholder(_time)} ?',
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('Ok'),
                                                onPressed: () {
                                                  Navigator.of(context).pop('ok');
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (res == 'ok') {
                                        Navigator.maybeOf(context).pop();
                                        setState(() {});
                                        await _notificationsUtils.setReminder(
                                          Time(_time.hour, _time.minute, _time.second),
                                          widget.frequency,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
                underline: SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
