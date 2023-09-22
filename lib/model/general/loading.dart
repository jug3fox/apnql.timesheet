import 'package:flutter/material.dart';

import '../oro/list/main.dart';

class LoadingStreamWidget<T> extends StatefulWidget {
  final OroList<T> list;
  final Widget Function(T element) builder;
  const LoadingStreamWidget({required this.list, required this.builder, Key? key}) : super(key: key);

  @override
  State<LoadingStreamWidget<T>> createState() => _LoadingStreamWidgetState<T>();
}

class _LoadingStreamWidgetState<T> extends State<LoadingStreamWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.list.stream,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting && widget.list.isEmpty) {
          return const Center(
            child: Text("Loading"),
          );
        }
        return ListView(
          children: widget.list.map((element) => widget.builder(element)).toList(),
        );
      },
    );
  }
}
