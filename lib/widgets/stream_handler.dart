import 'package:flutter/material.dart';
import 'package:meditation/util/global/helper_functions.dart';

import 'loading_widget.dart';

class StreamHandler<T> extends StatefulWidget {
  final T initial;
  final Stream<T> stream;
  final Widget Function(AsyncSnapshot<T> data) builder;
  StreamHandler({Key key, @required this.stream, @required this.builder, this.initial})
      : super(key: key);

  @override
  _StreamHandlerState createState() => _StreamHandlerState();
}

class _StreamHandlerState<T> extends State<StreamHandler<T>> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.stream,
      initialData: widget.initial,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        } else if (snapshot.hasError) {
          HelperFunctions.showSnackbar(context);
          return Container();
        }
        return widget.builder(snapshot);
      },
    );
  }
}
