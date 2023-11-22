
import 'dart:math';

import 'package:apnql_timesheet/model/timesheet/record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apnql_timesheet/main.dart';
import 'package:apnql_timesheet/model/general/date.dart';

import '../../model/timesheet/list.dart';
import '../../model/timesheet/main.dart';
import 'list.dart';
import 'day.dart';

class TimeSheetWidget extends StatefulWidget {
  final TimesheetWeek sheetWeek;
  final PunchTimesheetRecord? punchRecord;
  final int employeeId;
  final Size realSize;
  final RangeValues range;
  final ScrollController controller;
  final Function(TimesheetWeek) onWeekCreated;
  final Function(List<TimeSheetDay>? days) onCopyDays;
  final bool isCurrent;
  final List<TimeSheetDay>? dataInClipBoard;
  const TimeSheetWidget(this.sheetWeek, {
    required this.employeeId,
    this.punchRecord,
    required this.controller,
    required this.realSize,
    required this.range,
    required this.dataInClipBoard,
    required this.onCopyDays,
    required this.onWeekCreated,
    required this.isCurrent,
    Key? key
  }) : super(key: key);

  @override
  State<TimeSheetWidget> createState() => _TimeSheetWidgetState();
}

class _TimeSheetWidgetState extends State<TimeSheetWidget> with AutomaticKeepAliveClientMixin {
  EditionMode mode = EditionMode.read;

  late final TimesheetWeek timesheetWeek;

  int prevLen = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timesheetWeek = widget.sheetWeek;
    //widget.onWeekCreated(timesheetWeek);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.punchRecord != null) {

      print("widget time update2: ${widget.punchRecord?.timeOut}");
    }
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: StreamBuilder(
          stream: timesheetWeek.stream,
          builder: (context, snapshot) {
            bool isLoading = !timesheetWeek.loaded;
            return StreamBuilder(
              stream: timesheetWeek.status.stream,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                            clipBehavior: Clip.none,
                            mainAxisAlignment: MainAxisAlignment.center,
                            direction: isPortrait ? Axis.vertical : Axis.horizontal,
                            children: timesheetWeek.days.entries.map((day) {
                              bool isFirstDay = day.key.day == 1;
                              bool isWeekend = day.key.weekday > 5;
                              return Expanded(
                                  flex: ((isFirstDay ? (isPortrait ? 20 : 18) : 14) * (isWeekend ? 0.7 : 1)).round(),
                                  child: Flex(
                                    direction: isPortrait ? Axis.vertical : Axis.horizontal,
                                    children: [
                                      !isFirstDay ? Container() :
                                      Expanded(
                                          flex: isPortrait ? 8 : 6,
                                          child: Container(
                                            color: Colors.black,
                                            alignment: Alignment.center,
                                            child: Flex(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                direction: isPortrait ? Axis.horizontal : Axis.vertical,
                                                children: DateFormat("MMMM", "fr_CA").format(day.key).toUpperCase().split("").map((character) {
                                                  return Container(
                                                    margin: EdgeInsets.symmetric(
                                                      horizontal: isPortrait ? 6 : 0,
                                                      vertical: isPortrait ? 0 : 3,
                                                    ),
                                                    child: Text(character,
                                                        style: Theme.of(context).textTheme.titleLarge?.apply(
                                                            fontSizeDelta: isPortrait ? 0 : -4,
                                                            color: Colors.white,
                                                            fontWeightDelta: 3
                                                        )
                                                    ),
                                                  );
                                                }).toList()

                                              /*Text(DateFormat("MMMM", "fr_CA").format(day.key).toUpperCase().spli
                                                style: Theme.of(context).textTheme.titleLarge?.apply(
                                                color: Colors.white,
                                                fontWeightDelta: 3
                                            ),*/
                                            ),
                                          )
                                      ),
                                      TimeSheetDayWidget(
                                        controller: widget.controller,
                                        realSize: widget.realSize,
                                        isLoading: isLoading,
                                        key: Key(day.key.onlyDate),
                                        mode: mode,
                                        punchRecord: widget.punchRecord == null ? null :
                                          widget.punchRecord!.date.difference(day.key).inDays == 0
                                              && widget.punchRecord!.date.day == day.key.day ? widget.punchRecord : null,
                                        range: widget.range,
                                        status: timesheetWeek.status.status,
                                        day: day.key,
                                        timeSheetDay: day.value,
                                        week: timesheetWeek,
                                      )
                                    ],
                                  )
                              );
                            }).toList()
                        );
                        return Text("date");
                      },
                    ),
                    LoadingIconWidget(isLoading)
                  ],
                );


              },
            );

          },
        ),
      ),
    );
  }

  checkReason() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Raison ${timesheetWeek.status.status == WeekStatus.rejected ? "du refus" : "de l'acceptation"}",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(timesheetWeek.status.reason!, style: TextStyle(color: Colors.white),),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;//prevLen != widget.sheetWeek.length;
}

class LoadingIconWidget extends StatefulWidget {
  final bool isLoading;
  const LoadingIconWidget(this.isLoading, {Key? key}) : super(key: key);

  @override
  State<LoadingIconWidget> createState() => _LoadingIconWidgetState();
}

class _LoadingIconWidgetState extends State<LoadingIconWidget> with SingleTickerProviderStateMixin {
  bool isLoaded = false;

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 2000),
    reverseDuration: Duration(milliseconds: 600)
  );

  late Animation<double> fade = Tween<double>(begin: 0, end: 1).animate(_fadeController);

  @override
  void initState() {
    super.initState();
    _fadeController.forward();
  }

  @override
  void dispose() {
    //super.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      isLoaded = true;
      _fadeController.reverse();
    }


    return AnimatedBuilder(
        animation: fade,
        builder: (context, child) {
          if (_fadeController.status == AnimationStatus.dismissed) return Container();
          return Opacity(
            opacity: fade.value,
            child: Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.4),
              child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.black,
                strokeWidth: 20,
                strokeAlign: 2,
                strokeCap: StrokeCap.round,
              ),
            ),
          );
        },
    );
  }
}
