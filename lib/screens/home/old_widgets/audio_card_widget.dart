import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/util/color.dart';

class AudioCardWidget extends StatefulWidget {

  final AudioItem item;
  final String heroTag;
  final Function(AudioItem item) onTap;

  AudioCardWidget({
    @required this.item,
    @required this.heroTag,
    @required this.onTap
  });

  @override
  State createState() => AudioCardWidgetState();

}

class AudioCardWidgetState extends State<AudioCardWidget> {

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => widget.onTap(widget.item),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: const Offset(0, 1.0)
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        color: Colors.black54
                      ),
                      constraints: const BoxConstraints.expand(),
                      child: Image.network(
                        widget.item.getCoverImageFullPath(),
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(),
                      Container(
                        width: double.infinity,
                        color: primary3Color.withOpacity(0.7),
                        padding: const EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          bottom: 10.0,
                          top: 8.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.item.name,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: whiteColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              widget.item.description,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: whiteColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300,
                              ),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}
