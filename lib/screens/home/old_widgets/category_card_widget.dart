import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/category.dart';
import 'package:meditation/util/color.dart';

class CategoryCardWidget extends StatelessWidget {

  final CategoryItem item;
  final Function(CategoryItem item) onTap;

  CategoryCardWidget({
    @required this.item,
    @required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: item.id ?? item.name,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Image.network(
                    item.getImageFullPath(),
                    fit: BoxFit.cover
                  )
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          item.name,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: whiteColor,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w400
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left
                        ),
                        SizedBox(height: 5.0),
                        SizedBox(
                          height: 60.0,
                          child: Text(
                            item.description,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: whiteColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left
                          )
                        )
                      ]
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
