import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meditation/util/color.dart';

class NavItem {
  final String title;
  final String icon;
  final bool isSvg;

  NavItem(this.title, this.icon) : isSvg = icon.endsWith("svg");
}

class BottomNavBar extends StatelessWidget {
  final int selectedItem;
  final List<NavItem> items;
  final Function(int) onNavItemClick;

  BottomNavBar({this.selectedItem, this.items, this.onNavItemClick});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.maybeOf(context).size;
    return Container(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15.0,
            sigmaY: 15.0,
          ),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: screenSize.width * 0.06,
            backgroundColor: Colors.transparent,
            selectedItemColor: blueColor,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            items: items.map((b) {
              return BottomNavigationBarItem(
                label: '',
                icon: b.isSvg
                    ? SvgPicture.asset(
                        b.icon,
                        width: screenSize.width * 0.06,
                        height: screenSize.width * 0.06,
                        color: greyColor,
                      )
                    : ImageIcon(
                        AssetImage(b.icon),
                      ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: b.isSvg
                      ? SvgPicture.asset(
                          b.icon,
                          width: screenSize.width * 0.06,
                          height: screenSize.width * 0.06,
                          color: blueColor,
                        )
                      : ImageIcon(
                          AssetImage(b.icon),
                        ),
                ),
                backgroundColor: Colors.transparent,
              );
            }).toList(),
            onTap: (index) => onNavItemClick(index),
            currentIndex: selectedItem,
          ),
        ),
      ),
    );
  }
}
