import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditation/resources/images.dart';

class GuideScreen extends StatefulWidget {
  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.mainBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32.0),
                  _buildTitleWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              Images.icExit,
              color: Colors.white60,
              width: 38.0,
              height: 38.0,
            ),
          ),
        ],
      ),
    );
  }
}
