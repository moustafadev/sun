import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/local/preferences.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/home/home_screen.dart';
import 'package:meditation/screens/user/models/user_experiences_provider.dart';
import 'package:meditation/screens/user/models/user_goals_provider.dart';
import 'package:meditation/screens/user/models/user_pay_plans_provider.dart';
import 'package:meditation/screens/user/user_preferences.dart';
import 'package:meditation/util/appsflyer/appsflyer_service.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/custom_box_shadow.dart';
import 'package:meditation/util/custom_button.dart';
import 'package:meditation/util/facebook/facebook_service.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserContentScreen extends StatefulWidget {
  static const String routeName = '/user-content-screen';
  final bool isOffer;

  const UserContentScreen({Key key, this.isOffer = false}) : super(key: key);
  @override
  _UserContentScreenState createState() => _UserContentScreenState();
}

class _UserContentScreenState extends State<UserContentScreen> {
  final Preferences _preferences = Preferences();
  final UserGoalsProvider _goalsProvider = UserGoalsProvider();
  final UserExperienceProvider _experienceProvider = UserExperienceProvider();
  final UserPayPlanProvider _payPlanProvider = UserPayPlanProvider();
  ContentRepositoryFirebase _repositoryFirebase;

  double _screenWidth;

  PageController _pageController;
  int currentPage = 0;

  List<UserGoalItem> _availableGoals = [];
  List<String> _userGoals = [];

  List<UserExperienceItem> _availableExperiences = [];
  List<String> _userExperiences = [];

  List<UserPayPlanItem> _availablePayPlans = [];
  List<UserPayPlanItem> _userPayPlans = [];

  List<Package> _offerings = [];

  int selectedPayPlanIndex = -1;
  bool loading = false;

  double _opacity = 0;
  bool _showSubscribeScreen;
  int _delay;

  @override
  void initState() {
    Purchases.setup('LBMcLruKdTszKvQetPSEAZJhNjazuXZB',
        appUserId: FirebaseAuth.instance.currentUser.uid);
    _onPageChanged(widget.isOffer ? 2 : 0);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
    _showSubscribeScreen = _repositoryFirebase.configCache?.showSubscribeScreen;
    _delay = _repositoryFirebase.configCache?.delay;
    _pageController = PageController(
      initialPage: widget.isOffer ? 2 : 0,
    );
    if (widget.isOffer) {
      currentPage = 2;
      if (_delay != null) {
        initDelay();
      }
    }
    _pageController.addListener(() {
      if (currentPage != _pageController.page.floor() &&
          (_pageController.page == 0.0 ||
              _pageController.page == 1.0 ||
              _pageController.page == 2.0)) {
        setState(() {
          currentPage = _pageController.page.floor();
        });
      }
    });
    _fetchOfferingsData();
    _initData();
    super.didChangeDependencies();
  }

  void initDelay() {
    Future.delayed(
        Duration(
          seconds: _delay ?? 0,
        ), () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  Future<void> _fetchOfferingsData() async {
    Offerings offerings;
    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    if (purchaserInfo.entitlements.active.isNotEmpty) {
      PaymentStatus status = PaymentStatus();
      status.changePaymentStatus(true);
    }
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _offerings = offerings.all['set_of_subscriptions'].availablePackages;
    });
  }

  void _initData() async {
    _userGoals = await _preferences.getSelectedGoals();
    _userExperiences = await _preferences.getSelectedExperience();
    _userPayPlans = [];

    setState(() {
      _availableGoals = _goalsProvider.getAllAvailable();
      _availableExperiences = _experienceProvider.getAllAvailable();
      _availablePayPlans = _payPlanProvider.getAllAvailable();
    });
  }

  Future<void> _onPageChanged(int index) async {
    if (index == 2) {
      await AppsflyerService().initiatedCheckout();
      await FacebookService().logInitiateCheckout();
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.mainBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: _showSubscribeScreen == null
            ? Container()
            : Column(
                children: <Widget>[
                  Expanded(
                    child: PageView(
                      onPageChanged: _onPageChanged,
                      children: <Widget>[
                        _buildGoalsPage(),
                        _buildExperiencePage(),
                        if (_showSubscribeScreen) _buildPaymentPage(),
                      ],
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "What are your top goals?",
              style: TextStyle(
                color: textColor,
                fontSize: 26.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Choose 1-2 top goals and we’ll select recommendations for you',
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemBuilder: (BuildContext context, int index) {
                return _buildGoalItemWidget(index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 15.0);
              },
              itemCount: _availableGoals.length,
            ),
          ),
          const SizedBox(height: 18.0),
          _buildContinueButton(),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }

  Widget _buildGoalItemWidget(int index) {
    UserGoalItem item = _availableGoals[index];
    final selected = _userGoals.contains(item.name);
    return GestureDetector(
      onTap: () {
        if (_userGoals.contains(item.name)) {
          _userGoals.remove(item.name);
        } else {
          _userGoals.add(item.name);
        }
        setState(() {});
      },
      child: Container(
        child: Container(
          height: 68.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: selected
                ? primaryColor.withOpacity(0.37)
                : primaryColor.withOpacity(0.25),
            border: selected
                ? Border.all(width: 2.0, color: greyColor)
                : Border.all(width: 1.0, color: greyColor.withOpacity(0.6)),
            boxShadow: selected
                ? [
                    CustomBoxShadow(
                      color: primaryColor,
                      blurRadius: 6.0,
                      offset: Offset(0.0, 0.0),
                      blurStyle: BlurStyle.outer,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              selected
                  ? const SizedBox(width: 20.0)
                  : const SizedBox(width: 21.0),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: whiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              _buildCheckWidget(selected),
              const SizedBox(width: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlusCheckWidget(bool checked) {
    return SvgPicture.asset(
      checked ? Images.icVerified : Images.icPlus,
      color: checked ? whiteColor : textColor,
      height: 16.0,
      width: 16.0,
    );
  }

  Widget _buildExperiencePage() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Have you already meditated?",
              style: TextStyle(
                color: textColor,
                fontSize: 26.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'We’ll select practices depending on your experience',
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemBuilder: (BuildContext context, int index) {
                return _buildExperienceItemWidget(index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 15.0);
              },
              itemCount: _availableGoals.length,
            ),
          ),
          const SizedBox(height: 18.0),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildExperienceItemWidget(int index) {
    UserExperienceItem item = _availableExperiences[index];
    final selected = _userExperiences.contains(item.name);
    return GestureDetector(
      onTap: () {
        if (_userExperiences.contains(item.name)) {
          _userExperiences.remove(item.name);
        } else {
          _userExperiences.add(item.name);
        }
        setState(() {});
      },
      child: Container(
        child: Container(
          height: 68.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: selected
                ? primaryColor.withOpacity(0.37)
                : primaryColor.withOpacity(0.25),
            border: selected
                ? Border.all(width: 2.0, color: greyColor)
                : Border.all(width: 1.0, color: greyColor.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              selected
                  ? const SizedBox(width: 20.0)
                  : const SizedBox(width: 21.0),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: selected ? whiteColor : textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              _buildCheckWidget(selected),
              const SizedBox(width: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckWidget(bool checked) {
    return Image.asset(
        checked ? Images.checkCircleSelectedIcon : Images.checkCircleEmptyIcon,
        width: 16.0,
        height: 16.0,
        color: checked ? Colors.white : Colors.white38);
  }

  Widget _buildPaymentCheckWidget(bool checked) {
    return Image.asset(
      checked ? Images.checkCircleSelectedIcon : Images.checkCircleEmptyIcon,
      width: 19.0,
      height: 19.0,
      color: checked ? darkBlueColor : grey3Color,
    );
  }

  Widget _buildPaymentPage() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.paymentBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildBackButtonWidget(),
                  ],
                ),
              ),
              Image.asset(Images.logoTransparent, width: 80, height: 80),
              const SizedBox(height: 20.0),
              Text(
                "Try for free",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildPaymentItemWidget(index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 35.0);
                  },
                  itemCount: _availablePayPlans.length,
                ),
              ),
              const SizedBox(height: 11.0),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Text(
                  'Access to N + meditations for overcoming stress anxiety and insomnia. New classes every week. Anytime cancellation guarantee.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: text2Color,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20.0),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : _buildContinueButton(color: orangeColor),
              const SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Text(
                    _userPayPlans.isNotEmpty
                        ? _userPayPlans[0].title +
                            getPaymentPlanTitle(selectedPayPlanIndex)
                        : '',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewWidget(
                            'https://pages.flycricket.io/sun-live/privacy.html',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Privacy policy',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Text(
                    ' & ',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewWidget(
                            'https://pages.flycricket.io/sun-live/terms.html',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Terms',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  String getPaymentPlanTitle(int index) {
    if (_offerings.isEmpty) return '';
    final product = _offerings[index].product;
    final currencyCode = product.currencyCode;
    final price = product.price.ceil() - 0.01;
    switch (index) {
      case 0:
        return '$price $currencyCode';
      case 1:
        return '$price $currencyCode in a year';
      case 2:
        return '$price $currencyCode';
      default:
        return '';
    }
  }

  Future<bool> purchaseProduct(Package package) async {
    bool isPremium = false;
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      isPremium = purchaserInfo.entitlements.active.isNotEmpty;
      await AppsflyerService().purchase(
        package.product.price,
        package.product.currencyCode,
        package.product.title,
      );

      if (isPremium) {
        PaymentStatus status = PaymentStatus();
        status.changePaymentStatus(true);
        return isPremium;
      }
    } catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print("User cancelled");
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print("User not allowed to purchase");
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print("Payment is pending");
      }
      return isPremium;
    }
    return isPremium;
  }

  Widget _buildPaymentItemWidget(int index) {
    UserPayPlanItem item = _availablePayPlans[index];
    final selected = _userPayPlans.contains(item);
    return GestureDetector(
      onTap: () async {
        if (_availablePayPlans.contains(item.name)) {
          _availablePayPlans.remove(item.name);
        } else {
          _userPayPlans.clear();
          _userPayPlans.add(item);
        }
        selectedPayPlanIndex = index;
        setState(() {});
      },
      child: Container(
        child: Container(
          height: 68.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: selected ? whiteColor : Colors.transparent,
            border: selected
                ? Border.all(width: 2.0, color: whiteColor)
                : Border.all(width: 2.0, color: grey3Color),
          ),
          child: Row(
            children: [
              selected
                  ? const SizedBox(width: 20.0)
                  : const SizedBox(width: 21.0),
              Expanded(
                child: Text(
                  item.title + getPaymentPlanTitle(index),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: selected ? darkBlueColor : whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              _buildPaymentCheckWidget(selected),
              const SizedBox(width: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton({Color color = primaryColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CustomButton(
        color: color,
        title: Strings.nextButton,
        onTap: _isContinueButtonActive()
            ? () async => await _onContinueClick()
            : null,
        enabled: _isContinueButtonActive(),
      ),
    );
  }

  bool _isContinueButtonActive() {
    if (currentPage == 0) {
      return _userGoals.isNotEmpty;
    } else if (currentPage == 1) {
      return _userExperiences.isNotEmpty;
    } else if (currentPage == 2) {
      return _userPayPlans.isNotEmpty;
    } else {
      return false;
    }
  }

  Future _onContinueClick() async {
    if (currentPage == 0 && _userGoals.isNotEmpty) {
      _pageController.animateTo((currentPage + 1) * _screenWidth,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      await AppsflyerService().preonboardingComplete(1);
    } else if (currentPage == 1 && _userExperiences.isNotEmpty) {
      await _preferences.setSelectedGoals(_userGoals);
      await _preferences.setSelectedExperience(_userExperiences);
      if (_repositoryFirebase.configCache.showSubscribeScreen) {
        _pageController.animateTo((currentPage + 1) * _screenWidth,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
        await AppsflyerService().preonboardingComplete(2);
      } else {
        _navigateToHomeScreen();
      }

      initDelay();
    } else if (currentPage == 2) {
      setState(() {
        loading = true;
      });
      if (selectedPayPlanIndex == -1) {
        setState(() {
          loading = false;
        });
        _navigateToHomeScreen();
      }
      final purchased = await purchaseProduct(_offerings[selectedPayPlanIndex]);
      setState(() {
        loading = false;
      });
      if (purchased) {
        _navigateToHomeScreen();
      }
    }
  }

  void _navigateToHomeScreen() {
    NavigationUtil().pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeScreen(),
        settings: RouteSettings(
          name: HomeScreen.routeName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBackButtonWidget() {
    final screenSize = MediaQuery.maybeOf(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: GestureDetector(
        child: Container(
          child: SvgPicture.asset(
            Images.icExit,
            color: Colors.white,
            width: screenSize.width * 0.09,
          ),
        ),
        onTap: () {
          NavigationUtil().push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
              settings: RouteSettings(
                name: HomeScreen.routeName,
              ),
            ),
          );
        },
      ),
    );
  }
}

class WebViewWidget extends StatelessWidget {
  String url;
  WebViewWidget(this.url);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
