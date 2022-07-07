import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/widgets/locked_icon.dart';
import 'package:meditation/core/extensions/audio_item_extension.dart';

class RecommendationWidget extends StatefulWidget {
  final AudioItem item;
  final String heroTag;
  final Function(AudioItem item) onTap;

  RecommendationWidget({
    @required this.item,
    @required this.heroTag,
    @required this.onTap,
  });

  @override
  _RecommendationWidgetState createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  final PaymentStatus paymentStatusRepository = PaymentStatus();
  Stream<bool> paymentStatusStream;

  @override
  void initState() {
    super.initState();
    paymentStatusStream = paymentStatusRepository.getPaymentStatus();
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: const Offset(0, 1.0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      color: isLocked ? whiteColor.withOpacity(0.5) : null,
                      foregroundDecoration:
                          BoxDecoration(color: Colors.black54),
                      constraints: const BoxConstraints.expand(),
                      child: Image.network(
                        widget.item.getCoverImageFullPath(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  isLocked
                      ? LockedIcon()
                      : Center(
                          child: SvgPicture.asset(
                            Images.icPlay,
                            height: 56.0,
                            width: 56.0,
                          ),
                        ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: primary3Color.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 10.0),
                              constraints: const BoxConstraints(minHeight: 70),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.name,
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: whiteColor,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  FutureBuilder(
                                    future: widget.item.duration(),
                                    initialData: const Duration(seconds: 0),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data.inMinutes.toString() +
                                            ' min',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400,
                                          color: whiteColor,
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
