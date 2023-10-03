
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:apnql_timesheet/main.dart';
import 'list.dart';
import 'main.dart';
import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/model/general/xml_element.dart';
import 'package:apnql_timesheet/model/project/list.dart';
import 'package:xml/xml.dart';

import '../activity/main.dart';
import '../command/main.dart';
import '../main.dart';

class EmptyTimesheetRecord {
  final StreamController<EmptyTimesheetRecord> controller = StreamController.broadcast();
  Stream<EmptyTimesheetRecord> get stream => controller.stream;
  Stream<String> get timeStream => controller.stream.map((event) => "${event._timeIn}-${event._timeOut}").distinct();

  final StreamController<TimesheetRecord> _addController = StreamController.broadcast();
  Stream<TimesheetRecord> get addStream => _addController.stream;

  covariant Shift? shift;

  TimesheetWeek? parent;

  String? notes;

  covariant Project? project;
  covariant SubProject? subProject;
  covariant Activity? activity;

  final DateTime date;

  covariant TimeOfDay? _timeIn, _timeOut;

  TimeOfDay get timeIn => _timeIn ?? TimeOfDay(hour: 0, minute: 0);
  set timeIn(TimeOfDay newTime) {
    _timeIn = newTime;
    controller.add(this);
  }

  TimeOfDay get timeOut => _timeOut ?? TimeOfDay(hour: 0, minute: 0);
  set timeOut(TimeOfDay newTime) {
    _timeOut = newTime;
    controller.add(this);
  }

  DateTime get timeInDate => DateTime(date.year, date.month, date.day, timeIn.hour, timeIn.minute);
  DateTime get timeOutDate => DateTime(date.year, date.month, date.day, timeOut.hour, timeOut.minute);

  set time(MapEntry<TimeOfDay?, TimeOfDay?> newValue) {
    if (newValue.key != null) {
      _timeIn = newValue.key!;
    }

    if (newValue.value != null) {
      _timeOut = newValue.value!;
    }
  }

  Duration? get minutes => _timeIn == null || _timeOut == null ? null : _timeOut!.difference(_timeIn!);

  Future<TimesheetRecord?> addNew() async {
    Oro oro = Oro();
    OroCommand command = OroCommand(
        tag: "timesheet_tx_add",
        commands: [
          OroCommand(tag: "sub_project_id", innerText: subProject!.id.toString()),
          OroCommand(tag: "date", innerText: DateFormat("yyyy-MM-dd").format(date)),
          OroCommand(tag: "activity_type_id", innerText: activity!.id.toString()),
          OroCommand(tag: "shift", innerText: (shift?.index ?? 1).toString()),
          OroCommand(tag: "time_in", innerText: timeIn.show),
          OroCommand(tag: "time_out", innerText: timeOut.show),
          OroCommand(tag: "minutes", innerText: timeOut.difference(timeIn).inMinutes.toString()),
          OroCommand(tag: "employee_id", innerText: preferences.getInt("employee_id").toString()),
        ]
    );

    Response addResponse = await oro.send(command);
    XmlDocument root = XmlDocument.parse(addResponse.body);
    XmlNode? result = root.firstChild;
    String? newId = result?.firstElementChild?.innerText;

    command = OroCommand(
        tag: "timesheet_tx_get",
        commands: [
          OroCommand(
              tag: "timesheet_tx_id",
              innerText: newId ?? ""
          ),
        ]
    );


    Response getResponse = await oro.send(command);


    preferences.setInt("prefProject", project!.id);
    preferences.setInt("prefSubProject", subProject!.id);
    preferences.setInt("prefActivity", activity!.id);

    root = XmlDocument.parse(getResponse.body);
    result = root.firstChild;
    //log(result.toString());
    if (result?.firstElementChild != null) {
      TimesheetRecord newRecord = TimesheetRecord.fromXmlElement(element: result!.firstElementChild!);
      _addController.add(newRecord);
      return newRecord;
    }

    return null;
  }

  EmptyTimesheetRecord(this.date, {
    this.shift,
    TimeOfDay? timeIn,
    TimeOfDay? timeOut,
    this.parent,
    this.notes,
  }) {
    project = projects.where((element) => element.id == preferences.getInt("prefProject")).isNotEmpty ?
      projects.where((element) => element.id == preferences.getInt("prefProject")).first :
      projects.first;
    subProject = project!.subProjects.where((element) => element.id == preferences.getInt("prefSubProject")).isNotEmpty ?
      project!.subProjects.where((element) => element.id == preferences.getInt("prefSubProject")).first :
      project!.subProjects.first;
    activity = activities.where((element) => element.id == preferences.getInt("prefActivity")).isNotEmpty ?
      activities.where((element) => element.id == preferences.getInt("prefActivity")).first :
      activities.first;

    if (shift != null && (timeIn == null && timeOut == null)) {
      _timeIn = (_timeIn ?? shift!.delay?.start);
      _timeOut = (_timeOut ?? shift!.delay?.end);
    } else if (timeIn != null && timeOut != null) {
      _timeIn = timeIn;
      _timeOut = timeOut;
    }
  }



  EmptyTimesheetRecord get copy {
    EmptyTimesheetRecord copyRecord = EmptyTimesheetRecord(date, shift: shift);

    copyRecord._timeIn = _timeIn;
    copyRecord._timeOut = _timeOut;
    copyRecord.shift = shift;
    copyRecord.activity = activity;
    copyRecord.project = project;
    copyRecord.subProject = subProject;
    copyRecord.notes = notes;
    return copyRecord;
  }
}

class NewRecordTime {
  final TimesheetRecord? record;
  final TimeDirection? direction;
  DateTime? time;

  NewRecordTime({
    this.record,
    this.direction,
    this.time,
  });
}

enum TimeDirection {
  timeIn,
  timeOut,
}

enum TimesheetStatus {
  add,
  update,
  delete,
}

class TimesheetRecord extends EmptyTimesheetRecord {
  final StreamController<TimesheetRecord> controller = StreamController.broadcast();
  Stream<TimesheetRecord> get stream => controller.stream;

  @override
  Duration get minutes => _timeOut.difference(_timeIn);

  XmlElement? element;
  int id;

  @override
  Shift shift;

  TimeOfDay _timeIn, _timeOut;

  @override
  TimeOfDay get timeIn => _timeIn;

  @override
  TimeOfDay get timeOut => _timeOut;

  @override
  late Project project;

  @override
  late SubProject subProject;

  Activity activity;

  @override
  set timeIn(TimeOfDay? newValue) {
    if (newValue != null) {
      _timeIn = newValue;
    }
    controller.add(this);
  }

  @override
  set timeOut(TimeOfDay? newValue) {

    if (newValue != null) {
      _timeOut = newValue;
    }
    controller.add(this);
  }

  set time(MapEntry<TimeOfDay?, TimeOfDay?> entry) {


    if (entry.key != null) {
      _timeIn = entry.key!;
    }

    if (entry.value != null) {
      _timeOut = entry.value!;
    }

    controller.add(this);
  }



  Future<TimesheetRecord?> get remove async {
    Oro oro = Oro();
    OroCommand command = OroCommand(
        tag: "timesheet_tx_delete",
        commands: [
          OroCommand(
              tag: "timesheet_tx_id",
              innerText: id.toString()
          ),
        ]
    );
    Response result = await oro.send(command);
    super.parent?.removeWhere((element) => element.id == id);
    return this;
  }

  Future<TimesheetRecord> get save async {
    Oro oro = Oro();

    OroCommand command = OroCommand(
        tag: "timesheet_tx_edit",
        commands: [
          OroCommand(tag: "timesheet_tx_id", innerText: id.toString()),

          OroCommand(tag: "sub_project_id", innerText: subProject.id.toString()),
          OroCommand(tag: "activity_type_id", innerText: activity.id.toString()),
          OroCommand(tag: "shift", innerText: (shift.index ?? 1).toString()),

          OroCommand(tag: "time_in", innerText: _timeIn.show),
          OroCommand(tag: "time_out", innerText: _timeOut.show),
          OroCommand(tag: "minutes", innerText: _timeOut.difference(_timeIn).inMinutes.toString()),
        ]
    );
    Response result = await oro.send(command);
    controller.add(this);
    return this;
  }


  @override
  EmptyTimesheetRecord get copy {
    EmptyTimesheetRecord copyRecord = EmptyTimesheetRecord(date, shift: shift);
    copyRecord.timeIn = timeIn;
    copyRecord.timeOut = timeOut;
    copyRecord.shift = shift;
    copyRecord.project = project;
    copyRecord.subProject = subProject;
    copyRecord.activity = activity;
    copyRecord.notes = notes;
    return copyRecord;
  }

  TimesheetRecord.fromBase({required this.id, required DateTime date, required EmptyTimesheetRecord record}) :
        activity = record.activity!,

        shift = record.shift!,
        _timeIn = record.timeIn,
        _timeOut = record.timeOut,
        super(date,
          notes: record.notes
      );

  TimesheetRecord.fromXmlElement({
    required XmlElement this.element,
    super.parent,
  }) : id = int.parse(element.getElement("timesheet_tx_id")!.innerText),
        activity = activities.firstWhere((activity) => activity.id == int.parse(element.getElement("activity_type_id")!.innerText)),
        shift = Shift.values.elementAt(element["shift"].toInt),
        _timeIn = element.toTime("date", "time_in"),
        _timeOut = element.toTime("date", "time_out"),
        /*_timeIn = TimeOfDay.fromDateTime(DateTime.parse("${element.getElement("date")!.innerText} "
            "${element.getElement("time_in")!.innerText}")),*/
      super(element.toDate("date")) {
    subProject = projects.findSubProject(element!["sub_project_id"])!;
    project = subProject.parent!;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, timeIn: ${timeIn}, timeOut: ${timeOut}, project: $project, subProject, $subProject, activity: $activity}";
    return super.toString();
  }
}

extension ShiftExt on Shift {
  String get name {
    switch(this) {
      case Shift.none: return "Erreur";
      case Shift.avantMidi: return "avant-midi";
      case Shift.apresMidi: return "après-midi";
      case Shift.nuit: return "soir";
      case Shift.finDeSemaine: return "fin de semaine";
      default: return "Test";
    }
  }

  IconData? get icon {
    switch(this) {
      case Shift.none: return null;
      case Shift.avantMidi: return Icons.wb_twilight;
      case Shift.apresMidi: return Icons.wb_sunny;
      case Shift.nuit: return Icons.bedtime;
      case Shift.finDeSemaine: return Icons.beach_access;
      default: return null;
    }
  }

  Delay? get delay {
    switch(this) {
      case Shift.none: return null;
      case Shift.avantMidi: return Delay(
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
      );
      case Shift.apresMidi: return Delay(
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 16, minute: 0),
      );
      case Shift.nuit: return Delay(
        TimeOfDay(hour: 17, minute: 0),
        TimeOfDay(hour: 23, minute: 59),
      );
      case Shift.finDeSemaine: return null;
      default: return null;
    }
  }
}

enum Shift {
  none,
  avantMidi,
  apresMidi,
  nuit,
  finDeSemaine,
}

class Delay {
  TimeOfDay start;
  TimeOfDay end;
  Duration get difference => start.difference(end);

  Delay(this.start, this.end);
}