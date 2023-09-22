import 'package:apnql_timesheet/model/command/main.dart';
import 'package:apnql_timesheet/model/oro/list/main.dart';
import 'package:xml/xml.dart';
import 'package:apnql_timesheet/model/general/xml_element.dart';

import '../main.dart';

class Activities extends OroList<Activity> {
  Activities() : super(
    oro: Oro(),
    command: OroCommand(tag: "activity_type_list"),
    builder: Activity.fromXmlElement
  );
}

class Activity {
  XmlElement element;
  int id;
  int? index;
  String name, status;
  
  Activity.fromXmlElement(this.element, {this.index}) :
        id = int.parse(element["activity_type_id"]),
        name = element["description"],
        status = element["status"];

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, name: $name, status: $status}";
    return super.toString();
  }
}