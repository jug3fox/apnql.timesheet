import 'package:apnql_timesheet/model/command/main.dart';
import 'package:apnql_timesheet/model/employee/list.dart';
import 'package:apnql_timesheet/model/main.dart';
import 'package:apnql_timesheet/model/oro/element.dart';
import 'package:xml/xml.dart';

class EmployeeGroup extends OroElement<EmployeeGroup> {
  int id;
  String? description;

  OroListEmployees? list;
  EmployeeGroup(this.id) : super(
    parent: Oro(),
    command: OroCommand(
        tag: "employee_group_get",
      commands: [
        OroCommand(
          tag: "employee_group_id",
          innerText: id.toString()
        )
      ],
    )
  ) {
    builder = (element) {
      Iterable<int> list_employee_id = element.findAllElements("employee").map((employee_element) {
        return int.parse(employee_element.getElement("employee_id")!.innerText);
      });
      list = OroListEmployees(
        filter: (element) => list_employee_id.contains(int.tryParse(element.getElement("employee_id")?.innerText ?? ""))
      );
      description = element.getElement("description")?.innerText;
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{element: $element}";
    return super.toString();
  }
}