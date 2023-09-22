import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

extension XmlElExt on XmlElement {
  String operator[](String find) => getElement(find)!.innerText;
  TimeOfDay toTime(String date, String time) => TimeOfDay.fromDateTime(DateTime.parse("${this[date]} ${this[time]}"));
  DateTime toDate(String date) => DateTime.parse(this[date]);
  DateTime get getDate => DateTime.parse(this["date"]);
}

extension StringExt on String {

  int get toInt => int.parse(this);
}