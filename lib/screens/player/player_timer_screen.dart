import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/player/models/player_countdown_timer.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/string_utils.dart';

class PlayerTimerScreen extends StatefulWidget {

  final PlayerCountdownTimer prevTimerSetup;

  PlayerTimerScreen({
    this.prevTimerSetup
  });

  @override
  State<StatefulWidget> createState() => PlayerTimerScreenState();

}

class PlayerTimerScreenState extends State<PlayerTimerScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedDurationMinutes = 0;

  PlayerCountdownTimer _timer;
  int _timerTimeSeconds = 0;

  final List<int> timersMinutes = [
    15, 30, 45, 60
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prevTimerSetup != null) {
      selectedDurationMinutes = widget.prevTimerSetup.durationsMinutes;
      _setupTimer(widget.prevTimerSetup);
    }
  }

  void _setupTimer(PlayerCountdownTimer timer) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = timer;
    _timer.start(
      onTick: (time) {
        setState(() {
          _timerTimeSeconds = time;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.mainBackground),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            _buildBackButtonWidget(),
            SizedBox(height: 40),
            _buildTimeWidget(),
            SizedBox(height: 20),
            _buildTurnOffButton(),
            _buildTimersWidget(),
            SizedBox(height: 40.0)
          ]
        )
      )
    );
  }

  Widget _buildBackButtonWidget() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: 60.0,
              height: 60.0,
              child: RawMaterialButton(
                shape: CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    Images.backIconSvg,
                    color: Colors.white
                  )
                ),
                elevation: 0.0,
                onPressed: () {
                  dispose();
                  Navigator.pop(context, selectedDurationMinutes > 0 ? _timer : null);
                }
              )
            )
          )
        ),
        Center(
          child: Text(
            Strings.timer,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.w300
            )
          )
        )
      ]
    );
  }

  Widget _buildTimeWidget() {
    return Center(
      child: Text(
        StringUtils().formatSeconds(_timerTimeSeconds, divider: ":"),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 70.0,
          color: Colors.white,
          fontWeight: FontWeight.w100
        )
      )
    );
  }

  Widget _buildTurnOffButton() {
    return SizedBox(
      height: 50.0,
      child: Visibility(
        visible: selectedDurationMinutes > 0,
        child: Center(
          child: InkWell(
            onTap: _onTurnOffTimerClick,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                color: primaryColor.withAlpha(200)
              ),
              child: Text(
                Strings.turnOff,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w100
                )
              )
            )
          )
        )
      )
    );
  }
  
  void _onTurnOffTimerClick() {
    if (_timer != null) {
      _timer.cancel();
    }
    setState(() {
      selectedDurationMinutes = 0;
      _timerTimeSeconds = 0;
    });
  }

  Widget _buildTimersWidget() {
    return Expanded(
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final item = timersMinutes[index];
            return InkWell(
              onTap: () => _onTimerItemClick(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0
                ),
                child: Center(
                  child: Text(
                    "$item ${Strings.minutes}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0
                    )
                  )
                )
              )
            );
          },
          itemCount: timersMinutes.length,
        )
      )
    );
  }

  void _onTimerItemClick(int item) {
    setState(() {
      this.selectedDurationMinutes = item;
      this._timerTimeSeconds = item * 60;
    });
    _setupTimer(PlayerCountdownTimer(
      startTimeSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      durationsMinutes: item
    ));
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

}
