

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateExt on DateTime {
  String get onlyDate => DateFormat("yyyy-MM-dd").format(this);
  String get onlyTextDate => DateFormat("d MMM yyyy", "fr_CA").format(this);
  String get onlyTime => DateFormat("HH:mm:ss").format(this);
  String get onlyMinutes => DateFormat("HH:mm").format(this);

  int get weekDay => weekday == 7 ? 0 : weekday;
}

extension ToDExt on TimeOfDay {
  String get show => "${NumberFormat("00").format(hour)}:${NumberFormat("00").format(minute)}";

  Duration get duration => Duration(hours: hour, minutes: minute);

  double get inHours => duration.inMinutes / 60;

  String get toNumber => NumberFormat("0.##").format(inHours);
}

class DateTimeStream {
  StreamController<DateTime> controller = StreamController.broadcast();
  Stream<DateTime> get stream => controller.stream.distinct();

  //DateTime current = DateTime.now();
  Timer? _timer;

  DateTimeStream() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      controller.add(DateTime.now());
    });
  }
}