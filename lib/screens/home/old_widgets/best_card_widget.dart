import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/resources/images.dart';
import 'package:meditation/util/color.dart';

class BestCardWidget extends StatelessWidget {

  final AudioItem item;
  final String heroTag;
  final Function(AudioItem item) onTap;

  BestCardWidget({
    @required this.item,
    @required this.heroTag,
    @required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Color(0xff284981), Color(0xff1f3371)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 1.0)
            )
          ]
        ),
        child: GestureDetector(
          onTap: () => onTap(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Image.asset(
                      Images.bestOfTheWeek,
                      fit: BoxFit.cover
                    )
                  )
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            item.categoryName,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: whiteColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            item.name,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: whiteColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w300
                            ),
                            softWrap: true,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis
                          ),
                          SizedBox(height: 20.0)
                        ]
                      )
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }

}
