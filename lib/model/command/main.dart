class OroCommand {
  final String tag;
  late final List<OroCommand>? commands;
  final String? innerText;
  String get commandLine {
    String inside = "";

    for (OroCommand _command in commands!) {
      inside += _command.commandLine;
    }
    return "<$tag>$inside${innerText ?? ""}</$tag>";
  }

  OroCommand({
    Map<String, dynamic>? jsonCommands,
    required this.tag,
    this.innerText,
    List<OroCommand>? commands,
  }) {
    this.commands = (jsonCommands?.entries.where((entry) => entry.value != null).map((entry) {
      return OroCommand(tag: entry.key, innerText: entry.value.toString());
    }).toList() ?? commands) ?? [];
  }

  @override
  String toString() {
    // TODO: implement toString
    return commandLine;
  }
}