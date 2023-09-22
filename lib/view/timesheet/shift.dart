import 'package:flutter/material.dart';

import '../../../model/timesheet/record.dart';

class TimesheetShiftsWidget extends StatefulWidget {
  final Shift? shift;
  final Axis? direction;
  final Function(Shift newShift)? onChange;
  const TimesheetShiftsWidget({this.onChange, this.shift, this.direction, Key? key}) : super(key: key);

  @override
  State<TimesheetShiftsWidget> createState() => _TimesheetShiftsWidgetState();
}

class _TimesheetShiftsWidgetState extends State<TimesheetShiftsWidget> {
  Shift? currentShift;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentShift = widget.shift;
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.direction ?? Axis.horizontal,
      children: Shift.values.where((element) => element.icon != null).map((shift) {
        return TimesheetShiftWidget(shift,
            isCurrent: shift == currentShift,
            onChange: (newShift) {
              setState(() {
                currentShift = newShift;
                if (widget.onChange != null) {
                  widget.onChange!(newShift);
                }
              });
            }
        );
      }).toList()
    );
  }
}

class TimesheetShiftWidget extends StatefulWidget {
  final Shift shift;
  final bool isCurrent;
  final Function(Shift newShift) onChange;
  const TimesheetShiftWidget(this.shift, {required this.isCurrent, required this.onChange, Key? key}) : super(key: key);

  @override
  State<TimesheetShiftWidget> createState() => _TimesheetShiftWidgetState();
}

class _TimesheetShiftWidgetState extends State<TimesheetShiftWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        widget.onChange(widget.shift);
      },
      icon: Icon(widget.shift.icon, color: Colors.white.withOpacity(widget.isCurrent ? 1 : 0.3),)
    );
  }
}



