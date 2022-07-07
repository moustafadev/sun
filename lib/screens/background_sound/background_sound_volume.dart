import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/resources/shared_prefs_keys.dart';
import 'package:meditation/widgets/custom_switch.dart';

import 'background_sound_slider.dart';

class BackgroundSoundVolume extends StatefulWidget {
  final bool showBackIcon;

  const BackgroundSoundVolume({Key key, this.showBackIcon = false})
      : super(key: key);
  @override
  _BackgroundSoundVolumeState createState() => _BackgroundSoundVolumeState();
}

class _BackgroundSoundVolumeState extends State<BackgroundSoundVolume> {
  int bgSoundMutedIndex = 0;
  Preferences prefs = Preferences();
  bool muteStatus = false;
  final HomeScreenNavigation navigation = HomeScreenNavigation();

  @override
  void initState() {
    super.initState();
    getMuteStatus();
  }

  Future<void> getMuteStatus() async {
    muteStatus = await prefs.getBool(muteBackground, false);
    setState(() {
      bgSoundMutedIndex = muteStatus ? 1 : 0;
    });
  }

  Future<void> setMuteStatus(int index) async {
    final value = index == 0 ? true : false;
    muteStatus = await prefs.setBool(muteBackground, value);
    bgSoundMutedIndex = muteStatus ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showBackIcon)
                GestureDetector(
                  child: SvgPicture.asset(
                    Images.icBack,
                    height: screenSize.width * 0.073,
                    width: screenSize.width * 0.073,
                  ),
                  onTap: () {
                    navigation.changePageIndex(0);
                  },
                ),
              if (widget.showBackIcon)
                SizedBox(
                  width: screenSize.width * 0.025,
                ),
              Text(
                'Background volume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.052,
                ),
              ),
              Spacer(),
              CustomSwitch(
                activeBgColor: primaryColor.withOpacity(0.8),
                inactiveBgColor: textColor,
                activeFgColor: textColor,
                inactiveFgColor: primaryColor,
                icons: [Images.icSoundOn, Images.icSoundOff],
                initialLabelIndex: bgSoundMutedIndex,
                iconSize: screenSize.width * 0.03,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                ),
                onToggle: (index) async {
                  await setMuteStatus(bgSoundMutedIndex);
                  setState(() {
                    bgSoundMutedIndex = index;
                  });
                  index == 0
                      ? AudioPlayersUtil.bgSoundPlayer.setVolume(0.5)
                      : AudioPlayersUtil.bgSoundPlayer.setVolume(0);
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.04,
        ),
        BackgroundSoundSlider(
          isMuted: bgSoundMutedIndex == 0 ? false : true,
        ),
      ],
    );
  }
}
