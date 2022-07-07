import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/widgets/locked_icon.dart';

class MusicWidget extends StatefulWidget {
  final AudioItem item;
  final String heroTag;
  final Function(AudioItem item) onTap;

  MusicWidget(
      {@required this.item, @required this.heroTag, @required this.onTap});

  @override
  _MusicWidgetState createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget> {
  final PlayerManager playerManager = PlayerManager();
  final PaymentStatus paymentStatusRepository = PaymentStatus();
  Stream<bool> paymentStatusStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AudioPlayersUtil.changeBgAudioIndex(playerManager.backgroundAudio,
          isInit: true);
    });
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
          child: StreamBuilder(
            stream: playerManager.getBackgroundAudio(),
            builder: (context, AsyncSnapshot<AudioItem> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  border: snapshot.hasData && snapshot.data.id == widget.item.id
                      ? Border.all(
                          color: Colors.blue,
                          width: 2,
                        )
                      : null,
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
                          foregroundDecoration:
                              BoxDecoration(color: Colors.black54),
                          constraints: const BoxConstraints.expand(),
                          child: widget.item.getCoverImageFullPath() != null
                              ? Image.network(
                                  widget.item.getCoverImageFullPath(),
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                        ),
                      ),
                      if (isLocked)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          child: LockedIcon(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            color: primary3Color.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            constraints: const BoxConstraints(minHeight: 70),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.item.name,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: whiteColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
