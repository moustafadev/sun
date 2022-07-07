import 'package:flutter/material.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int count;
  final int selectedIndex;

  const PageIndicatorWidget({
    @required this.count,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          return Padding(
              padding: count - 1 != index
                  ? const EdgeInsets.only(right: 15.0)
                  : const EdgeInsets.all(0.0),
              child: Container(
                width: 29.0,
                height: 9.0,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  color: Colors.white.withOpacity(0.85),
                  border: Border.all(
                    width: 2.0,
                    color: index == selectedIndex
                        ? Color(0xff619CAD)
                        : Colors.transparent,
                  ),
                ),
              ),
          );
        },
      ),
    );
  }
}
