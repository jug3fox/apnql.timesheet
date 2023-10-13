import 'package:apnql_timesheet/wear/timesheet/list.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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

class WearShapeWidget extends StatefulWidget {
  final Widget child;
  const WearShapeWidget(this.child, {Key? key}) : super(key: key);

  @override
  State<WearShapeWidget> createState() => _WearShapeWidgetState();
}

class _WearShapeWidgetState extends State<WearShapeWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: widget.child,
      )
    );
  }
}

class WearAppBar extends Container {
  WearAppBar({
    super.key,
    EdgeInsets? padding,
    required super.height,
    required BuildContext context,
    required Widget child
  }) : super(
    //color: Colors.red.withOpacity(0.5),
    width: 200,
    child: Card(
      clipBehavior: Clip.none,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(55),
            bottomRight: Radius.circular(55),
          )
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      color: Theme.of(context).primaryColor,
      child: Container(
        padding: EdgeInsets.only(top: 2, bottom: 2).add(padding ?? EdgeInsets.zero),
        child: child,
      ),
    )
  );
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
        theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            //backgroundColor: Colors.red
          )
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
      color: Colors.black,
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

