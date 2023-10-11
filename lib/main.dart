import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/activity/main.dart';
import 'package:apnql_timesheet/view/employee/list.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:apnql_timesheet/view/employee/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;


import 'model/notifications/service.dart';
import 'model/project/list.dart';

late final SharedPreferences preferences;

final Projects projects = Projects();
final Activities activities = Activities();
final NotificationService notifications = NotificationService();

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
  await notifications;

  //await preferences.remove("employee_id");

  runApp(OroTimesheetApp());
}

class OroTimesheetApp extends StatefulWidget {
  const OroTimesheetApp({Key? key}) : super(key: key);

  @override
  State<OroTimesheetApp> createState() => _OroTimesheetAppState();
}

class _OroTimesheetAppState extends State<OroTimesheetApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    int? id = preferences.getInt("employee_id");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
          sliderTheme: SliderThemeData(
              valueIndicatorColor: ColorScheme.fromSeed(seedColor: Colors.blueGrey).primary, // This is what you are asking for
              inactiveTrackColor: Colors.white.withOpacity(0.3), // Custom Gray Color
              activeTrackColor: ColorScheme.fromSeed(seedColor: Colors.blueGrey).primary,
              thumbColor: Color.lerp(Colors.white, ColorScheme.fromSeed(seedColor: Colors.blueGrey).primary, 0.3),
              overlayColor: Color(0x29EB1555),  // Custom Thumb overlay Color
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
              activeTickMarkColor: Color.lerp(Colors.black, Colors.white, 0.9),
              inactiveTickMarkColor: Color.lerp(Colors.black, Colors.white, 0.5),
              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 6)
          ),
          dialogBackgroundColor: Color.lerp(Colors.white, Colors.black, 0.5),
          appBarTheme: AppBarTheme(
              centerTitle: true
          )
      ),
      home: id != null ? EmployeeInfoPage(id) : const EmployeesWidget(),
    );
  }
}
