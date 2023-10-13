
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:xml/xml.dart';

import '../../model/command/main.dart';
import '../../model/main.dart';
import '../../model/timesheet/list.dart';
import '../../model/timesheet/record.dart';

class TimesheetMainMenuWidget extends StatefulWidget {
  final TimesheetWeek currentWeek;
  final bool initiallyOpen;
  const TimesheetMainMenuWidget({
    this.initiallyOpen = false,
    required this.currentWeek,
    Key? key
  }) : super(key: key);

  @override
  State<TimesheetMainMenuWidget> createState() => _TimesheetMainMenuWidgetState();
}

class _TimesheetMainMenuWidgetState extends State<TimesheetMainMenuWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 400),
    reverseDuration: Duration(milliseconds: 100),
  );

  late final Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(_controller);

  ValueNotifier<TimesheetWeek?> weekCopied = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    if (widget.initiallyOpen) {

      menuShow = true;
      _controller.forward();
    }
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.dismissed) {
        setState(() {
          menuShow = !menuShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return GestureDetector(
      onTap: () {
        setState(() {
          menuShow = false;
        });
        print("touch");
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Visibility(
              visible: menuShow,
              child: Container(
                width: 600,
                height: 600,
              )
          ),
          Visibility(
              visible: menuShow,
              child:
              Positioned(
                  left: -20,
                  right: -20,
                  child: Container(
                    width: 620,
                    height: 620,
                    decoration: BoxDecoration(
                        gradient: RadialGradient(
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.black.withOpacity(0)
                            ],
                            center: Alignment(1, 0.8),
                            radius: 1,
                            stops: [
                              0.4, 1
                            ]
                        )
                    ),
                  )
              ),
          ),
          Flex(
              mainAxisSize: MainAxisSize.min,
              direction: isPortrait ? Axis.horizontal : Axis.vertical,

              children: [
                Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Visibility(
                          visible: menuShow,
                          child: Opacity(
                            opacity: animation.value,
                            child: Flex(
                              direction: Axis.vertical,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StreamBuilder(
                                  stream: widget.currentWeek.status.stream,
                                  builder: (context, snapshot) {
                                    WeekStatus? currentStatus = widget.currentWeek.status.status;
                                    bool isSent = currentStatus != WeekStatus.not_submitted;
                                    return TimesheetMenuButtonWidget(
                                      icon: isSent ? Icons.cancel_schedule_send : Icons.send,
                                      text: isSent ? "Annuler l'envoie" : "Envoyer",
                                      onClick: widget.currentWeek.status.isLocked ? null : () {
                                        widget.currentWeek.submit();
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                ),
                                ValueListenableBuilder(
                                  valueListenable: weekCopied,
                                  builder: (context, value, child) {
                                    return Flex(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        TimesheetMenuButtonWidget(
                                          icon: Icons.copy_all,
                                          text: "Copier",
                                          onClick: copyWeek,
                                        )
                                        /*Material(
                          elevation: 4,
                          color: Theme.of(context).colorScheme.primary,

                          borderRadius: BorderRadius.circular(100),
                          child: IconButton(
                            onPressed: copyWeek,
                            icon: Icon(Icons.copy_all, size: 24, color: Colors.white,)
                          ),
                        ),*/,
                                        const SizedBox(
                                          width: 10,
                                          height: 10,
                                        ),
                                        TimesheetMenuButtonWidget(
                                          icon: Icons.paste,
                                          text: "Coller",
                                          onClick: weekCopied.value == null || widget.currentWeek.status.isLocked ? null : pasteWeek,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  width: 5,
                                  height: 5,
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    FloatingActionButton(
                      mini: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)
                      ),
                      onPressed: menuPopup,
                      child: Icon(menuShow ? Icons.cancel_outlined : Icons.menu, size: 24, ),
                    ),
                  ],
                ),
              ]
          ),
          Flex(
            mainAxisSize: MainAxisSize.min,
            direction: isPortrait ? Axis.horizontal : Axis.vertical,

            children: [
              Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Visibility(
                        visible: menuShow,
                        child: Opacity(
                          opacity: animation.value,
                          child: Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StreamBuilder(
                                stream: widget.currentWeek.status.stream,
                                builder: (context, snapshot) {
                                  WeekStatus? currentStatus = widget.currentWeek.status.status;
                                  bool isSent = currentStatus != WeekStatus.not_submitted;
                                  return TimesheetMenuButtonWidget(
                                    icon: isSent ? Icons.cancel_schedule_send : Icons.send,
                                    text: isSent ? "Annuler l'envoie" : "Envoyer",
                                    onClick: widget.currentWeek.status.isLocked ? null : () {
                                      widget.currentWeek.submit();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(
                                width: 10,
                                height: 10,
                              ),
                              ValueListenableBuilder(
                                valueListenable: weekCopied,
                                builder: (context, value, child) {
                                  return Flex(
                                    direction: Axis.vertical,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TimesheetMenuButtonWidget(
                                        icon: Icons.copy_all,
                                        text: "Copier",
                                        onClick: copyWeek,
                                      )
                                      /*Material(
                              elevation: 4,
                              color: Theme.of(context).colorScheme.primary,

                              borderRadius: BorderRadius.circular(100),
                              child: IconButton(
                                onPressed: copyWeek,
                                icon: Icon(Icons.copy_all, size: 24, color: Colors.white,)
                              ),
                            ),*/,
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                      ),
                                      TimesheetMenuButtonWidget(
                                        icon: Icons.paste,
                                        text: "Coller",
                                        onClick: weekCopied.value == null || widget.currentWeek.status.isLocked ? null : pasteWeek,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(
                                width: 5,
                                height: 5,
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  FloatingActionButton(
                    mini: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                    ),
                    onPressed: menuPopup,
                    child: Icon(menuShow ? Icons.cancel_outlined : Icons.menu, size: 24, ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: isPortrait ? Axis.horizontal : Axis.vertical,

      children: [
        Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Visibility(
                  visible: false || menuShow,
                  child: Opacity(
                    opacity: animation.value,
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreamBuilder(
                          stream: widget.currentWeek.status.stream,
                          builder: (context, snapshot) {
                            WeekStatus? currentStatus = widget.currentWeek.status.status;
                            bool isSent = currentStatus != WeekStatus.not_submitted;
                            return TimesheetMenuButtonWidget(
                              icon: isSent ? Icons.cancel_schedule_send : Icons.send,
                              text: isSent ? "Annuler l'envoie" : "Envoyer",
                              onClick: widget.currentWeek.status.isLocked ? null : () {
                                widget.currentWeek.submit();
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          width: 10,
                          height: 10,
                        ),
                        ValueListenableBuilder(
                          valueListenable: weekCopied,
                          builder: (context, value, child) {
                            return Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TimesheetMenuButtonWidget(
                                  icon: Icons.copy_all,
                                  text: "Copier",
                                  onClick: copyWeek,
                                )
                                /*Material(
                                  elevation: 4,
                                  color: Theme.of(context).colorScheme.primary,

                                  borderRadius: BorderRadius.circular(100),
                                  child: IconButton(
                                    onPressed: copyWeek,
                                    icon: Icon(Icons.copy_all, size: 24, color: Colors.white,)
                                  ),
                                ),*/,
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                ),
                                TimesheetMenuButtonWidget(
                                  icon: Icons.paste,
                                  text: "Coller",
                                  onClick: weekCopied.value == null || widget.currentWeek.status.isLocked ? null : pasteWeek,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          width: 5,
                          height: 5,
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
            FloatingActionButton(
              mini: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)
              ),
              onPressed: menuPopup,
              child: Icon(menuShow ? Icons.cancel_outlined : Icons.menu, size: 24, ),
            ),
          ],
        ),
      ],
    );
  }

  bool menuShow = false;

  menuPopup() {
    if (menuShow) {
      _controller.reverse();
    } else {
      setState(() {
        menuShow = !menuShow;
      });
      _controller.forward();
    }
  }

  copyWeek() {
    weekCopied.value = widget.currentWeek.copy;
  }

  pasteWeek() {
    Oro oro = Oro();
    List<Future<TimesheetRecord>> futures = [];

    for(var record in weekCopied.value!){
      DateTime newDate = widget.currentWeek.week.start.add(Duration(days: record.date.weekDay));
      OroCommand command = OroCommand(
          tag: "timesheet_tx_add",
          jsonCommands: {
            "sub_project_id": record.subProject.id,
            "employee_id": weekCopied.value!.employeeId,
            "activity_type_id": record.activity.id,
            "date": newDate.onlyDate,
            "shift": record.shift.index,
            "minutes": record.minutes.inMinutes,
            "time_in": record.timeIn.show,
            "time_out": record.timeOut.show,
            "notes": record.notes,
          }
      );

      futures.add(oro.send(command).then((value) {
        XmlDocument root = XmlDocument.parse(value.body);
        XmlNode? result = root.firstChild;
        XmlElement element = result!.firstElementChild!;
        print(root);
        TimesheetRecord newRecord = TimesheetRecord.fromBase(id: int.parse(element.innerText), date: newDate, record: record);
        return newRecord;
      }));
    }

    Future.wait(futures).then((value) {
      widget.currentWeek.addAll(value);
      _controller.reverse();
    });
  }
}

class TimesheetMenuButtonWidget extends StatefulWidget {
  final Color? backgroundColor, foregroundColor;
  final IconData icon;
  final String text;
  final Function()? onClick;
  const TimesheetMenuButtonWidget({
    this.backgroundColor,
    this.foregroundColor,
    required this.icon,
    required this.text,
    required this.onClick,
    Key? key
  }) : super(key: key);

  @override
  State<TimesheetMenuButtonWidget> createState() => _TimesheetMenuButtonWidgetState();
}

class _TimesheetMenuButtonWidgetState extends State<TimesheetMenuButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: true ? null : BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(100)
      ),
      //color: Colors.red.withOpacity(0.4),
      child: ElevatedButton(
        onPressed: widget.onClick,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
          elevation: MaterialStateProperty.all(7),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
        ),
        child: Opacity(
          opacity: widget.onClick == null ? 0.3 : 1,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.text),
              SizedBox(
                height: 5,
                width: 5,
              ),
              Icon(widget.icon, size: 18)
            ],
          ),
        ),
      ),
    );
  }
}
