import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubscriptionPriceWidget extends StatelessWidget {

  final String days;
  final String price;
  final String format;
  final double pricePerYearSize;

  SubscriptionPriceWidget({
    @required this.price,
    @required this.format,
    @required this.pricePerYearSize,
    this.days = ""
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: RichText(
        text: _buildTextSpan(),
        textAlign: TextAlign.center
      )
    );
  }

  TextSpan _buildTextSpan() {
    TextStyle baseStyle = TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.w200,
      fontFamily: "roboto"
    );
    try {
      final pricePerYearKey = '\$pricePerYear';
      final formatWithDays = _replaceDays(format);
      final indexOfPricePerYearInFormat = formatWithDays.indexOf(pricePerYearKey);
      if (indexOfPricePerYearInFormat > -1) {
        String prefix = formatWithDays.substring(
          0, indexOfPricePerYearInFormat
        );
        String postfix = formatWithDays.substring(
          indexOfPricePerYearInFormat + pricePerYearKey.length
        );
        return TextSpan(
          children: [
            TextSpan(text: prefix),
            _costPerYearTextSpan(),
            TextSpan(text: postfix)
          ],
          style: baseStyle
        );
      } else {
        return TextSpan(
          text: formatWithDays,
          style: baseStyle
        );
      }
    } catch (e) {
      print(e);
      return TextSpan();
    }
  }

  String _replaceDays(String str) {
    return str.replaceFirst('\$days', days);
  }

  TextSpan _costPerYearTextSpan() {
    final costPerYear = (price?.isNotEmpty ?? false) ? price : "XX";
    final costPerYearPart = "$costPerYear per year";
    return TextSpan(
      text: costPerYearPart,
      style: TextStyle(fontSize: pricePerYearSize)
    );
  }

}
