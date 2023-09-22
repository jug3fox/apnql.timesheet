
import 'package:flutter/material.dart';

class CustomTFF extends StatefulWidget {
  final String title;
  final String? data;
  const CustomTFF(this.title, this.data, {Key? key}) : super(key: key);

  @override
  State<CustomTFF> createState() => _CustomTFFState();
}

class _CustomTFFState extends State<CustomTFF> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        enabled: false,
        style: TextStyle(
          color: Colors.black
        ),
        decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(2),

            border: InputBorder.none,
            labelText: widget.title,
            labelStyle: Theme.of(context).textTheme.labelMedium?.apply(
                fontSizeDelta: 13
            )
        ),
        key: Key(widget.data ?? ""),
        initialValue: widget.data,
      ),
    );
  }
}


