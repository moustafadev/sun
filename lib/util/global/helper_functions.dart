import 'package:flutter/material.dart';

class HelperFunctions {
  static void showSnackbar(BuildContext context) {
    ScaffoldMessenger.maybeOf(context).showSnackBar(
      SnackBar(content: Text('Error occured on data loading!!!')),
    );
  }
}
