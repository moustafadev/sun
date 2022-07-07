import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/favorites/favorites_repository.dart';
import 'package:meditation/repositories/local/local_repository.dart';
import 'package:meditation/resources/images.dart';

class FavouriteIconWidget extends StatefulWidget {
  final bool favorite;
  final AudioItem item;

  const FavouriteIconWidget({@required this.favorite, @required this.item});

  @override
  _FavouriteIconWidgetState createState() => _FavouriteIconWidgetState();
}

class _FavouriteIconWidgetState extends State<FavouriteIconWidget> {
  final LocalRepository favoritesRepository = FavoritesRepository();
  bool _favorite = false;

  Future _onFavoriteClick() async {
    if (_favorite) {
      await favoritesRepository.remove(widget.item.id);
      setState(() => _favorite = false);
    } else {
      await favoritesRepository.add(widget.item.id, widget.item);
      setState(() => _favorite = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _favorite = widget.favorite;
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.maybeOf(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: SvgPicture.asset(
              Images.icFavourites,
              color: _favorite ? Colors.white : Colors.white54,
              width: screenSize.width * 0.12,
            ),
          ),
          onTap: () => _onFavoriteClick(),
        )
      ],
    );
  }
}