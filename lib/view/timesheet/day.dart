
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apnql_timesheet/model/timesheet/list.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/view/timesheet/list.dart';
import 'package:apnql_timesheet/view/timesheet/record.dart';

import '../../../model/timesheet/main.dart';
import '../../../model/timesheet/record.dart';

class TimeSheetDayWidget extends StatefulWidget {
  //final double minStart, maxEnd;
  final WeekStatus? status;
  final EditionMode mode;
  final RangeValues range;
  final Size realSize;
  final bool isLoading;
  final TimesheetWeek week;
  final TimeSheetDay? timeSheetDay;
  final DateTime day;
  final ScrollController controller;
  const TimeSheetDayWidget({
    required this.controller,
    required this.mode,
    required this.range,
    required this.isLoading,
    required this.realSize,
    this.status,
    required this.day,
    this.timeSheetDay,
    required this.week,
    Key? key
  }) : super(key: key);

  @override
  State<TimeSheetDayWidget> createState() => _TimeSheetDayWidgetState();
}

class _TimeSheetDayWidgetState extends State<TimeSheetDayWidget> {

  ValueNotifier<Offset> offset = ValueNotifier(Offset(0, 0));
  int gap = 30;
  bool isDragging = false;

  EmptyTimesheetRecord? _newRecord;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    widget.controller.addListener(() {
      offset.value = Offset(offsetHeader, widget.controller.position.viewportDimension);
    });
  }

  double get offsetHeader {

    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return widget.controller.offset;

    double realValue = isPortrait ? widget.realSize.width : widget.realSize.height;
    double screenValue = isPortrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height;
    double maxHoursStart = 24 - (widget.range.end - widget.range.start);
    double percentStart = widget.range.start / maxHoursStart;
    return (widget.controller.offset + screenValue / 2 - 50) - (percentStart * (((widget.range.end - widget.range.start) / 24) * screenValue));
  }

  @override
  Widget build(BuildContext context) {
    DateTime day = widget.day;
    TimeSheetDay? timeSheetDay = widget.week.days[day];
    bool isWeekend = day.weekday > 5;
    bool isToday = DateTime.now().onlyDate == widget.day.onlyDate;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    Future.delayed(Duration(milliseconds: 1)).then((value) {
      offset.value = Offset(offsetHeader, widget.controller.position.viewportDimension);
    });

    return StreamBuilder(
        stream: timeSheetDay?.stream,
        builder: (context, snapshot) {
          return Expanded(
            flex: isWeekend ? 10 : 20,
            child: Container(
              color: Colors.black.withOpacity((widget.day.day) % 2 == 1 ? 0.6 : 0.4),
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Flex(
                    direction: isPortrait ? Axis.horizontal : Axis.vertical,
                    children: List.generate(24, (index) {
                      return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.2)
                                ),
                                color: Theme.of(context).colorScheme.secondary.withOpacity(index % 2 == 1 ? 0.15 : 0)
                            ),
                            child: Flex(
                              direction: isPortrait ? Axis.horizontal : Axis.vertical,
                              children: List.generate(4, (minutes) {
                                DateTime data = DateTime(
                                  widget.day.year,
                                  widget.day.month,
                                  widget.day.day,
                                  index,
                                  minutes * 15
                                );
                                DateTime targetData = data.add(Duration(minutes: 15));
                                return Expanded(
                                  child: LongPressDraggable<NewRecordTime>(
                                    onDragStarted: () {
                                      print("drsag start");
                                      isDragging = true;
                                      setState(() {
                                        _newRecord = EmptyTimesheetRecord(data,
                                            timeIn: data.timeOfDay,
                                            timeOut: targetData.timeOfDay,
                                            shift: widget.timeSheetDay?.newShift
                                        );
                                      });
                                    },
                                    onDragEnd: (details) {
                                      isDragging = false;
                                    },
                                    data: NewRecordTime(
                                        time: data
                                    ),
                                    feedback: Container(),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        /*border: Border.all(
                                          color: Colors.red,
                                        )*/
                                      ),
                                      //child: Text("$index-${minutes / 4}"),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                      );
                    }),
                  ),
                  StreamBuilder(
                    stream: _newRecord?.timeStream,
                    builder: (context, snapshot) {
                      print("timeOut: ${_newRecord?.timeOut}");
                      if (_newRecord == null) return Container();
                      return TimesheetRecordWidget(
                          record: _newRecord!,
                          week: widget.week,
                          status: widget.status,
                          day: widget.timeSheetDay!,
                          size: widget.realSize
                      );
                      return Container();
                    },
                  ),

                  Stack(
                    children: (widget.timeSheetDay?.records ?? []).map((record) {
                      if (record is! TimesheetRecord) {
                        return Container();
                      }
                      return TimesheetRecordWidget(
                          record: record,
                          dragChange: (dragging) {
                            setState(() {
                              isDragging = dragging;
                            });
                          },
                          week: widget.week,
                          status: widget.status,
                          day: widget.timeSheetDay!,
                          size: widget.realSize
                      );
                    }).toList(),
                  ),


                  Visibility(
                      visible: isDragging,
                      child: Flex(
                          direction: isPortrait ? Axis.horizontal : Axis.vertical,
                          children: List.generate(24, (index) {
                            return Expanded(
                              child: Flex(
                                direction: isPortrait ? Axis.horizontal : Axis.vertical,
                                children: List.generate(4, (minutes) {

                                  DateTime targetData = DateTime(
                                      widget.day.year,
                                      widget.day.month,
                                      widget.day.day,
                                      index,
                                      minutes * 15
                                  ).add(Duration(minutes: 15));

                                  return Expanded(
                                    child: DragTarget<NewRecordTime>(
                                      onMove: (details) {
                                        print("entering");
                                        if (details.data.record != null) {
                                          if (details.data.direction == TimeDirection.timeIn) {
                                            details.data.record!.timeIn = targetData.timeOfDay;
                                          } else {
                                            details.data.record!.timeOut = targetData.timeOfDay;
                                          }
                                        } else if (details.data.time != null) {
                                          DateTime start = details.data.time!;

                                          bool validGap = targetData.difference(start).inMinutes >= 60;
                                          print("valid: ${validGap}, newShift: ${widget.timeSheetDay?.shiftLeft}");
                                          if ((_newRecord == null && validGap) || (_newRecord != null && !validGap)) {
                                            setState(() {
                                              _newRecord = validGap ? EmptyTimesheetRecord(details.data.time!,
                                                  timeIn: start.timeOfDay,
                                                  timeOut: targetData.timeOfDay,
                                                  shift: widget.timeSheetDay?.newShift
                                              ) : null;
                                            });
                                          }
                                          _newRecord?.timeOut = targetData.timeOfDay;
                                        }
                                      },
                                      onAccept: (result) {
                                        print(_newRecord);
                                        if(result.record != null) {
                                          print("saving: ${result.record?.timeOut}");
                                          result.record?.save;
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => TimesheetRecordDialog(
                                              record: _newRecord!,
                                              week: widget.week,
                                              day: widget.timeSheetDay!,
                                            ),
                                          ).then((value) {
                                            setState(() {
                                              _newRecord = null;
                                            });
                                          });
                                        }
                                        print("from: $result, to: ${targetData}");
                                      },
                                      builder: (context, candidateData, rejectedData) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            /*border: Border.all(
                                                color: Colors.blue.withOpacity(0.3)
                                            ),*/
                                            //color: Colors.red.withOpacity(0.3),
                                          ),
                                          alignment: Alignment.center,
                                          //child: Text("$index-${minutes / 4}"),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ),
                            );
                          })
                      )
                  ),
                  ValueListenableBuilder(
                    valueListenable: offset,
                    builder: (context, value, child) {
                      String dayOfWeek = DateFormat("EEE", "fr_CA").format(widget.day).substring(0, 3);
                      String day = DateFormat("dd", "fr_CA").format(widget.day);
                      TimeOfDay hoursWorked = widget.timeSheetDay!.hoursWorked;
                      return Positioned(
                        left: isPortrait ? offset.value.dx : 0,
                        width: isPortrait ? 280 : null,
                        right: isPortrait ? null : 0,

                        top: isPortrait ? 0 : offset.value.dx,
                        //right: offset.value - 100,
                        child: GestureDetector(
                          onTap: widget.timeSheetDay == null || widget.status.isFullLocked ? null : () {
                            print("tapped");
                            Iterable<Shift> shiftLeft = widget.timeSheetDay!.shiftLeft;

                            Shift? shift = widget.timeSheetDay!.newShift;
                            showDialog(
                              context: context,
                              builder: (context) => TimesheetRecordDialog(
                                record: EmptyTimesheetRecord(widget.day,
                                  shift: shift,
                                ),
                                week: widget.week,
                                day: widget.timeSheetDay!,
                              ),
                            );
                          },
                          onLongPress: () {
                            print("long press");

                            Iterable<Shift> shiftLeft = widget.timeSheetDay!.shiftLeft;

                            Shift? shift = widget.timeSheetDay!.newShift;
                            showDialog(
                              context: context,
                              builder: (context) => TimesheetRecordDialog(
                                record: EmptyTimesheetRecord(widget.day,
                                  shift: shift,
                                ),
                                week: widget.week,
                                day: widget.timeSheetDay!,
                              ),
                            );
                          },
                          child: Transform.scale(
                            scale: isPortrait ? 0.7 : 0.8,
                            alignment: Alignment.topCenter,
                            child: Card(

                              shadowColor: isToday ? Colors.red : Theme.of(context).colorScheme.secondary,
                              elevation: isToday ? 7 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: isPortrait ? Radius.elliptical(150, 60) : Radius.elliptical(60, 60),
                                  bottomRight: Radius.elliptical(40, 60),
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
                              margin: EdgeInsets.zero,
                              child: Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: isPortrait ? 10 : 4),
                                      child: Text("${dayOfWeek.toUpperCase()} (${day})",
                                        textAlign: TextAlign.center,
                                        style: (
                                            isPortrait ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.titleSmall
                                        )?.apply(
                                            color: (isToday ? Colors.white : Colors.black).withOpacity(widget.status.isFullLocked ? 0.6 : 1),
                                            fontWeightDelta: 7,
                                          fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: isPortrait ? 10 : 0).add(
                                      EdgeInsets.only(right: isPortrait ? 0 : 7)
                                    ),
                                    //alignment: Alignment(0.9, 0),
                                    child: Text("${hoursWorked.toNumber} h",
                                      style: (
                                          isPortrait ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.labelLarge
                                      )?.apply(
                                          color: Color.lerp(widget.timeSheetDay?.color, isToday ? Colors.white : Colors.black, isToday ? 0.5 : 0.1),
                                          fontWeightDelta:  (hoursWorked.inHours * 2).round() - 6,
                                        fontSizeDelta: -1
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}
