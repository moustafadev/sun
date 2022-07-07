import 'package:audio_service/audio_service.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jiffy/jiffy.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/favorites/favorites_repository.dart';
import 'package:meditation/repositories/home_screen/home_screen_navigation.dart';
import 'package:meditation/repositories/local/local_repository.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/player/player_navigation_util.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/background_sound/background_sound_slider.dart';
import 'package:meditation/screens/music/widgets/music_widget.dart';
import 'package:meditation/screens/profile/widgets/custom_dropdown.dart';
import 'package:meditation/screens/profile/widgets/attendance_widget.dart';
import 'package:meditation/screens/profile/widgets/custom_rounded_bar.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/resources/shared_prefs_keys.dart';
import 'package:meditation/util/notifications/notifications_utils.dart';
import 'package:meditation/widgets/custom_button.dart';
import 'package:meditation/widgets/custom_switch.dart';
import 'package:meditation/widgets/horizontal_list_widget.dart';
import 'package:meditation/core/extensions/days_extension.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // int _stubMinutes = 0;
  int _currentWeek = 0;
  bool _showReminder = true;
  bool _isAudioPlaying = false;

  Stream<bool> paymentStatusStream;

  final LocalRepository favoritesRepository = FavoritesRepository();
  final PlayerNavigationUtil playerNavigationRepository = PlayerNavigationUtil();
  final HomeScreenNavigation navigation = HomeScreenNavigation();
  final Preferences prefs = Preferences();
  final PaymentStatus paymentStatusRepository = PaymentStatus();
  ContentRepositoryFirebase _repositoryFirebase;

  Future<void> updateAttendance() async {
    for (var day in Day.values) {
      prefs.setInt(day.asString(), 0);
    }
    prefs.setInt(totalListenedMinutes, 0);
  }

  Future<void> checkCurrentWeek() async {
    final value = await prefs.getInt(currentWeekNumber, 0);
    prefs.setInt(currentWeekNumber, Jiffy().week);
    if (value == 0) {
      _currentWeek = Jiffy().week;
    } else {
      _currentWeek = value;
    }
    if (_currentWeek != Jiffy().week) {
      await updateAttendance();
    }
  }

  Future<void> getReminderState() async {
    _showReminder = await prefs.getBool(showReminder, false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    paymentStatusStream = paymentStatusRepository.getPaymentStatus();
    checkCurrentWeek();
    getReminderState();
    AudioPlayerTask().playbackState.listen((event) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = event.processingState != AudioProcessingState.idle;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  Future<List<charts.Series<TotalListened, String>>> _createChartData() async {
    List<TotalListened> data = [];
    for (var day in Day.values) {
      final minutes = await prefs.getInt(day.asString(), 0);
      data.add(TotalListened(day.short(), (minutes / 60).round()));
    }

    return [
      charts.Series<TotalListened, String>(
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

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.maybeOf(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 23.0),
          _buildAttendanceWidget(),
          const SizedBox(height: 23.0),
          _buildFavouritesWidget(),
          const SizedBox(height: 25.0),
          _buildVolumeWidget(),
          const SizedBox(height: 25.0),
          _buildReminderWidget(),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget _buildAttendanceWidget() {
    return GestureDetector(
      child: FutureBuilder(
        future: prefs.getInt(totalListenedMinutes, 0),
        initialData: 0,
        builder: (context, snapshot) {
          return AttendanceWidget((snapshot.data / 60).round());
        },
      ),
      onTap: () async {
        final res = await _createChartData();
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Container(
                width: double.infinity,
                child: Text(
                  'Minutes',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.9,
                child: CustomRoundedBars(res),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavouritesWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Strings.myFavorites,
                style: TextStyle(
                  fontSize: 20.0,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5.0),
              Icon(
                Icons.favorite,
                color: textColor,
                size: 20,
              ),
              Spacer(),
              CustomButton(title: Strings.seeAll, onTap: _onSeeAllTap),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          HorizontalListWidget<AudioItem>(
            width: MediaQuery.of(context).size.width * 0.37,
            height: MediaQuery.of(context).size.height * 0.27,
            stream: favoritesRepository.getAll().asStream(),
            errorMessage: Strings.recentlyAddedLoadingError,
            itemBuilder: (item) {
              return MusicWidget(
                item: item,
                heroTag: playerNavigationRepository.buildTag(item, "recently_added"),
                onTap: (item) async {
                  await playerNavigationRepository.navigateToAudio(
                    item,
                    playerNavigationRepository.buildTag(item, "recently_added"),
                    context,
                    _repositoryFirebase,
                  );
                  setState(() {});
                },
              );
            },
            headerVisible: false,
          ),
        ],
      ),
    );
  }

  void _onSeeAllTap() {
    navigation.changePageIndex(6);
  }

  Widget _buildVolumeWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Strings.backgroundVolume,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              CustomButton(
                title: Strings.backgroundSounds,
                onTap: _onBackgroundSoundsTap,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          BackgroundSoundSlider(ratio: 0.65),
        ],
      ),
    );
  }

  void _onBackgroundSoundsTap() {
    navigation.changePageIndex(5);
  }

  Widget _buildReminderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Strings.remindAboutMeditation,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomSwitch(
                activeBgColor: primaryColor.withOpacity(0.8),
                inactiveBgColor: textColor,
                activeFgColor: textColor,
                inactiveFgColor: primaryColor,
                labels: ['yes', 'no'],
                initialLabelIndex: _showReminder ? 0 : 1,
                changeOnTap: false,
                onToggle: (index) {
                  print('switched to: $index');
                  _onReminderToggle(index);
                },
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          Text(
            Strings.selectFrequencyAndTime,
            style: TextStyle(
              color: textColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 15.0),
          Opacity(
            opacity: _showReminder ? 1 : 0.5,
            child: CustomDropdown(_showReminder),
          ),
        ],
      ),
    );
  }

  Future<void> _onReminderToggle(int value) async {
    NotificationsUtils _notificationsUtils = NotificationsUtils();
    if (value == 1) {
      final res = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text(
              'Do you really want to remove reminder?',
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
        setState(() {
          _showReminder = false;
        });
        await _notificationsUtils.cancelReminder();
      }
    } else {
      final res = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text(
              'Set time and frequency to set reminder!',
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
        setState(() {
          _showReminder = true;
        });
      }
    }
    await prefs.setBool(showReminder, _showReminder);
  }
}
