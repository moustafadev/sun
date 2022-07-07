import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditation/util/color.dart';
import '../../../core/extensions/days_extension.dart';

class CustomRoundedBars extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  CustomRoundedBars(this.seriesList, {this.animate});

  /// Creates a [BarChart] with custom rounded bars.
  factory CustomRoundedBars.withSampleData() {
    return new CustomRoundedBars(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.BarRendererConfig(
        cornerStrategy: const charts.ConstCornerStrategy(30),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TotalListened, String>> _createSampleData() {
    final data = [
      new TotalListened(Day.monday.short(), 5),
      new TotalListened(Day.tuesday.short(), 7),
      new TotalListened(Day.wednesday.short(), 10),
      new TotalListened(Day.thursday.short(), 5),
      new TotalListened(Day.friday.short(), 11),
      new TotalListened(Day.saturday.short(), 5),
      new TotalListened(Day.sunday.short(), 5),
    ];

    return [
      new charts.Series<TotalListened, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TotalListened sales, _) => sales.day,
        measureFn: (TotalListened sales, _) => sales.minutes,
        data: data,
        fillColorFn: (datum, index) {
          return charts.Color(
            r: primaryColor.red,
            g: primaryColor.green,
            b: primaryColor.blue,
            a: primaryColor.alpha,
          );
        },
      )
    ];
  }
}

/// Sample ordinal data type.
class TotalListened {
  final String day;
  final int minutes;

  TotalListened(this.day, this.minutes);
}
