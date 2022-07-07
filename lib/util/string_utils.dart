class StringUtils {
  String formatSeconds(int seconds, {String divider = " : "}) {
    int hours = seconds ~/ 3600;
    int minutes = seconds ~/ 60;

    String hoursStr = hours > 0 ? (hours % 60).toString().padLeft(2, '0') + divider : '';
    String minuteStr = (minutes % 60).toString().padLeft(2, '0');
    String secondStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr$minuteStr$divider$secondStr";
  }
}
