import 'dart:async';

import 'package:apnql_timesheet/model/command/main.dart';
import 'package:apnql_timesheet/model/main.dart';
import 'package:flutter/material.dart';
import '../oro/list/main.dart';
import 'record.dart';
import 'package:apnql_timesheet/model/general/date.dart';


class TimeSheetDay extends OroList<EmptyTimesheetRecord> {
  StreamController<List<EmptyTimesheetRecord>> controller = StreamController.broadcast();
  Stream<List<EmptyTimesheetRecord>> get stream => controller.stream.distinct((prev, next) {
    bool result = prev.length != next.length;
    return result;
  });

  final int employeeId;

  Iterable<Shift> get shiftLeft => Shift.values.where((element) {
    return !map((e) => e.shift?.index).contains(element.index) && element.index != 0;
  }).toList()..sort((a, b) => a.index.compareTo(b.index));

  Shift? get newShift => shiftLeft.isEmpty ? null : shiftLeft.first;

  TimeSheetDay get copy {
    TimeSheetDay copyDay = TimeSheetDay(day,
        employeeId: employeeId,
        records: map((e) => e.copy).toList()
    );
    return copyDay;
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

  final DateTime day;
  bool? toCopy;

  Future<TimesheetRecord?> add(EmptyTimesheetRecord newRecord) async {
    TimesheetRecord? newTimesheet = await newRecord.save();

    if (newTimesheet != null) {
      add(newTimesheet);
      controller.add(this);
    }
    return newTimesheet;
  }

  remove(dynamic newRecord) async {
    TimesheetRecord? recordsRemoved = newRecord.remove;
    removeWhere((record) => record is! TimesheetRecord ? false : record.id == recordsRemoved?.id);
    controller.add(this);
    return recordsRemoved;
  }

  TimeSheetDay(this.day, {required this.employeeId, required List<EmptyTimesheetRecord> records}) : super.fromList(newList: records);

  TimeSheetDay.fromOro(this.day, {required this.employeeId}) : super(
    command: OroCommand(
        tag: "timesheet_tx_list",
        commands: [
          OroCommand(
              tag: "employee_id",
              innerText: employeeId.toString()
          ),
          OroCommand(
            tag: "date_from",
            innerText: day.onlyDate,
          ),
          OroCommand(
            tag: "date_to",
            innerText: day.onlyDate,
          ),
        ]
    ),
    builder :(element, {index}) {
      TimesheetRecord newRecord = TimesheetRecord.fromXmlElement(element: element);
      newRecord.timeOut.difference(newRecord.timeIn);
      return newRecord;
    }
  );

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
    return super.toString();
  }

  Color? get color {
    if (hoursWorked.inHours == 0) {
      return Color.lerp(Colors.black, Colors.white, 0.7);
    } else if (hoursWorked.inHours < 2) {
      return Color.lerp(Colors.black, Colors.orange, 0.8);
    } else if (hoursWorked.inHours < 5) {
      return Color.lerp(Colors.black, Colors.yellow, 0.6);
    } else if (hoursWorked.inHours < 9) {
      return Color.lerp(Colors.black, Colors.green, 0.8);
    } else {
      return Color.lerp(Colors.black, Colors.red, 0.3);
    }

    return Colors.black;
  }
}

extension TimeDayExt on TimeOfDay{
  Duration difference(TimeOfDay other) {
    return Duration(minutes: minute - other.minute, hours: hour - other.hour);
  }
}
