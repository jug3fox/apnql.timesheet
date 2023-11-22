import 'dart:ffi';

import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/view/timesheet/record.dart';
import 'package:flutter/material.dart';

import '../../model/employee/main.dart';
import '../../model/timesheet/list.dart';
import '../../model/timesheet/record.dart';
import '../timesheet/list.dart';

class EmployeeWidget extends StatefulWidget {
  final OroEmployee employee;
  const EmployeeWidget(this.employee, {Key? key}) : super(key: key);

  @override
  State<EmployeeWidget> createState() => _EmployeeWidgetState();
}

class _EmployeeWidgetState extends State<EmployeeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmployeeInfoPage(widget.employee.id))
        );
      },
      tileColor: Colors.black.withOpacity(widget.employee.isShift ? 0.15 : 0.1),
      title: Text(widget.employee.name!),
    );
  }
}

class EmployeeInfoPage extends StatefulWidget {
  final int id;
  const EmployeeInfoPage(this.id, {Key? key}) : super(key: key);

  @override
  State<EmployeeInfoPage> createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  ValueNotifier<double> scale = ValueNotifier(2.3);

  ValueNotifier<TimesheetWeek?> weekCopied = ValueNotifier(null);
  ValueNotifier<bool> isTimesheet = ValueNotifier(false);
  late ValueNotifier<TimesheetWeek> currentWeek;

  late final EmployeeInfo employeeInfo;

  ValueNotifier<PunchTimesheetRecord?> punchRecord = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    employeeInfo = EmployeeInfo(widget.id);

    currentWeek = ValueNotifier(TimesheetWeek(employeeId: widget.id, week: Week(DateTime.now())));
    super.initState();
  }

  static Widget actionButton(dynamic data, Function()? onPressed, [double? size]) {
    return Container(
      constraints: BoxConstraints(maxHeight: size ?? 25, maxWidth:  (size ?? 25) + 10),
      decoration: true ? null : BoxDecoration(
        border: Border.all(
          color: Colors.black26
        ),
        //color: Colors.red.withOpacity(0.3),
      ),
      child: IconButton(
          iconSize: (size ?? 25) / 1.5,
          visualDensity: VisualDensity.compact,
          disabledColor: Colors.green,
          onPressed: onPressed,
          icon: data is IconData ? Icon(data) : data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          foregroundColor: Colors.white,
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.primary, Colors.black, 0.5),
          toolbarHeight: isPortrait ? 60 : 35,
          titleSpacing: 0,
          actions: [
            ValueListenableBuilder(
              valueListenable: currentWeek,
              builder: (context, snapshot, _) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flex(
                      direction: MediaQuery.of(context).orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder(
                          stream: currentWeek.value.status.stream,
                          builder: (context, snapshot) {
                            return actionButton(
                                currentWeek.value.status.status == WeekStatus.not_submitted ? Icons.send : Icons.cancel_schedule_send,
                                currentWeek.value.status.isLocked ? null : () {
                                  currentWeek.value.submit();
                                }
                            );
                          },
                        ),
                        ValueListenableBuilder(
                            valueListenable: weekCopied,
                            builder: (context, value, child) {
                              if (weekCopied.value == null) {
                                return actionButton(Icons.copy, () {
                                  weekCopied.value = currentWeek.value.copy;
                                });
                              }

                              if(weekCopied.value!.week != currentWeek.value.week) {

                                return actionButton(Icons.paste, () {
                                  weekCopied.value!.pasteTo(currentWeek.value).then((value) {
                                    currentWeek.value.controller.add(currentWeek.value);
                                  });
                                  weekCopied.value = null;
                                });
                              }
                              return actionButton(Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomRight,
                                children: [
                                  Icon(Icons.paste),
                                  Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0
                                          ),
                                          borderRadius: BorderRadius.circular(300),
                                          color: Colors.white,
                                        ),
                                        child: Icon(Icons.cancel, size: 10, color: Colors.red,),
                                      )
                                  ),
                                ],
                              ), () {
                                weekCopied.value = null;
                              });
                            },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

          ],

          title: StreamBuilder(
            stream: employeeInfo.stream,
            builder: (context, snapshot) {
              return SizedBox(
                width: isPortrait ? null : 500,
                child: Flex(
                  direction: isPortrait ? Axis.vertical : Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      //color: Colors.red.withOpacity(0.3),
                      child: Text(employeeInfo.name ?? "",
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                            color: Colors.white
                        ),
                      ),
                    ),
                    Container(
                      //color: Colors.green.withOpacity(0.3),
                      height: 30,
                      width: 200,
                      alignment: isPortrait ? Alignment.topCenter : Alignment.center,
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        direction: Axis.horizontal,
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.coronavirus_outlined,
                                grade: 1,
                                weight: 1,
                                opticalSize: 1,
                                fill: 0.1,
                                size: 26,
                                color: Colors.yellow,
                              ),
                              SizedBox(
                                width: 3,
                                height: 3,
                              ),
                              Text(employeeInfo.bank?.sick.timeLeft ?? "0",
                                style: Theme.of(context).textTheme.labelLarge?.apply(
                                    color: Colors.yellow
                                ),
                              ),
                            ],
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.beach_access,
                                size: 26,
                                color: Colors.green,
                              ),
                              Text(employeeInfo.bank?.vacations.timeLeft ?? "0",
                                style: Theme.of(context).textTheme.labelLarge?.apply(
                                    color: Colors.green
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        body: StreamBuilder(
          stream: currentWeek.value.stream,
          builder: (context, snapshot) {
            return ValueListenableBuilder(
                valueListenable: punchRecord,
                builder: (context, value, child) {
                  print("punchRecord: ${punchRecord.value}");
                  return TimeSheetWeeksWidget(employeeInfo,
                      punchRecord: punchRecord.value,
                      onWeekChanged: (TimesheetWeek week) {
                        currentWeek.value = week;
                      }
                  );
                },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white.withOpacity(1),
          ),
          alignment: Alignment.center,
          width: 35,
          height: 35,
          child: ValueListenableBuilder(
            valueListenable: punchRecord,
            builder: (context, value, child) {
              return PunchTimeWidget(
                employeeId: employeeInfo.id,
                onRecordChange : (newRecord) {
                  punchRecord.value = newRecord;
                },
              );
            },
          ),
        ),

      ),
    );
  }



  Future<bool> onWillPop() async {
    weekCopied.value = null;
    return false;

  }
}

class PunchTimeWidget extends StatefulWidget {
  final int employeeId;
  final Function(PunchTimesheetRecord? record) onRecordChange;
  const PunchTimeWidget({required this.employeeId, required this.onRecordChange, Key? key}) : super(key: key);

  @override
  State<PunchTimeWidget> createState() => _PunchTimeWidgetState();
}

class _PunchTimeWidgetState extends State<PunchTimeWidget> with SingleTickerProviderStateMixin {
  ValueNotifier<PunchTimesheetRecord?> record = ValueNotifier(null);
  late final TimeSheetDay timesheetToday = TimeSheetDay.today(employeeId: widget.employeeId);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  );

  late final Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear
  ));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: record,
        builder: (context, value, child) {
          if (record.value == null) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  left: -20,
                  right: -20,
                  top: 28,
                  child: ScaleTransition(
                    scale: animation,
                    alignment: Alignment.topCenter,
                    child: Card(
                      color: Colors.green.withOpacity(0.8),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          //color: Colors.green.withOpacity(0.8),
                        ),
                        alignment: Alignment.center,
                        child: StreamBuilder(
                          stream: record.value?.stream,
                          builder: (context, value) {
                            return Text(record.value?.label ?? "00:00:00",
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                    ),
                  )
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular((1 - animation.value) * 30),
                        bottomRight: Radius.circular((1 - animation.value) * 30),
                      ),
                      color: Color.lerp(Colors.white, Colors.green, animation.value),
                    ),
                    alignment: Alignment.center,
                    child: _EmployeeInfoPageState.actionButton(
                      record.value == null ? Icons.punch_clock : Icons.cancel, () {
                        if (record.value == null) {
                          TimeOfDay currentTime = TimeOfDay(
                            hour: DateTime.now().hour,
                            minute: DateTime.now().minute,
                          );

                          Shift? newShift = Shift.values
                              .where((shift) => timesheetToday.where((sheet) => sheet.shift == shift).isNotEmpty)
                              .firstOrNull;
                          record.value = PunchTimesheetRecord(
                            shift: newShift
                          );
                          widget.onRecordChange(record.value);
                        } else {
                          record.value?.timer.cancel();
                          _controller.reverse().then((value) {
                            record.value?.save();
                            record.value = null;
                            widget.onRecordChange(record.value);
                          });
                        }
                      }
                    ),
                  );
                },
              )
            ],
          );
        },
    );
  }
}

