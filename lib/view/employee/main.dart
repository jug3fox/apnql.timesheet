import 'package:flutter/material.dart';

import '../../model/employee/main.dart';
import '../../model/timesheet/list.dart';
import '../timesheet/list.dart';

class EmployeeWidget extends StatefulWidget {
  final OroEmployee employee;
  const EmployeeWidget(this.employee, {Key? key}) : super(key: key);

  @override
  State<EmployeeWidget> createState() => _EmployeeWidgetState();
}

class _EmployeeWidgetState extends State<EmployeeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmployeeInfoPage(widget.employee.id))
        );
      },
      tileColor: Colors.black.withOpacity(widget.employee.isShift ? 0.15 : 0.1),
      title: Text(widget.employee.name!),
    );
  }
}

class EmployeeInfoPage extends StatefulWidget {
  final int id;
  const EmployeeInfoPage(this.id, {Key? key}) : super(key: key);

  @override
  State<EmployeeInfoPage> createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  ValueNotifier<double> scale = ValueNotifier(2.3);

  ValueNotifier<TimesheetWeek?> weekCopied = ValueNotifier(null);
  ValueNotifier<bool> isTimesheet = ValueNotifier(false);
  late TimesheetWeek currentWeek;

  late final EmployeeInfo employeeInfo;

  @override
  void initState() {
    // TODO: implement initState
    employeeInfo = EmployeeInfo(widget.id);

    currentWeek = TimesheetWeek(employeeId: widget.id, week: Week(DateTime.now()));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          foregroundColor: Colors.white,
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.primary, Colors.black, 0.5),
          toolbarHeight: isPortrait ? 50 : 24,
          titleSpacing: 0,

          title: Flex(
            direction: Axis.vertical,
            children: [
              StreamBuilder(
                  stream: employeeInfo.stream,
                  builder: (context, snapshot) => Text(employeeInfo.name ?? ""),
              ),
            ],
          ),
          /*actions: [
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: weekCopied,
                  builder: (context, value, child) {
                    if (weekCopied.value == null) return Container();
                    return IconButton(
                      onPressed: weekCopied.value == null ? null : pasteWeek,
                      icon: Icon(Icons.paste),
                      padding: EdgeInsets.zero,
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: weekCopied,
                  builder: (context, value, child) {
                    if (weekCopied.value != null) return Container();
                    return IconButton(
                      onPressed: copyWeek,
                      icon: Icon(Icons.copy_all),
                      padding: EdgeInsets.zero,
                    );
                  },
                ),
              ],
            )
          ],*/
        ),
        body: TimeSheetWeeksWidget(employeeInfo),

      ),
    );
  }



  Future<bool> onWillPop() async {
    weekCopied.value = null;
    return false;

  }
}
