import 'package:amplitude_flutter/amplitude.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation/util/appsflyer/appsflyer_service.dart';
import 'package:meditation/util/color.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meditation/util/facebook/facebook_service.dart';
import 'package:provider/provider.dart';

import 'repositories/content/content_repository_firebase.dart';
import 'screens/startup/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await Hive.initFlutter();
  await AppsflyerService().initSdk();
  await FacebookService().setAdvertiserTracking();
// Create the instance
  final Amplitude analytics =
      Amplitude.getInstance(instanceName: "sunmeditation");

  // Initialize SDK
  analytics.init("b3a6efe8a993db27aaa1d9e88f4381c2");

  Map appsFlyerOptions = {
    "afDevKey": "TC6qBpZjR4JGCJJwLRDZv",
    "afAppId": "sun.live",
    "isDebug": kDebugMode,
  };

  AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
  appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true);

  var dateNow = DateTime.now();
  // var dateEndUsing = DateTime.parse("2022-06-20");
  // var daysEndUsing = dateEndUsing.difference(dateNow).inDays;
  // if (daysEndUsing <= 0) {
  //   throw Exception('Need pay money for developer!');
  // }
  // print('Days remain for use app: ' + daysEndUsing.toString());

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    GlobalConfiguration().loadFromPath("asset/config/app_settings.json");
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Provider(
      create: (context) => ContentRepositoryFirebase()..categories,
      child: MaterialApp(
        title: 'Sun',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: primaryColor, fontFamily: 'Ageo'),
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SplashScreen(),
        ),
        builder: (context, child) {
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
      ),
    );
  }
}
