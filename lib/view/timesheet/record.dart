
import 'package:flutter/material.dart';
import 'package:apnql_timesheet/main.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/model/timesheet/list.dart';
import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/view/timesheet/shift.dart';

import '../../../model/timesheet/record.dart';
import '../general/group_box.dart';
import 'button_time.dart';

class TimesheetRecordWidget extends StatefulWidget {
  final WeekStatus? status;
  final Function(bool dragging)? dragChange;
  final TimesheetWeek week;
  final TimeSheetDay day;
  final EmptyTimesheetRecord record;
  final Size size;
  const TimesheetRecordWidget({
    this.dragChange,
    this.status,
    required this.week,
    required this.record,
    required this.day,
    required this.size,
    Key? key
  }) : super(key: key);

  @override
  State<TimesheetRecordWidget> createState() => _TimesheetRecordWidgetState();
}

class _TimesheetRecordWidgetState extends State<TimesheetRecordWidget> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return StreamBuilder(
        stream: widget.record.timeStream,
        builder: (context, snapshot) {
          double hourPercentIn = ((widget.record.timeIn.hour + (widget.record.timeIn.minute / 60)) / 24);
          double hourPercentOut = ((widget.record.timeOut.hour + (widget.record.timeOut.minute / 60)) / 24); // From 6 to 20 hour


          return Positioned(
            left: isPortrait ? hourPercentIn * (widget.size.width) + 1 : 0,
            right: isPortrait ? (1 - hourPercentOut ) * (widget.size.width) + 1 : 0,
            top: isPortrait ? 20 : hourPercentIn * (widget.size.height) + 1,
            bottom: isPortrait ? 0 : (1 - hourPercentOut ) * (widget.size.height) + 1,
            child: Container(
                alignment: Alignment.center,
                //color: Colors.green.withOpacity(0.3),
                child: Container(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 5, vertical: 0),
                    color: Color.lerp(widget.status.color, Colors.black, (widget.record.shift?.index ?? 0) / 4),
                    shape: RoundedRectangleBorder( //<-- SEE HERE
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Colors.black,
                        width: 2
                      ),
                    ),
                    child: Opacity(
                      opacity: widget.status.isFullLocked ? 0.8 : 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              print("tapped");
                              showDialog(
                                context: context,
                                builder: (context) => TimesheetRecordDialog(
                                  record: widget.record,
                                  day: widget.day,
                                  week: widget.week,
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              alignment: isPortrait ? null : Alignment.center,
                              child: Flex(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                direction: widget.record.date.weekday > 5 ? Axis.horizontal : Axis.vertical,
                                children: [
                                  Text(widget.record.timeIn.show,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  ),
                                  widget.record.date.weekday > 5 ?
                                  Text("-",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  ) : Container(),
                                  Text(widget.record.timeOut.show,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          /*GestureDetector(
                            onTap: widget.status.isFullLocked ? null : () {
                              print("tapped");
                              showDialog(
                                context: context,
                                builder: (context) => TimesheetRecordDialog(
                                  record: widget.record,
                                  day: widget.day,
                                  week: widget.week,
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              alignment: isPortrait ? null : Alignment.center,
                              child: Flex(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                direction: widget.record.date.weekday > 5 ? Axis.horizontal : Axis.vertical,
                                children: [
                                  Text(widget.record.timeIn.show,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  ),
                                  widget.record.date.weekday > 5 ?
                                  Text("-",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  ) : Container(),
                                  Text(widget.record.timeOut.show,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.apply(
                                        color: Colors.white,
                                        fontStyle: widget.status.isFullLocked ? FontStyle.italic : null
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),*/

                          widget.record is TimesheetRecord ? Positioned(
                            left: isPortrait ? 3 : null,
                            top: isPortrait ? null : 3,
                            child: Draggable(
                              onDragStarted: () {
                                if (widget.dragChange != null) widget.dragChange!(true);
                              },
                              onDragEnd: (details) {
                                if (widget.dragChange != null) widget.dragChange!(false);
                              },
                              data: NewRecordTime(
                                direction: TimeDirection.timeIn,
                                record: widget.record as TimesheetRecord,
                              ),
                              feedback: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                padding: EdgeInsets.all(4),
                                  child: RotatedBox(
                                    quarterTurns: isPortrait ? 0 : 1,
                                    child: Icon(Icons.sync_alt, color: Color.lerp(Colors.black, Colors.green, 1),),
                                  )
                              ),
                              child: RotatedBox(
                                quarterTurns: isPortrait ? 0 : 1,
                                child: Icon(Icons.first_page, size: 16, color: Colors.white,),
                              ),
                            ),
                          ) : Container(),
                          widget.record is TimesheetRecord ? Positioned(
                            right: isPortrait ? 3 : null,
                            bottom: isPortrait ? null : 3,
                            child: Draggable(
                              onDragStarted: () {
                                if (widget.dragChange != null) widget.dragChange!(true);
                              },
                              onDragEnd: (details) {
                                if (widget.dragChange != null) widget.dragChange!(false);
                              },
                              data: NewRecordTime(
                                direction: TimeDirection.timeOut,
                                record: widget.record as TimesheetRecord,
                              ),
                              feedback: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                padding: EdgeInsets.all(4),
                                child: RotatedBox(
                                  quarterTurns: isPortrait ? 0 : 1,
                                  child: Icon(Icons.sync_alt, color: Color.lerp(Colors.black, Colors.green, 1),),
                                )
                              ),

                              child: RotatedBox(
                                quarterTurns: isPortrait ? 0 : 1,
                                child: Icon(Icons.last_page, size: 16, color: Colors.white,),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          );
        },
    );
  }
}

class TimesheetRecordDialog extends StatefulWidget {
  final EmptyTimesheetRecord record;
  final TimesheetWeek week;
  final TimeSheetDay day;
  const TimesheetRecordDialog({required this.week, required this.day, required this.record, Key? key}) : super(key: key);

  @override
  State<TimesheetRecordDialog> createState() => _TimesheetRecordDialogWidgetState();
}

class _TimesheetRecordDialogWidgetState extends State<TimesheetRecordDialog> {
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double width = isPortrait ? MediaQuery.of(context).size.width - 50 : MediaQuery.of(context).size.width - 200;
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.black,
      alignment: Alignment.center,

      titlePadding: isPortrait ? null : EdgeInsets.only(top: 20),
      title: Text("${widget.record is! TimesheetRecord ? "Ajout" : "Modification"} du temps",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: isPortrait ? 10 : 0),
      content: Container(
        width: width,
        child: StreamBuilder(
          stream: widget.record.stream,
          builder: (context, snapshot) {
            return Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10, height: 10,),
                Flex(
                  direction: MediaQuery.of(context).orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TimeButtonWidget(
                          title: "Entrée",
                          time: widget.record.timeIn,
                          onChange: (newTime) {
                            widget.record.timeIn = newTime;
                          },
                        ),
                        const SizedBox(width: 20, height: 20,),
                        TimeButtonWidget(
                          title: "Sortie",
                          time: widget.record.timeOut,
                          onChange: (newTime) {
                            widget.record.timeOut = newTime;
                          },
                        ),
                      ],
                    ),
                    GroupBoxWidget(
                      bgColor: Colors.blue.withOpacity(0.2),
                      title: "Quart d${widget.record.shift?.name.isVowel == true ? "'" : "e "}${widget.record.shift?.name}",
                      titleAlignment: TextAlign.center,
                      padding: const EdgeInsets.all(10),
                      child: TimesheetShiftsWidget(
                        shift: widget.record.shift,
                        onChange: (newShift) {
                          setState(() {
                            widget.record.shift = newShift;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: isPortrait ? 220 : null,
                  child: Flex(
                    direction: isPortrait ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GroupBoxWidget(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            margin: const EdgeInsets.all(5),
                            bgColor: Colors.white.withOpacity(0.1),
                            title: "Catégorie (Projet)",
                            child: DropdownButton(
                                underline: Container(),
                                dropdownColor: Color.lerp(Colors.black, Colors.white, 0.3),
                                isExpanded: true,
                                items: projects.map((project) {
                                  return DropdownMenuItem(
                                    value: project,
                                    child: Text(project.name,
                                      style: const TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: widget.record.project,
                                onChanged: (selectedProject) {
                                  setState(() {
                                    widget.record.project = selectedProject;
                                    widget.record.subProject = selectedProject?.subProjects.first;
                                  });
                                }
                            )
                        ),
                      ),
                      Expanded(
                        child: (widget.record.project?.subProjects ?? []).length < 2 ? Container () :
                        GroupBoxWidget(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          margin: const EdgeInsets.all(5),
                          bgColor: Colors.white.withOpacity(0.1),
                          title: "Sous-projet",
                          child: DropdownButton(
                              underline: Container(),
                              dropdownColor: Color.lerp(Colors.black, Colors.white, 0.3),
                              isExpanded: true,
                              items: widget.record.project?.subProjects.map((subProject) {
                                return DropdownMenuItem(
                                  value: subProject,
                                  child: Text(subProject.name,
                                    style: const TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: widget.record.subProject,
                              onChanged: (selectedSubProject) {
                                setState(() {
                                  widget.record.subProject = selectedSubProject;
                                });
                              }
                          ),
                        ),
                      ),
                      Expanded(
                        child: GroupBoxWidget(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          margin: const EdgeInsets.all(5),
                          bgColor: Colors.white.withOpacity(0.1),
                          title: "Activité",
                          child: DropdownButton(
                              underline: Container(),
                              dropdownColor: Color.lerp(Colors.black, Colors.white, 0.3),
                              isExpanded: true,
                              items: activities.map((activity) {
                                return DropdownMenuItem(
                                  value: activity,
                                  child: Text(activity.name,
                                    style: const TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: widget.record.activity,
                              onChanged: (selectedActivity) {
                                setState(() {
                                  widget.record.activity = selectedActivity;
                                });
                              }
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        widget.record is TimesheetRecord ?
        IconButton(onPressed: isSaving ? null : onRemove, icon: const Icon(Icons.delete_forever), color: Colors.red, iconSize: 35,) :
        const SizedBox(),
        Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.horizontal,
          children: [
            IconButton(onPressed: isSaving ? null : onCancel, icon: const Icon(Icons.cancel), color: Colors.blueGrey, iconSize: 35,),
            IconButton(onPressed: isSaving ? null : onAccept, icon: const Icon(Icons.check_circle), color: Colors.green, iconSize: 35,)
          ],
        ),
      ],
    );
  }

  onCancel() {
    Navigator.pop(context, null);
  }

  onRemove() {
    Navigator.pop(context, null);
    TimesheetRecord record = (widget.record as TimesheetRecord);
    record.remove;
    widget.week.removeWhere((element) => element.id == record.id);
  }

  onAccept() {
    setState(() {
      isSaving = true;
    });
    if (widget.record is! TimesheetRecord) {
      widget.record.save().then((value) {
        widget.week.add(value!);
        Navigator.pop(context);
      });
    } else {
      (widget.record as TimesheetRecord).save().then((value) {
        widget.record.controller.add(widget.record);
        widget.week.controller.add(widget.week);
        Navigator.pop(context);
      });
    }
  }
}


extension StringExt on String? {
  bool get isVowel {
    if (this == null) {
      return false;
    }
    return ["a", "à", "e", "é", "è", "ê", "i", "ï", "o", "ô", "u", "ù", "û"].contains(this!.characters.first.toLowerCase());
  }
}

