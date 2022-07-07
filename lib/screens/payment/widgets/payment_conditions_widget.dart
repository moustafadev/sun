import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/util/color.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentConditionsWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: pinkColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w200,
            fontFamily: "roboto"
          ),
          children: [
            TextSpan(text: Strings.subscriptionPaymentDescription),
            TextSpan(text: "\n\n"),
            TextSpan(text: Strings.subscriptionAccept1),
            TextSpan(text: "\n"),
            TextSpan(
              text: Strings.subscriptionTermsOfService,
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white60
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchPrivacyPolicyAndTermsOfServiceUrl()
            ),
            TextSpan(text: " & "),
            TextSpan(
              text: Strings.subscriptionPrivacyPolicy,
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white60
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchPrivacyPolicyAndTermsOfServiceUrl()
            )
          ]
        )
      )
    );
  }

  void _launchPrivacyPolicyAndTermsOfServiceUrl() async {
    if (await canLaunch(Strings.privacyPolicyUrl)) {
      await launch(Strings.privacyPolicyUrl);
    }
  }

}
