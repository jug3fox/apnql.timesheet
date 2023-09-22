import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:apnql_timesheet/model/employee/main.dart';
import 'package:apnql_timesheet/model/timesheet/list.dart';
import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/view/timesheet/week.dart';

import '../../main.dart';
import 'menu.dart';


class TimeSheetWeeksWidget extends StatefulWidget {
  final EmployeeInfo employee;
  final Week? initialWeek;
  const TimeSheetWeeksWidget(this.employee, {this.initialWeek, Key? key}) : super(key: key);

  @override
  State<TimeSheetWeeksWidget> createState() => _TimeSheetWeeksWidgetState();
}

class _TimeSheetWeeksWidgetState extends State<TimeSheetWeeksWidget> {
  late Size realSize;

  RangeValues range = RangeValues(7, 17);
  double prevScale = 2.3;

  ValueNotifier<TimesheetWeek?> weekCopied = ValueNotifier(null);
  late TimesheetWeek currentWeek;
  WeekStatus? currentStatus;

  final DateTime current = DateTime.now();
  ValueNotifier<List<TimeSheetDay>?> daysToCopy = ValueNotifier(null);
  PageController controller = PageController(
    initialPage: 100,
    //viewportFraction: 0.9,
  );
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);

  bool get dataInClipBoard => daysToCopy.value != null;

  final Map<DateTime, TimesheetWeek> weeks = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 1)).then((value) {
      scrollController.jumpTo((scrollController.position.extentTotal / 24) * 7);
    });


    TimesheetWeek prevWeek = TimesheetWeek(employeeId: widget.employee.id, week: Week(DateTime.now().subtract(Duration(days: 7))));
    prevWeek.status.stream.listen((event) {
      print(prevWeek.status.status);
      if(prevWeek.status.status == WeekStatus.not_submitted) {
        notifications.initializePlatformNotifications().then((value) {
          notifications.showTimesheetNotification(
            prevWeek: prevWeek,
            onClick: (index) {
              setState(() {
                controller.animateToPage(99, duration: Duration(milliseconds: 1200), curve: Curves.easeInOutQuad);
                initiallyOpen = true;
                //currentWeek = weeks[prevWeek.week.start]!;
              });
            }
          );
        });
      }
    });


    TimesheetWeek initialWeek = TimesheetWeek(employeeId: widget.employee.id, week: widget.initialWeek ?? Week(DateTime.now()));
    weeks[initialWeek.week.start] = initialWeek;
    currentWeek = weeks[initialWeek.week.start]!;
    renewSubs;

    scrollController.addListener(() {
      bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      double realValue = isPortrait ? realSize.width : realSize.height;
      double hourStart = (scrollController.offset / realValue * 24);
      double hourMove = hourStart - range.start;
      double hourEnd = range.end + hourMove;
      if(hourStart >= 0 && hourEnd <= 24) {
        setState(() {
          range = RangeValues(hourStart, hourEnd);
        });
      }
    });
  }

  double get scale => 24 / (range.end - range.start);
  bool initiallyOpen = false;

  StreamSubscription? _currentWeekSubs;

  Future<void> get renewSubs async {
    await _currentWeekSubs?.cancel();
    _currentWeekSubs = currentWeek.status.stream.listen((event) {
      setState(() {
        currentStatus = currentWeek.status.status;
      });
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    //int daysDiff = DateTime.now().difference(currentWeek.week.start).inDays;
    //bool inWeek = daysDiff >= 0 && daysDiff < 7;

    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    print("init: $initiallyOpen");
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          realSize = Size(constraints.maxWidth * scale, constraints.maxHeight * scale);
          bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          return Flex(
            direction: isPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: isPortrait ? Axis.horizontal : Axis.vertical,
                  child: Container(
                    alignment: Alignment.center,
                    width: isPortrait ? realSize.width : null,
                    height: isPortrait ? null : realSize.height,
                    child: Flex(
                      clipBehavior: Clip.none,
                      direction: isPortrait ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                            child: Flex(
                              direction: isPortrait ? Axis.vertical : Axis.horizontal,
                              children: [
                                HoursWidget(),
                                Expanded(
                                    child: PageView.builder(
                                      controller: controller,

                                      scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        Week newWeek = Week(current.add(Duration(days: (index - 100) * 7)));
                                        //print()
                                        if (weeks[newWeek.start] == null) {
                                          weeks[newWeek.start] = TimesheetWeek(employeeId: widget.employee.id, week: newWeek);
                                        }
                                        return ValueListenableBuilder(
                                          valueListenable: daysToCopy,
                                          builder: (context, value, child) {

                                            return TimeSheetWidget(weeks[newWeek.start]!,
                                              //key: Key(timesheetWeek.week.start.onlyDate),
                                              controller: scrollController,
                                              employeeId: widget.employee.id,
                                              realSize: realSize,
                                              range: range,
                                              isCurrent: newWeek == widget.employee.week?.week,
                                              dataInClipBoard: daysToCopy.value,
                                              onWeekCreated: (week) {
                                                //weeks[newWeek] = week;
                                              },
                                              onCopyDays: (days) {
                                                daysToCopy.value = days;
                                              },
                                            );
                                          },
                                        );
                                      },
                                      onPageChanged: (index) {
                                        Week newWeek = Week(current.add(Duration(days: (index - 100) * 7)));
                                        setState(() {
                                          currentWeek = weeks[newWeek.start]!;
                                          renewSubs;
                                        });
                                      },
                                    )
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                )
              ),
              Container(
                height: isPortrait ? 30 : null,
                width: isPortrait ? null : 30,
                //color: Colors.orange,
                color: Colors.black,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: isPortrait ? 0 : 1,
                        child: RangeSlider(
                          values: range,

                          min: 0,
                          max: 24,
                          divisions: 24,
                          onChanged:  (newValue) {
                            setState(() {
                              range = newValue;
                              realSize = Size(constraints.maxWidth * scale, constraints.maxHeight * scale);
                              double realValue = isPortrait ? realSize.width : realSize.height;
                              scrollController.jumpTo((range.start / 24) * realValue);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          //return ;
        },
      ),
      bottomNavigationBar: Container(
        color: Color.lerp(currentWeek.status.status.color, Colors.black, 0.5),
        height: isPortrait ? 50 : 36,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  controller.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeOut);
                },
                icon: Icon(isPortrait ? Icons.move_up : Icons.chevron_left, color: Colors.white,),
              ),
            ),
            Flex(
              direction: isPortrait ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    //color: inWeek ? Colors.green.withOpacity(0.5) : null,
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.red,
                  ),
                  child: Text("Semaine du ${currentWeek.week.start.onlyTextDate}",
                    style: Theme.of(context).textTheme.labelLarge?.apply(
                        color: Colors.white,
                        fontSizeFactor: 1.1
                    ),
                  ),
                ),
                SizedBox(
                  height: 0,
                  width: 10,
                ),
                StreamBuilder(
                  stream: currentWeek.stream,
                  builder: (context, snapshot) {
                    return Text("${currentWeek.hoursWorked.toNumber} hrs travaillés",
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
            Container(
              child: IconButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeOut);
                },
                icon: RotatedBox(
                  quarterTurns: isPortrait ? 2 : 0,
                  child: Icon(isPortrait ? Icons.move_up : Icons.chevron_right, color: Colors.white,),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: TimesheetMainMenuWidget(
        key: Key(initiallyOpen.toString()),
        initiallyOpen : initiallyOpen,
        currentWeek: currentWeek,
      ),
    );
  }
}

class HoursWidget extends StatefulWidget {
  const HoursWidget({Key? key}) : super(key: key);

  @override
  State<HoursWidget> createState() => _HoursWidgetState();
}

class _HoursWidgetState extends State<HoursWidget> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Stack(
      children: [
        Container(
          height: isPortrait ? 25 : null,
          width: isPortrait ? null : 25,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          child: Flex(
            direction: isPortrait ? Axis.horizontal : Axis.vertical,
            children: List.generate(25, (index) {
              bool emptyText = index == 0 || index == 24;
              return Expanded(
                flex: emptyText ? 1 : 2,
                child: Container(
                  alignment: Alignment.center,
                  child: emptyText ? null : Text(index.toString(),
                    style: Theme.of(context).textTheme.titleSmall?.apply(
                        fontWeightDelta: 5,
                        color: Colors.white
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Container(
          height: isPortrait ? 25 : null,
          width: isPortrait ? null : 25,
          //color: Colors.black.withOpacity(0.3),
          alignment: Alignment.center,
          child: Flex(
            direction: isPortrait ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(24, (index) {
              return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(index % 2 == 0 ? 0 : 0.15),
                    ),
                    alignment: Alignment.center,
                    //child: ,
                  )
              );
              return Text(index.toString());
            }),
          ),
        ),
      ],
    );
  }
}

enum EditionMode {
  read,
  write
}