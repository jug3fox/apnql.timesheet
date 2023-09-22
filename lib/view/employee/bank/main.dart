import 'package:flutter/material.dart';
import 'package:apnql_timesheet/model/employee/timebank.dart';

import '../../general/custom_ttf.dart';

class TimeBankWidget extends StatefulWidget {
  final TimeBank? bank;
  const TimeBankWidget(this.bank, {Key? key}) : super(key: key);

  @override
  State<TimeBankWidget> createState() => _TimeBankWidgetState();
}

class _TimeBankWidgetState extends State<TimeBankWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.lerp(Colors.green, Colors.white, 0.7),
      child: ExpansionTile(
        title: Text("Banque de temps", style: Theme.of(context).textTheme.titleLarge?.apply(
            fontWeightDelta: 3
        )),
        initiallyExpanded: true,
        children: [

          Container(
            color: Colors.black.withOpacity(0.1),
            child:
            ListTile(
              title: CustomTFF("Accumulés", widget.bank?.accumulated.timeLeft),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.15),
            child:
            ListTile(
              title: CustomTFF("Vacances", widget.bank?.vacations.timeLeft),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
            child:
            ListTile(
              title: CustomTFF("Maladies", widget.bank?.sick.timeLeft),
            ),
          ),
        ],
      ),
    );
  }
}
