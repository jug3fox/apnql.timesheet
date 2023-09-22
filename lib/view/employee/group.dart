import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/employee/group.dart';
import 'package:apnql_timesheet/model/employee/main.dart';

import '../general/custom_ttf.dart';

class EmployeeGroupWidget extends StatefulWidget {
  final EmployeeGroup? group;
  final int? currentEmployeeId;
  const EmployeeGroupWidget(this.group, {this.currentEmployeeId, Key? key}) : super(key: key);

  @override
  State<EmployeeGroupWidget> createState() => _EmployeeGroupWidgetState();
}

class _EmployeeGroupWidgetState extends State<EmployeeGroupWidget> {
  //late final EmployeeGroup group;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //group = EmployeeGroup(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.group?.stream,
        builder: (context, snapshot) {
          return ExpansionTile(
            title: CustomTFF("Groupe", widget.group?.description),
            children: [
              StreamBuilder(
                  stream: widget.group?.list?.stream,
                  builder: (context, snapshot) {
                    return Flex(
                      direction: Axis.vertical,
                      children: (widget.group?.list ?? List<OroEmployee>.empty()).map((employee) {
                        return Container(
                          color: Colors.blue.withOpacity(employee.isShift ? 0.15 : 0.1),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 30),
                            //tileColor: Colors.black.withOpacity(employee.isShift ? 0.15 : 0.1),
                            title: Text(employee.name ?? "NA",
                              style: TextStyle(
                                  color: widget.currentEmployeeId == employee.id ? Colors.grey : null,
                                  fontSize: 18
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
              )
            ],
          );
        },
    );
  }
}
