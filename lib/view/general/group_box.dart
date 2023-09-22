import 'package:flutter/material.dart';

class GroupBoxWidget extends StatefulWidget {
  final Widget child;
  final EdgeInsets? margin, padding;
  final String title;
  final TextAlign? titleAlignment;
  final Color? bgColor;
  const GroupBoxWidget({
    required this.child,
    required this.title,
    this.titleAlignment,
    this.bgColor,
    this.margin,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  State<GroupBoxWidget> createState() => _GroupBoxWidgetState();
}

class _GroupBoxWidgetState extends State<GroupBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: (widget.margin ?? EdgeInsets.symmetric(horizontal: 3, vertical: 10)).add(EdgeInsets.only(top: 10)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: widget.padding,
            decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(15)
            ),
            child: widget.child,
          ),
          Positioned(
              left: 10,
              right: 10,
              top: -10,
              child: Container(
                color: Theme.of(context).dialogTheme.backgroundColor,
                child: Text(widget.title,
                  textAlign: widget.titleAlignment,
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              )
          )
        ],
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: widget.bgColor?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15)
          ),
          child: widget.child,
        ),
        Positioned(
          left: 10,
          top: -10,
          child: Text(widget.title)
        )
      ],
    );
  }
}
