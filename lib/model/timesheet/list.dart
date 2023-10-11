import 'dart:async';
import 'package:http/http.dart';
import 'package:apnql_timesheet/model/oro/element.dart';
import 'package:apnql_timesheet/model/general/xml_element.dart';

import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/command/main.dart';
import '../../main.dart';
import 'record.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/model/oro/list/main.dart';

import '../main.dart';
import 'main.dart';

class Week {
  late final DateTime start;
  late final DateTime end;

  Week(DateTime date) {
    DateTime _start = date.subtract(Duration(days: date.weekday));
    start = DateTime(_start.year, _start.month, _start.day);
    end = start.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{start: $start, end: $end}";
    return super.toString();
  }
}

class TimesheetWeek extends OroList<TimesheetRecord> {
  @override
  Stream<List<TimesheetRecord>> get stream => controller.stream;

  StreamController<TimeOfDay> hoursWorkedController = StreamController.broadcast();
  Stream<TimeOfDay> get hoursWorkedStream => hoursWorkedController.stream
      .distinct((prev, next) {
        return true;
  });

  StreamController<TimesheetRecord> recordController = StreamController.broadcast();
  Stream<TimesheetRecord> get recordStream => recordController.stream.distinct();

  @override
  add(TimesheetRecord element) {
    super.add(element);
    hoursWorkedController.add(hoursWorked);
    //hoursWorkedController.add(hoursWorked);
  }


  @override
  void removeWhere(bool Function(TimesheetRecord element) test) {
    super.removeWhere(test);
    hoursWorkedController.add(hoursWorked);
    //hoursWorkedController.add(hoursWorked);
  }

  TimeOfDay get hoursWorked {
    int minutes = 0;
    if (length < 2) {
      if (isNotEmpty) {
        minutes =  first.timeOut.difference(first.timeIn).inMinutes;
      }
    } else {
      minutes = map((e) => e.timeOut.difference(e.timeIn).inMinutes)
          .reduce((value, element) => value + element);
    }

    return TimeOfDay(hour: (minutes / 60).floor(), minute: minutes % 60);
  }

  late final TimeSheetWeekStatus status;
  final int employeeId;

  Future<void> updateStatus(WeekStatus newValue) async {
    OroCommand command = OroCommand(
      tag: "timesheet_week_state_set",
      commands: [
        OroCommand(tag: "employee_id", innerText: employeeId.toString()),
        OroCommand(tag: "date", innerText: days.keys.first.onlyDate),
        OroCommand(tag: "state", innerText: newValue.name),
      ]
    );

    await Oro().send(command);
    status.name = newValue.name;
    status.controller.add(status);
    return;
  }


  submit() {
    if (status.status == WeekStatus.submitted) {
      updateStatus(WeekStatus.not_submitted);
    } else if (status.status == WeekStatus.not_submitted) {
      print("i uodate");
      updateStatus(WeekStatus.submitted).then((value) {
        print("i uodated");
        notifications.cancelTimesheetNotification;
      });
    }
  }

  final Week week;
  Map<DateTime, TimeSheetDay?> get days => Map.fromEntries(List.generate(7, (index) {
    DateTime dateTime = week.start.add(Duration(days: index));
    var listRecords = where((element) => element.date.onlyDate == dateTime.onlyDate).toList();
    return MapEntry(
        week.start.add(Duration(days: index)),
        TimeSheetDay(dateTime,
            employeeId: employeeId,
            records: listRecords
        )
    );
  }));

  TimesheetWeek get copy {
    TimesheetWeek newTimesheetWeek = TimesheetWeek(employeeId: employeeId, week: week);
    return newTimesheetWeek;
  }

  //TimesheetWeek.fromDays() : super.fromList(newList: newList)

  TimesheetWeek({
    required this.employeeId,
    Week? week,
  }) : week = week ?? Week(DateTime.now()), super(
    oro: Oro(),
    command: OroCommand(
      tag: "timesheet_tx_list",
      commands: [
        OroCommand(
            tag: "employee_id",
            innerText: employeeId.toString()
        ),
        OroCommand(
          tag: "date_from",
          innerText: (week ?? Week(DateTime.now())).start.onlyDate,
        ),
        OroCommand(
          tag: "date_to",
          innerText: (week ?? Week(DateTime.now())).end.onlyDate,
        ),
      ]
    ),
    builder :(element, {index}) {
      TimesheetRecord newRecord = TimesheetRecord.fromXmlElement(element: element);
      newRecord.timeOut.difference(newRecord.timeIn);
      return newRecord;
    }
  ) {
    status = TimeSheetWeekStatus(
      command: OroCommand(
          tag: "timesheet_week_state_get",
          commands: [
            OroCommand(tag: "employee_id", innerText: employeeId.toString()),
            OroCommand(tag: "date", innerText: days.keys.first.onlyDate)
          ]
      ),
      parent: Oro()
    );
  }

  @override
  operator ==(dynamic other) {
    if (other is! TimesheetWeek) return false;
    return days.entries.first.key.compareTo(other.days.entries.first.key) == 0;
  }
  
}

class TimeSheetWeekStatus extends OroElement {
  @override
  Stream<dynamic> get stream => controller.stream;

  bool get isLocked => status.isLocked;

  String? name;
  String? reason;

  WeekStatus? get status {
    Iterable<WeekStatus> status = WeekStatus.values.where((element) => element.name == name);
    return status.isEmpty ? null : status.first;
  }

  TimeSheetWeekStatus({
    required super.parent,
    required super.command,
  }) {
    builder = (element) {
      name = element["state"];
      reason = element["reason_reject"].isEmpty ? null : element["reason_reject"];
      //print("element: ${element}");
    };
  }
}

extension WeekStatusExt on WeekStatus? {
  Color get color {
    if (this == null) return Colors.white;
    switch(this) {
      case WeekStatus.rejected: return Colors.red;
      case WeekStatus.approved: return Colors.green;
      case WeekStatus.submitted: return Colors.blue;
      case WeekStatus.not_submitted: return Colors.grey;
      default: return Colors.white;
    }
  }

  bool get isLocked => [WeekStatus.approved, WeekStatus.rejected].contains(this);
  bool get isFullLocked => this != WeekStatus.not_submitted;

  IconData get icon {
    if (this == null) return Icons.refresh;
    switch(this) {
      case WeekStatus.rejected: return Icons.cancel;
      case WeekStatus.approved: return Icons.check_circle;
      case WeekStatus.submitted: return Icons.cancel_schedule_send;
      case WeekStatus.not_submitted: return Icons.send;
      default: return Icons.send;
    }
  }

  String? get fullname {
    if (this == null) return "en chargement";
    switch(this) {
      case WeekStatus.rejected: return "Rejeté";
      case WeekStatus.approved: return "Approuvé";
      case WeekStatus.submitted: return "Soumise";
      case WeekStatus.not_submitted: return "Non-soumise";
      default: return "NA";
    }
  }
}

enum WeekStatus {
  // ignore: constant_identifier_names
  not_submitted,
  submitted,
  approved,
  rejected
}
