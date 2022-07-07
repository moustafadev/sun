import 'package:flutter/material.dart';
import 'package:meditation/models/story_category.dart';
import 'package:meditation/repositories/content/content_repository_firebase.dart';
import 'package:meditation/repositories/payment/payment_status.dart';
import 'package:meditation/resources/strings.dart';
import 'package:meditation/screens/text_guide/story_widget.dart';
import 'package:meditation/screens/user/content/user_content_screen.dart';
import 'package:meditation/util/color.dart';
import 'package:meditation/util/global/navigation_util.dart';
import 'package:meditation/widgets/locked_icon.dart';
import 'package:provider/provider.dart';

class StoryCard extends StatefulWidget {
  final StoryCategory storyData;

  const StoryCard({Key key, this.storyData}) : super(key: key);

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  final PaymentStatus paymentStatusRepository = PaymentStatus();
  ContentRepositoryFirebase _repositoryFirebase;
  Stream<bool> paymentStatusStream;

  @override
  void initState() {
    super.initState();
    paymentStatusStream = paymentStatusRepository.getPaymentStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repositoryFirebase = Provider.of<ContentRepositoryFirebase>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: paymentStatusStream,
      initialData: paymentStatusRepository.paymentStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final isLocked = paymentStatusRepository.isLocked(
          snapshot.data,
          widget.storyData.isPaid,
        );
        return Container(
          child: GestureDetector(
            onTap: () {
              if (!_repositoryFirebase.configCache.showSubscribeScreen && isLocked) {
                ScaffoldMessenger.maybeOf(context).showSnackBar(
                  SnackBar(
                    content: Text(Strings.errorOccured),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              NavigationUtil().push(
                context,
                MaterialPageRoute(
                  builder: (context) => isLocked
                      ? UserContentScreen(
                          isOffer: true,
                        )
                      : StoryWidget(
                          storyData: widget.storyData,
                        ),
                  settings: RouteSettings(
                    name: isLocked ? UserContentScreen.routeName : StoryWidget.routeName,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: const Offset(0, 1.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        foregroundDecoration:
                            BoxDecoration(color: Colors.black54),
                        constraints: const BoxConstraints.expand(),
                        child: Image.network(
                            widget.storyData.getCoverImageFullPath(),
                            fit: BoxFit.cover),
                      ),
                    ),
                    if (isLocked)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          child: LockedIcon(),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: primary3Color.withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          constraints: const BoxConstraints(minHeight: 70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.storyData.name,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: whiteColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
