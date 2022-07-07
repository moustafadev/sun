import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/resources/keys.dart';
import 'package:meditation/resources/shared_prefs_keys.dart';
import 'package:meditation/screens/home/home_screen.dart';
import 'package:meditation/screens/inapp/in_app_preferences.dart';
import 'package:meditation/screens/inapp/in_app_purchases_impl_2.dart';
import 'package:meditation/screens/payment/models/products_provider_impl.dart';
import 'package:meditation/util/amplitude/amplitude_service.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/audio_players_util.dart';
import 'package:meditation/util/global/audio_service_util.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:meditation/util/notifications/notifications_utils.dart';
import 'package:meditation/screens/user/content/user_content_screen.dart';
import 'package:meditation/screens/user/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Preferences _preferences = Preferences();
  final NotificationsUtils _notifications = NotificationsUtils();
  PurchaserInfo _purchaserInfo;
  bool muteBgMusicStatus = false;
  bool bgAudiosStarted = false;

  @override
  void initState() {
    super.initState();
    print("SplashScreen initState");
    WidgetsBinding.instance.addObserver(this);
    _notifications.initialize();
  }

  Future<void> _initPurchasesState() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("LBMcLruKdTszKvQetPSEAZJhNjazuXZB",
        appUserId: FirebaseAuth.instance.currentUser.uid);
    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();

    if (!mounted) return;

    _purchaserInfo = purchaserInfo;
    PaymentStatus status = PaymentStatus();
    if (_purchaserInfo.entitlements.active.isNotEmpty) {
      status.changePaymentStatus(true);
    } else {
      status.changePaymentStatus(false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AudioPlayersUtil.bgSoundPlayer.pause();
      AudioPlayersUtil.isPlayingBackground = false;
    } else {
      if (!AudioPlayerTask().playbackState.value.playing && bgAudiosStarted) {
        AudioPlayersUtil.bgSoundPlayer.play();
        AudioPlayersUtil.isPlayingBackground = true;
      }
    }
  }

  Future<void> _checksFlow() async {
    await checkConnectivity();
    await _printFirebaseTokenId();
    await _checkInAppPurchases();
    await _checkCurrentUser();
    await AmplitudeService().init();
    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Oops! Internet lost'),
              content: Text(
                  'Sorry, Please check your internet connection and then try again'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  onPressed: () async {
                    await checkConnectivity();
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  Future<void> _printFirebaseTokenId() async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      print("Firebase Instance ID: " + token);
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }

  Future<void> _checkInAppPurchases() async {
    InAppPurchasesImpl2 iap;
    try {
      final productsProvider = ProductsProviderImpl();
      final pack = await productsProvider.getActiveSubscriptionPack();
      final availableSubsIds =
          await productsProvider.getAvailableSubscriptionIds();
      final isFirstSubscriptionCheck =
          await _preferences.isFirstSubscriptionCheck();
      if (!isFirstSubscriptionCheck) {
        iap = InAppPurchasesImpl2(
            productsProvider: productsProvider,
            onPurchaseUpdate: null,
            onPurchaseError: null,
            onError: (error) {});
        await iap.initialize();
        if (pack?.id?.isNotEmpty ?? false) {
          availableSubsIds.add(pack.id);
        }
        if (pack?.specialOfferId?.isNotEmpty ?? false) {
          availableSubsIds.add(pack.specialOfferId);
        }
        final subscription = await iap.isAnySubscriptionActive(
            availableSubsIds, Keys.subscriptionPackPass);
        if (subscription) {
          await _notifications.cancelSpecialOfferNotification();
        }
        await _preferences.setHasSubscription(subscription);
      }
    } catch (error, _) {
      print("[SplashScreen]: $error");
    } finally {
      if (iap != null) {
        await iap.dispose();
      }
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      User user = _auth.currentUser;
      if (user == null) {
        UserCredential auth = await _auth.signInAnonymously();
        if (auth != null) {
          _setDataUser(auth.user);
        }
      }
      _initPurchasesState();
    } catch (error) {
      print("[SplashScreen]: $error");
    }
  }

  Future _setDataUser(User currentUser) async {
    Map metaData = {
      "createdBy": "0L1uQlYHdrdrG0D5CroAeybZsL33",
      "createdDate": DateTime.now(),
      "docId": currentUser.uid,
      "env": "production",
      "fl_id": currentUser.uid,
      "locale": "en-US",
      "schema": "users",
      "schemaRef": "fl_schemas/RIGJC2G8tsCBml0270IN",
      "schemaType": "collection",
    };
    if (currentUser.uid != null) {
      FirebaseFirestore.instance
          .collection('fl_content')
          .where('_fl_meta_.fl_id', isEqualTo: currentUser.uid)
          .get()
          .then((QuerySnapshot snapshot) async {
        // check if the user does not exists.
        if (snapshot.docs.length == 0) {
          FirebaseFirestore.instance
              .collection("fl_content")
              .doc(currentUser.uid)
              .set({
            "_fl_meta_": metaData,
            "email": currentUser.email,
            "name": currentUser.displayName,
            "photoUrl": currentUser.photoURL,
            "joiningDate": DateTime.now().toString()
          }, SetOptions(merge: true));
        }
      });
    }
  }

  void _navigateToNextScreen() async {
    try {
      final selectedGoals = await _preferences.getSelectedGoals();
      final selectedExperience = await _preferences.getSelectedExperience();

      if (selectedGoals.isEmpty || selectedExperience.isEmpty) {
        _navigateToUserContentScreen();
      } else {
        _navigateToHomeScreen();
      }
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack);
      throw error;
    }
  }

  void _navigateToHomeScreen() {
    NavigationUtil().pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        transitionDuration: const Duration(seconds: 0),
        settings: RouteSettings(
          name: HomeScreen.routeName,
        ),
      ),
    );
  }

  void _navigateToUserContentScreen() {
    NavigationUtil().pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => UserContentScreen(),
          settings: RouteSettings(
            name: UserContentScreen.routeName,
          ),
        ));
  }

  Future<void> startBackgroundMusic(List<AudioItem> items) async {
    muteBgMusicStatus = await _preferences.getBool(muteBackground, false);
    try {
      if (!AudioPlayerTask().playbackState.value.playing &&
          !AudioPlayersUtil.isPlayingBackground) {
        final currentAudioItem =
            items.firstWhere((element) => element.name == 'Birds chirping');
        AudioPlayersUtil.bgSoundPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(currentAudioItem.file),
          ),
          preload: false,
        );
        AudioPlayersUtil.bgSoundPlayer.setLoopMode(LoopMode.one);
        AudioPlayersUtil.bgSoundPlayer.play();

        AudioPlayersUtil.isPlayingBackground = true;
        await AudioPlayersUtil.changeBgAudioIndex(
            items[items.indexOf(currentAudioItem)]);
        bgAudiosStarted = true;
        if (muteBgMusicStatus) {
          AudioPlayersUtil.bgSoundPlayer.setVolume(0.0);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _checksFlow(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLogoWidget();
          }
          return StreamBuilder(
            initialData:
                Provider.of<ContentRepositoryFirebase>(context).categoriesCache,
            stream: Provider.of<ContentRepositoryFirebase>(context).categories,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildLogoWidget();
              }
              return StreamBuilder(
                stream: Provider.of<ContentRepositoryFirebase>(context).config,
                initialData:
                    Provider.of<ContentRepositoryFirebase>(context).configCache,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLogoWidget();
                  }
                  print(snapshot.data);
                  return StreamBuilder(
                      initialData:
                          Provider.of<ContentRepositoryFirebase>(context)
                              .backgroundSoundsCache,
                      stream: Provider.of<ContentRepositoryFirebase>(context)
                          .backgroundSounds,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildLogoWidget();
                        }
                        return FutureBuilder(
                          future: startBackgroundMusic(snapshot.data),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLogoWidget();
                            }
                            _navigateToNextScreen();

                            return _buildLogoWidget();
                          },
                        );
                      });
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildLogoWidget() {
  return Container(
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Images.logoTransparent,
              width: 100,
              height: 100,
            ),
            Container(
              child: Text(
                'Sun',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 30,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
