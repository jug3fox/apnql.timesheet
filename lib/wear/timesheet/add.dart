import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/model/timesheet/record.dart';
import 'package:apnql_timesheet/wear/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../view/general/group_box.dart';
import '../../view/timesheet/button_time.dart';

class TimesheetRecordAddPage extends StatefulWidget {
  final TimeSheetDay day;
  final EmptyTimesheetRecord record;
  const TimesheetRecordAddPage({
    required this.day,
    required this.record,
    Key? key
  }) : super(key: key);

  @override
  State<TimesheetRecordAddPage> createState() => _TimesheetRecordAddPageState();
}

class _TimesheetRecordAddPageState extends State<TimesheetRecordAddPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 100) Navigator.pop(context);
      },
      child: WearShapeWidget(
          Scaffold(
            backgroundColor: Colors.black.withOpacity(0.92),
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                TimesheetRecordAddWidget(
                  record: widget.record,
                ),
                WearAppBar(
                    height: 40,
                    padding: EdgeInsets.only(
                        top: 5
                    ),
                    context: context,
                    child: Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      direction: Axis.vertical,
                      children: [
                        Text("Ajout pour",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium?.apply(
                              fontWeightDelta: 2
                          ),
                        ),
                        Text(DateFormat("d MMMM", "fr_CA").format(widget.record.date),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.apply(
                            fontWeightDelta: 5,
                          ),
                        )
                      ],
                    )
                ),
                Align(
                  alignment: Alignment(-0.8, -0.8),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black,

                      child: Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ),
                )
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "accept",
                  mini: true,
                  onPressed: save,
                  child: Icon(Icons.save_alt),
                ),
                FloatingActionButton(
                  heroTag: "cancel",
                  backgroundColor: Colors.red,
                  mini: true,
                  onPressed: cancel,
                  child: Icon(Icons.close),
                ),
              ],
            ),
          )
      ),
    );
  }

  cancel() {
    widget.record.remove;
    Navigator.pop(context);
  }

  save() {
    widget.record.save().then((value) {
      //widget.week.add(value!);

      cancel();
    });
  }
}

class TimesheetRecordAddWidget extends StatefulWidget {
  final EmptyTimesheetRecord record;
  const TimesheetRecordAddWidget({required this.record, Key? key}) : super(key: key);

  @override
  State<TimesheetRecordAddWidget> createState() => _TimesheetRecordAddWidgetState();
}

class _TimesheetRecordAddWidgetState extends State<TimesheetRecordAddWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          //color: Colors.blueGrey,
          width: 50,
          padding: EdgeInsets.only(left: 25, right: 25, top: 65 , bottom: 10),
          alignment: Alignment.center,
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            direction: Axis.horizontal,
            children: [
              TimeButtonWidget(
                onChange: (TimeOfDay newTime) {
                  setState(() {
                    widget.record.timeIn = newTime;
                  });
                },
                time: widget.record.timeIn,
                padding: EdgeInsets.all(-10),
                title: 'In',
              ),
              TimeButtonWidget(
                onChange: (TimeOfDay newTime) {
                  setState(() {
                    widget.record.timeOut = newTime;
                  });
                },
                time: widget.record.timeOut ?? widget.record.timeIn,
                title: 'Out',
                padding: EdgeInsets.all(-10),
              )
            ],
          )
        ),
        GroupBoxWidget(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            bgColor: Colors.white.withOpacity(0.1),
            title: "Catégorie (Projet)",
            child: DropdownButton(
                padding: EdgeInsets.all(5),
                isDense: true,
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
        GroupBoxWidget(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          bgColor: Colors.white.withOpacity(0.1),
          title: "Sous-projet",
          child: DropdownButton(
              isDense: true,
              padding: EdgeInsets.all(5),
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
        GroupBoxWidget(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          bgColor: Colors.white.withOpacity(0.1),
          title: "Activité",
          child: DropdownButton(
            padding: EdgeInsets.all(5),
            isDense: true,
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
        SizedBox(
          height: 70,
          width: 70,
        )
      ],
    );
  }
}

