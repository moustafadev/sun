import 'package:flutter/material.dart';
import 'package:meditation/util/color.dart';

class CustomFilter extends StatefulWidget {
  final List<dynamic> filters;
  final Function(int) onFilterTap;

  const CustomFilter(this.filters, this.onFilterTap);

  @override
  _CustomFilterState createState() => _CustomFilterState();
}

class _CustomFilterState extends State<CustomFilter> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.maybeOf(context).size.width * 0.03,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.filters
              .map(
                (e) => _buildFilterWidget(
                  widget.filters.indexOf(e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFilterWidget(int index) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () => _onTap(index),
      child: Container(
        decoration: _selectedIndex == index
            ? BoxDecoration(
                color: primary2Color.withOpacity(0.31),
                border: Border.all(width: 1.0, color: primary2Color),
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              )
            : null,
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text(
          widget.filters[index],
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    widget.onFilterTap(index);
    setState(() {
      _selectedIndex = index;
    });
  }
}
