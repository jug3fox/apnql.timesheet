import 'package:apnql_timesheet/model/employee/group.dart';
import 'package:apnql_timesheet/model/employee/list.dart';
import 'package:apnql_timesheet/model/timesheet/list.dart';
import 'package:xml/xml.dart';
import 'package:apnql_timesheet/model/oro/element.dart';

import '../command/main.dart';
import 'timebank.dart';
import '../main.dart';

mixin OroEmployeeBase {
  int? id;
  String? name;
  String? email;

  _fromXmlElement(XmlElement element) {
    name = element.getElement("name")?.innerText;
    email = element.getElement("email")?.innerText;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, name: $name, email: $email}";
  }
}

class OroEmployee with OroEmployeeBase {
  @override
  final int id;

  @override
  final String email;

  int? index;
  bool get isShift => index == null ? false : (index! % 2 == 1);


  OroEmployee({
    required this.id,
    required this.email,
  });

  OroEmployee.fromXmlElement(XmlElement element, {this.index}) :
        id = int.parse(element.getElement("employee_id")!.innerText),
        email = element.getElement("email")!.innerText{
    _fromXmlElement(element);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, name: $name, email: $email}";
  }
}

class EmployeeInfo extends OroElement<EmployeeInfo> with OroEmployeeBase {
  static final Oro oro = Oro();
  static const String tag = "employee_get";
  static const String childTag = "employee_id";

  String? status;
  TimeBank? bank;
  EmployeeGroup? group;
  TimesheetWeek? _week;

  TimesheetWeek? get week => _week;

  set week(var newValue) {
    if (newValue is Week) {
      TimesheetWeek newWeek = TimesheetWeek(employeeId: id, week: newValue);
      _week = newWeek;
    } else if(newValue is TimesheetWeek) {
      _week = newValue;
    }
  }
  
  static Future<EmployeeInfo?> fromEmail(String email) async {
    OroListEmployees list = OroListEmployees();
    Iterable<OroEmployee> result = await list.stream.first;
    result = result.where((element) => element.email == email);
    print("result : $result");
    if (result.isNotEmpty) {
      return EmployeeInfo(result.first.id);
    }
    return null;
  }

  @override
  final int id;

  EmployeeInfo(this.id, {super.onError}) :
        super(
        parent: oro,
        command: OroCommand(
            tag: tag,
            commands: [
              OroCommand(
                  tag: childTag,
                  innerText: id.toString()
              )
            ]
        ),

      ) {
    builder = (element) {
      _fromXmlElement(element);
      week = TimesheetWeek(employeeId: id);
      int? groupId = int.tryParse(element.getElement("employee_group_id")?.innerText ?? "");
      group = groupId == null ? null : EmployeeGroup(groupId);
      //group = EmployeeGroup(id);
      status = element.getElement("status")?.innerText;
      bank = TimeBank(element);
    };
  }
}