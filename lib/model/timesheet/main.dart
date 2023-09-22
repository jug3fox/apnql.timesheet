import 'dart:async';

import 'package:flutter/material.dart';
import 'record.dart';
import 'package:apnql_timesheet/model/general/date.dart';


class TimeSheetDay {
  StreamController<List<EmptyTimesheetRecord>> controller = StreamController.broadcast();
  Stream<List<EmptyTimesheetRecord>> get stream => controller.stream.distinct((prev, next) {
    bool result = prev.length != next.length;
    return result;
  });

  TimeSheetDay get copy {
    TimeSheetDay copyDay = TimeSheetDay(day, records: records.map((e) => e.copy).toList());
    return copyDay;
  }

  TimeOfDay get hoursWorked {
    int minutes = 0;
    if (records.length < 2) {
      if (records.isNotEmpty) {
        minutes =  records.first.timeOut.difference(records.first.timeIn).inMinutes;
      }
    } else {
      minutes = records.map((e) => e.timeOut.difference(e.timeIn).inMinutes)
          .reduce((value, element) => value + element);
    }

    return TimeOfDay(hour: (minutes / 60).floor(), minute: minutes % 60);
  }

  final DateTime day;
  final List<EmptyTimesheetRecord> records;
  bool? toCopy;

  Future<TimesheetRecord?> add(EmptyTimesheetRecord newRecord) async {
    TimesheetRecord? newTimesheet = await newRecord.addNew();

    if (newTimesheet != null) {
      records.add(newTimesheet);
      controller.add(records);
    }
    return newTimesheet;
  }

  Future<TimesheetRecord?> remove(TimesheetRecord newRecord) async {
    TimesheetRecord? recordsRemoved = await newRecord.remove;
    records.removeWhere((record) => record is! TimesheetRecord ? false : record.id == recordsRemoved?.id);
    controller.add(records);
    return recordsRemoved;
  }

  TimeSheetDay(this.day, {required this.records});

  @override
  String toString() {
    // TODO: implement toString
    return records.toString();
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
