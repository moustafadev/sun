import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/repositories/player/player_manager.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BackgroundSoundSlider extends StatefulWidget {
  final double ratio;
  final bool isMuted;

  BackgroundSoundSlider({this.ratio = 1, this.isMuted = false})
      : assert(ratio > 0 && ratio <= 1);
  @override
  _BackgroundSoundSliderState createState() => _BackgroundSoundSliderState();
}

class _BackgroundSoundSliderState extends State<BackgroundSoundSlider> {
  final PlayerManager playerManager = PlayerManager();

  Stream<AudioPlayer> getBgSound;
  Stream<double> getVolumeValue;
  AudioPlayer player;

  Future<void> onVolumeChanged(double value) async {
    playerManager.changeVolumeValue(value);
    if (!widget.isMuted) {
      AudioPlayersUtil.bgSoundPlayer.setVolume(value / 100.0);
    }
  }

  @override
  void initState() {
    super.initState();
    getVolumeValue = playerManager.getVolumeValue();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return StreamBuilder(
      stream: getVolumeValue,
      initialData: playerManager.volumeValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return IntrinsicHeight(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  Images.icSoundOn,
                  color: Color.fromRGBO(146, 152, 154, 1),
                  width: mediaQuery.size.height * 0.04 * widget.ratio,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: mediaQuery.size.height * 0.2 * widget.ratio,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        startAngle: 270,
                        endAngle: 270,
                        showLabels: false,
                        showTicks: false,
                        radiusFactor: 1,
                        axisLineStyle: AxisLineStyle(
                          cornerStyle: CornerStyle.bothFlat,
                          color: Color.fromRGBO(95, 101, 104, 1),
                          thickness: 25 * widget.ratio,
                        ),
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: snapshot.data,
                            cornerStyle: CornerStyle.bothFlat,
                            width: 25 * widget.ratio,
                            sizeUnit: GaugeSizeUnit.logicalPixel,
                            color: primaryColor.withOpacity(0.8),
                          ),
                          MarkerPointer(
                            color: whiteColor,
                            value: snapshot.data,
                            enableDragging: true,
                            onValueChanged: onVolumeChanged,
                            markerHeight: 28 * widget.ratio,
                            markerWidth: 28 * widget.ratio,
                            markerType: MarkerType.circle,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
