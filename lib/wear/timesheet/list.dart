import 'package:apnql_timesheet/model/general/date.dart';
import 'package:apnql_timesheet/model/timesheet/main.dart';
import 'package:apnql_timesheet/view/timesheet/week.dart';
import 'package:flutter/material.dart';

class ListDaysWidget extends StatefulWidget {
  final int employeeId;
  const ListDaysWidget({required this.employeeId, Key? key}) : super(key: key);

  @override
  State<ListDaysWidget> createState() => _ListDaysWidgetState();
}

class _ListDaysWidgetState extends State<ListDaysWidget> {

  PageController dayController = PageController(
    initialPage: 100,
    //viewportFraction: 0.9,
  );


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500)
        ),
        child: PageView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: dayController,

          itemBuilder: (BuildContext context, int index) {
            TimeSheetDay day = TimeSheetDay.fromOro(DateTime.now().add(Duration(days: index - 100)),
              employeeId: widget.employeeId,
            );
            return WatchTimesheetDayWidget(
              day: day,
            );
          },
        ),
      )
    );
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      controller: dayController,

      itemBuilder: (BuildContext context, int index) {
        TimeSheetDay day = TimeSheetDay.fromOro(DateTime.now().add(Duration(days: index - 100)),
          employeeId: widget.employeeId,
        );
        return WatchTimesheetDayWidget(
          day: day,
        );
      },
    );
  }
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

    return Center(
      child: Container(
        child: Scaffold(
          backgroundColor: Colors.blueGrey.withOpacity(0.4),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(70.0), // here the desired height
            child: Card(
              margin: EdgeInsets.zero,
              color: Theme.of(context).primaryColor,
              child: Container(
                padding: EdgeInsets.only(top: 15, bottom: 5),
                child: Text(widget.day.day.onlyDate,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.apply(
                    color: Colors.white,
                    fontWeightDelta: 5
                  ),
                ),
              ),
            ),
          ),
          body: StreamBuilderWithLoad(
            stream: widget.day.stream,
            builder: (context, snapshot) {
              return Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Text(snapshot.connectionState.toString()),
                    (snapshot.connectionState == ConnectionState.done && widget.day.isEmpty ? Text("Is Empty",
                      textAlign: TextAlign.center,
                    ) :
                    Flex(
                      direction: Axis.vertical,
                      children: (widget.day..sort((a, b) => a.timeIn.difference(b.timeIn).inMinutes)).map((record) {
                        return ListTile(
                          title: Text("${record.timeIn.show} - ${record.timeOut.show}",
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text("${record.project?.name} - ${record.subProject?.name} - ${record.activity?.name}",
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    )
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ]
              );
            },
          ),
        ),
      ),
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
          LoadingIconWidget(snapshot.connectionState != ConnectionState.done),
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


