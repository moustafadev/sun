import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/payment/subscription_screen.dart';
import 'package:meditation/screens/player/audio_player_screen.dart';
import 'package:meditation/screens/payment/subscription_dialogs.dart';
import 'package:meditation/screens/user/content/user_content_screen.dart';
import 'package:meditation/util/global/navigation_util.dart';

class PlayerNavigationUtil {
  final Preferences preferences = Preferences();

  Future navigateToAudio(AudioItem item, String tag, BuildContext context,
      ContentRepositoryFirebase repositoryFirebase) async {
    PaymentStatus paymentStatus = PaymentStatus();
    final isLocked =
        paymentStatus.isLocked(paymentStatus.paymentStatus, item.isPaid);
    if (!repositoryFirebase.configCache.showSubscribeScreen && isLocked) {
      ScaffoldMessenger.maybeOf(context).showSnackBar(
        SnackBar(
          content: Text(Strings.errorOccured),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (isLocked) {
      await NavigationUtil().push(
        context,
        MaterialPageRoute(
          builder: (context) => UserContentScreen(
            isOffer: true,
          ),
          settings: RouteSettings(
            name: UserContentScreen.routeName,
          ),
        ),
      );
    } else {
      return await NavigationUtil().push(
        context,
        CupertinoPageRoute(
          builder: (context) => AudioPlayerScreen(item: item, heroTag: tag),
          settings: RouteSettings(
            name: AudioPlayerScreen.routeName,
          ),
        ),
      );
    }
  }

  String buildTag(AudioItem item, [String prefix = ""]) {
    return "$prefix${item.id ?? ""}${item.name ?? ""}";
  }

  // Future navigateToSubscriptionScreen(BuildContext context) async {
  //   final result = await Navigator.push(
  //     context,
  //     CupertinoPageRoute(builder: (context) => SubscriptionScreen()),
  //   );
  //   if (result != null) {
  //     if (result is bool) {
  //       if (result) {
  //         showSuccessSubscriptionPaymentDialog(context);
  //       } else {
  //         Navigator.of(context).pop();
  //       }
  //     } else if (result is String && result.isNotEmpty) {
  //       showSubscriptionErrorDialog(context, message: result);
  //     }
  //   }
  // }
}
