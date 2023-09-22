import 'package:apnql_timesheet/model/command/main.dart';
import 'package:apnql_timesheet/model/oro/list/main.dart';
import 'package:apnql_timesheet/model/main.dart';

import 'main.dart';


class OroListEmployees extends OroList<OroEmployee> {
  static const String tag = "employee_list";

  OroListEmployees({
    super.filter
  }) : super(
    oro: Oro(),
    command: OroCommand(tag: tag),
    builder: (element, {index}) => OroEmployee.fromXmlElement(element, index: index)
  ) {
  }
}