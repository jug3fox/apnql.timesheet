import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/general/date.dart';

class TimeButtonWidget extends StatefulWidget {
  final String title;
  final TimeOfDay time;
  final Function(TimeOfDay newTime) onChange;
  const TimeButtonWidget({
    required this.onChange,
    required this.time,
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  State<TimeButtonWidget> createState() => _TimeButtonWidgetState();
}

class _TimeButtonWidgetState extends State<TimeButtonWidget> {
  late TimeOfDay currentTime = widget.time;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog<TimeOfDay>(
              context: context,
              builder: (context) {
                return TimePickerDialog(
                  initialTime: widget.time,

                );
              },
            ).then((value) {
              if (value != null) {
                setState(() {
                  currentTime = value;
                  widget.onChange(value);
                });
              }
            });
          },
          child: Text(widget.time.show,
            style: Theme.of(context).textTheme.titleMedium?.apply(
              color: Colors.white,
              fontWeightDelta: 5
            ),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(Color.lerp(Colors.white, Colors.black, 0.8)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 15))
          ),
        ),
        Positioned(
          top: -10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              //color: Color.lerp(Colors.white, Colors.black, 0.7),
            ),
            child: Text(widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white
              ),
            ),
          ),
        )
      ],
    );
  }
}
