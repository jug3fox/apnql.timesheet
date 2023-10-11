import 'package:apnql_timesheet/wear/timesheet/list.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import '../main.dart';


void main() async {
  List<Future> preLoading = [];
  WidgetsFlutterBinding.ensureInitialized();

  preferences = await SharedPreferences.getInstance();
  await projects.stream.first;
  await activities.stream.first;

  preLoading
      .add(initializeDateFormatting('fr_CA'));

  //await preferences.remove("employee_id");
  await Future.wait(preLoading);
  notifications;
  await preferences.setInt("employee_id", 1);

  //await preferences.remove("employee_id");

  runApp(OroTimesheetWearApp(isWatch: false,));
}

class OroTimesheetWearApp extends StatefulWidget {
  final bool isWatch;
  const OroTimesheetWearApp({required this.isWatch, Key? key}) : super(key: key);

  @override
  State<OroTimesheetWearApp> createState() => _OroTimesheetWearAppState();
}

class _OroTimesheetWearAppState extends State<OroTimesheetWearApp> {
  @override
  Widget build(BuildContext context) {
    int? id = preferences.getInt("employee_id");
    if (!widget.isWatch) {
      return MaterialApp(
        home: ActiveWatchFace(
          employeeId: id ?? 0,
        ),
      );
    }

    return WatchShape(
      builder: (BuildContext context, WearShape shape, Widget? child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return mode == WearMode.active ? ActiveWatchFace(
              employeeId: id ?? 0,
            ) : AmbientWatchFace();
          },
        );
      },
    );
  }
}

class ActiveWatchFace extends StatefulWidget {
  final int employeeId;
  const ActiveWatchFace({required this.employeeId, Key? key}) : super(key: key);

  @override
  State<ActiveWatchFace> createState() => _ActiveWatchFaceState();
}

class _ActiveWatchFaceState extends State<ActiveWatchFace> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListDaysWidget(
        employeeId: widget.employeeId
      ),
    );
  }
}

class AmbientWatchFace extends StatefulWidget {
  const AmbientWatchFace({Key? key}) : super(key: key);

  @override
  State<AmbientWatchFace> createState() => _AmbientWatchFaceState();
}

class _AmbientWatchFaceState extends State<AmbientWatchFace> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
    );
  }
}

