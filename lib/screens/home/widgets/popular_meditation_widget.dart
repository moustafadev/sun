import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/locked_icon.dart';

class PopularMeditationWidget extends StatefulWidget {
  final AudioItem item;
  final double width;
  final String heroTag;
  final Function(AudioItem item) onTap;

  PopularMeditationWidget({
    @required this.item,
    @required this.heroTag,
    @required this.width,
    @required this.onTap,
  });

  @override
  _PopularMeditationWidgetState createState() => _PopularMeditationWidgetState();
}

class _PopularMeditationWidgetState extends State<PopularMeditationWidget> {
  final PaymentStatus paymentStatusRepository = PaymentStatus();
  Stream<bool> paymentStatusStream;
  @override
  void initState() {
    super.initState();
    paymentStatusStream = paymentStatusRepository.getPaymentStatus();
  }

  @override
  Widget build(BuildContext context) {
    double widgetWidth = 90;

    if (widget.width > widgetWidth) {
      widgetWidth = widget.width;
    }

    return StreamBuilder(
      stream: paymentStatusStream,
      initialData: paymentStatusRepository.paymentStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final isLocked = paymentStatusRepository.isLocked(
          snapshot.data,
          widget.item.isPaid,
        );
        return InkWell(
          onTap: () {
            widget.onTap(widget.item);
          },
          child: Container(
            width: widgetWidth,
            child: Column(
              children: [
                Container(
                  width: widgetWidth,
                  height: widgetWidth,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: const Offset(0, 1.0)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: widgetWidth,
                        width: widgetWidth,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                          child: Image.network(
                            widget.item.getCoverImageFullPath(),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      if (isLocked)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: widgetWidth,
                            child: LockedIcon(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  widget.item.categoryName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3.0),
                Text(
                  "\"${widget.item.name}\"",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
