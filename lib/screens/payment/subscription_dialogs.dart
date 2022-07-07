import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showSubscriptionErrorDialog(BuildContext context, {String message, Function onOk, Function onClose}) async {
  await Alert(
    context: context,
    type: AlertType.error,
    title: "Subscription error",
    desc: message ?? "Oops!! Something went wrong. Please try again",
    closeFunction: onClose,
    buttons: [
      DialogButton(
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: onOk != null ? onOk : () => Navigator.pop(context),
        width: 120,
      )
    ]
  ).show();
}

void showSuccessSubscriptionPaymentDialog(BuildContext context) async {
  await Alert(
    context: context,
    type: AlertType.success,
    title: "Success",
    desc: "You've successfully subscribed to our extended meditation pack. To check your subscription details goto your Apple account.",
    buttons: [
      DialogButton(
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ]
  ).show();
}

Future showProgressDialog(BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
        )
      );
    }
  );
}