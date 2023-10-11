
import 'dart:async';
import 'dart:collection';
import 'package:xml/xml.dart';

import 'package:apnql_timesheet/model/command/main.dart';

import '../../main.dart';

class OroList<T> extends ListBase<T> {
  final StreamController<List<T>> controller = StreamController.broadcast();
  Stream<List<T>> get stream => controller.stream.distinct();

  final StreamController<T> _removeController = StreamController.broadcast();
  Stream<T> get removeStream => _removeController.stream.distinct();

  final StreamController<T> _addController = StreamController.broadcast();
  Stream<T> get addStream => _addController.stream.distinct();

  T Function(XmlElement element, {int? index})? builder;
  final bool Function(XmlElement element)? filter;
  XmlDocument? root;

  bool loaded = false;

  final Oro oro;
  final OroCommand? command;

  final List<T> _list = [];

  @override
  set length(int newLength) { _list.length = newLength; }

  @override
  int get length => _list.length;

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) { _list[index] = value; }

  @override
  add(T element) {
    _list.add(element);
    _addController.add(element);
    controller.add(this);
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _list.removeWhere(test);
    controller.add(this);
    // TODO: implement removeWhere
  }

  @override
  addAll(Iterable<T> element) {
    _list.addAll(element);
    controller.add(this);
  }

  OroList.fromList({
    required Iterable<T> newList,
    this.builder,
    this.filter
  }) : oro = Oro(), command = null {
    _list.addAll(newList);
    controller.add(this);
  }

  OroList({
    Oro? oro,
    this.builder,
    this.filter,
    this.command
  }) : oro = oro ?? Oro() {
    if(command != null && builder != null) {
      this.oro.send(command!).then((value) {
        root = XmlDocument.parse(value.body);
        loaded = true;
        XmlNode? result = root!.firstChild;
        if (result != null) {
          int i = 0;
          for (var e in result.childElements) {
            if (filter == null || filter!(e)) {
              _list.add(
                  builder!(e, index: i++)
              );
            }
          }
          controller.add(this);
          controller.close();
        }
      });
    }
  }
// your custom methods
}