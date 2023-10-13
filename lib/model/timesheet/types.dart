import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ProjectType {
  work,
  leave,
}

enum SubProjectType {
  home,
  office,

  annualLeave,
  sick,
  overtime,
  holiday,
  freeLeave,
}

extension ProjectTypeIntExt on int {
  ProjectType get toProject {
    return ProjectType.values[this];
  }
}

extension ProjectTypeStringExt on String {
  ProjectType get toProject {
    return ProjectType.values.firstWhere((element) => element.name == this);
  }
}

extension SubProjectTypeStringExt on String {
  SubProjectType? get toSubProject {
    if (toLowerCase().contains("bureau")) {
      return SubProjectType.office;
    } else if (toLowerCase().contains("maison")) {
      return SubProjectType.home;
    } else if (toLowerCase().contains("annuel")) {
      return SubProjectType.annualLeave;
    } else if (toLowerCase().contains("malad")) {
      return SubProjectType.sick;
    } else if (toLowerCase().contains("overtime")) {
      return SubProjectType.overtime;
    } else if (toLowerCase().contains("non payés")) {
      return SubProjectType.freeLeave;
    } else if (toLowerCase().contains("férié")) {
      return SubProjectType.holiday;
    }
    return null;
  }
}

extension ProjectTypeExt on ProjectType {
  IconData get icon {
    switch (this) {
      case ProjectType.work: return Icons.devices_other;
      case ProjectType.leave: return Icons.logout;
      default: return Icons.home;
    }
  }

  Color get color {
    switch (this) {
      case ProjectType.work: return Colors.green;
      case ProjectType.leave: return Colors.yellow;
      default: return Colors.black;
    }
  }

  Color? get lightColor {
    return Color.lerp(color, Colors.white, 0.6);
  }
}

extension SubProjectTypeExt on SubProjectType? {
  IconData get icon {
    switch (this) {
      case SubProjectType.home: return Icons.home;
      case SubProjectType.office: return Icons.apartment;


      case SubProjectType.annualLeave: return Icons.beach_access;
      case SubProjectType.sick: return Icons.sick;
      case SubProjectType.overtime: return Icons.work_history;
      case SubProjectType.freeLeave: return Icons.money_off;
      case SubProjectType.holiday: return Icons.celebration;
      default: return Icons.cancel;
    }
  }

  /*
  Color get color {
    switch (this) {
      case ProjectType.work: return Colors.green;
      case ProjectType.leave: return Colors.yellow;
      default: return Colors.black;
    }
  }

  Color? get lightColor {
    return Color.lerp(color, Colors.white, 0.6);
  }*/
}

enum WorkLocation {
  office,
  home,
}