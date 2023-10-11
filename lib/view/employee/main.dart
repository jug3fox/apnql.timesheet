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
          toolbarHeight: isPortrait ? 60 : 35,
          titleSpacing: 0,

          title:
          StreamBuilder(
            stream: employeeInfo.stream,
            builder: (context, snapshot) {
              return SizedBox(
                width: isPortrait ? null : 500,
                child: Flex(
                  direction: isPortrait ? Axis.vertical : Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      //color: Colors.red.withOpacity(0.3),
                      child: Text(employeeInfo.name ?? "",
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                            color: Colors.white
                        ),
                      ),
                    ),
                    Container(
                      //color: Colors.green.withOpacity(0.3),
                      height: 30,
                      width: 200,
                      alignment: isPortrait ? Alignment.topCenter : Alignment.center,
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        direction: Axis.horizontal,
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.coronavirus_outlined,
                                grade: 1,
                                weight: 1,
                                opticalSize: 1,
                                fill: 0.1,
                                size: 26,
                                color: Colors.yellow,
                              ),
                              SizedBox(
                                width: 3,
                                height: 3,
                              ),
                              Text(employeeInfo.bank?.sick.timeLeft ?? "0",
                                style: Theme.of(context).textTheme.labelLarge?.apply(
                                    color: Colors.yellow
                                ),
                              ),
                            ],
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.beach_access,
                                size: 26,
                                color: Colors.green,
                              ),
                              Text(employeeInfo.bank?.vacations.timeLeft ?? "0",
                                style: Theme.of(context).textTheme.labelLarge?.apply(
                                    color: Colors.green
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
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
