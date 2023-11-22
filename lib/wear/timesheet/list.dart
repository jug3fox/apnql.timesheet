import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/model/timesheet/record.dart';
import 'package:apnql_timesheet/model/timesheet/types.dart';
import 'package:apnql_timesheet/wear/timesheet/add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../view/timesheet/week.dart';
import '../main.dart';

class ListDaysWidget extends StatefulWidget {
  final int employeeId;
  const ListDaysWidget({required this.employeeId, Key? key}) : super(key: key);

  @override
  State<ListDaysWidget> createState() => _ListDaysWidgetState();
}

class _ListDaysWidgetState extends State<ListDaysWidget> with AutomaticKeepAliveClientMixin {
  static int get startPage => 100;

  ValueNotifier<int> _currentPage = ValueNotifier(startPage);

  PageController dayController = PageController(
    initialPage: startPage,
    viewportFraction: 1.1,
    //viewportFraction: 0.9,
  );


  @override
  Widget build(BuildContext context) {
    return WearShapeWidget(
        Scaffold(
          body: PageView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: dayController,

            itemBuilder: (BuildContext context, int index) {
              TimeSheetDay day = TimeSheetDay.fromOro(DateTime.now().add(Duration(days: index - 100)),
                employeeId: widget.employeeId,
              );
              return WatchTimesheetDayWidget(
                day: day,
              );
            },
            onPageChanged: (value) => _currentPage.value = value,
          ),
          backgroundColor: Colors.black,

          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: true ? null : ValueListenableBuilder(
            valueListenable: _currentPage,
            builder: (context, value, child) {
              return FloatingActionButton(
                mini: true,
                onPressed: _currentPage == 100 ? null : () {
                  dayController.animateToPage(100,
                      duration: Duration(milliseconds: 500 + 100 * (_currentPage.value - 100).abs().toInt()),
                      curve: Curves.easeOut
                  );
                },
                disabledElevation: 1,
                backgroundColor: _currentPage.value == 100 ? Color.lerp(Colors.blueGrey, Colors.white, 0.5) : null,
                child: Opacity(
                  opacity: _currentPage.value == 100 ? 0.6 : 1,
                  child: Icon(Icons.today),
                ),
              );
            },
          ),
        )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class WatchTimesheetDayWidget extends StatefulWidget {
  final TimeSheetDay day;

  const WatchTimesheetDayWidget({
    required this.day,
    Key? key
  }) : super(key: key);

  @override
  State<WatchTimesheetDayWidget> createState() => _WatchTimesheetDayWidgetState();
}

class _WatchTimesheetDayWidgetState extends State<WatchTimesheetDayWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {

    return StreamBuilderWithLoad(
      stream: widget.day.stream,
      builder: (context, snapshot) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black,
            child: Container(
              color: Colors.white,
              child: Scaffold(
                backgroundColor: Colors.blueGrey.withOpacity(0),
                body: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      child: ListView(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                            ),
                            ...(widget.day..sort((a, b) => a.timeIn.difference(b.timeIn).inMinutes)).map((record) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => TimesheetRecordAddPage(
                                        day: widget.day,
                                        record: record
                                    ))
                                  );
                                },
                                child: Card(
                                    color: record.project?.type.lightColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)
                                    ),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            //color: Colors.red.withOpacity(0.3),
                                            child: Icon(record.project?.type.icon, size: 18,),
                                          ),
                                          Expanded(
                                            child: Text("${record.timeIn.show} - ${record.timeOut!.show}",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.labelMedium?.apply(
                                                  fontSizeDelta: 4
                                              ),
                                            ),
                                          ),

                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            //color: Colors.red.withOpacity(0.3),
                                            child: Icon(record.subProject?.subType.icon, size: 18,),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                              );
                            }).toList(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 2 - 40,
                              width: 100,
                            ),
                          ]
                      ),
                    ),
                    WearAppBar(
                      context: context,
                      height: 40,
                      padding: EdgeInsets.only(top: 3),
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat("EEEE", "fr_CA").format(widget.day.day).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium?.apply(
                                color: Colors.white.withOpacity(0.7),
                                fontSizeDelta: 0,
                                fontWeightDelta: 5
                            ),
                          ),
                          Text(DateFormat("d MMMM ${widget.day.day.year == DateTime.now().year ? "" : "yyyy"}", "fr_CA").format(widget.day.day).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium?.apply(
                                color: Colors.white,
                                fontSizeDelta: 2,
                                fontWeightDelta: 5
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: widget.day.day.onlyDate,
                  mini: true,
                  backgroundColor: Colors.black,
                  onPressed: () {
                    Navigator.push(context,
                      CupertinoPageRoute(
                        builder: (context) => TimesheetRecordAddPage(
                          day: widget.day,
                          record: EmptyTimesheetRecord(
                            widget.day.day,
                          )
                        ),
                      )
                    );
                  },
                  child: Icon(Icons.add),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              ),
            ),
          ),
        );
      }
    );

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class StreamBuilderWithLoad<T> extends StreamBuilder<T> {
  final Widget? loadWidget;
  StreamBuilderWithLoad({
    super.key,
    required super.stream,
    this.loadWidget,
    required Widget Function(BuildContext, AsyncSnapshot ) builder
  }) : super(
    builder: (context, snapshot) {
      return Stack(
        children: [
          builder(context, snapshot),
          LoadingIconWidget(!snapshot.hasData),
        ],
      );
      if (snapshot.connectionState == ConnectionState.done) return builder(context, snapshot);
      return loadWidget ??  Container(
        alignment: Alignment.center,
        child: const Icon(Icons.refresh,
          size: 40,
        ),
      );
    }
  );

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class LoadingIcon extends StatefulWidget {
  const LoadingIcon({Key? key}) : super(key: key);

  @override
  State<LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


