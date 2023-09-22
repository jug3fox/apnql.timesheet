import 'package:apnql_timesheet/model/command/main.dart';
import 'package:apnql_timesheet/model/oro/list/main.dart';
import 'package:xml/xml.dart';

import '../main.dart';

class ProjectsBase<T> extends OroList<T> {
  ProjectsBase({super.builder}): super(
    oro: Oro(),
    command: OroCommand(tag: "project_list"),
  );
}

class Projects extends ProjectsBase<Project> {
  List<SubProject> get listAll => expand((element) => element.subProjects).toList();
  Project? findProject(String id) {
    Iterable<SubProject> _list = listAll.where((element) => element.id == int.tryParse(id));
    if (_list.isNotEmpty) {
      return _list.first.parent;
    }
    return null;
  }

  SubProject? findSubProject(String id) {
    Iterable<SubProject> _list = listAll.where((element) => element.id == int.tryParse(id));
    if (_list.isNotEmpty) {
      return _list.first;
    }
    return null;
  }

  Projects(): super(
    builder: (element, {index}) => Project.fromXmlElement(element),
  );
}

class SubProject {
  late int id;
  Project? parent;
  String name;
  XmlElement element;
  SubProject.fromXmlElement(this.element, this.parent) :
        name = element.getElement("description")!.innerText {
    id = int.parse(element.getElement("${this is! Project ? "sub_" : ""}project_id")!.innerText);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, name: $name}";
    return super.toString();
  }
}

class Project extends SubProject {
  List<SubProject> subProjects = [];

  Project.fromXmlElement(XmlElement element) :
        super.fromXmlElement(element, null)
  {
    subProjects.addAll(
        element.findAllElements("sub_project").map((subElement) {
          return SubProject.fromXmlElement(subElement, this);
        })
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "{id: $id, name: $name, subProjects: $subProjects}";
    return super.toString();
  }
}