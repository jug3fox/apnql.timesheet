import 'dart:async';

import 'package:xml/xml.dart';

import '../command/main.dart';
import '../main.dart';

class Error {
  final int id;
  final String message;

  Error({
    required this.id,
    required this.message
  });
}

class OroElement<T> {

  final StreamController<T> controller = StreamController.broadcast();
  Stream<T> get stream => controller.stream.distinct();

  final StreamController<Error> errorController = StreamController.broadcast();
  Stream<Error> get errorStream => errorController.stream.distinct();

  XmlElement? element;
  final Oro parent;
  final OroCommand command;
  Function(XmlElement element)? builder;
  final Function(Error error)? onError;

  OroElement({
    required this.parent,
    required this.command,
    this.builder,
    this.onError,
  }) {
    parent.send(command).then((value) {
      XmlDocument root = XmlDocument.parse(value.body);
      XmlNode? result = root.firstChild;
      //log(result.toString());
      if (result?.firstElementChild != null && builder != null) {
        element = result!.firstElementChild!;
        if (element?.localName == "error") {
          if (onError != null) {
            int? errorId = int.tryParse(element?.attributes.firstWhere((attrib) => attrib.localName == "code").value ?? "");
            String? errorMessage = element?.innerText;
            if (errorId != null && errorMessage != null) {
              onError!(Error(
                id: errorId,
                message: errorMessage
              ));
            }
          }
        } else {
          builder!(result.firstElementChild!);
          controller.add(this as T);
          controller.sink;
        }
      } else {
        //element = null;
      }
    });
  }

}