import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

class TimeBank {
  late final TimeBankElement accumulated;
  late final TimeBankElement vacations;
  late final TimeBankElement sick;

  TimeBank(XmlElement element) {
    accumulated = TimeBankElement(
        TimeBankBalanceType.accumulated,
        int.tryParse(element.getElement("time_bank_balance_accumulated")?.innerText ?? "")
    );
    vacations = TimeBankElement(
        TimeBankBalanceType.vacations,
        int.tryParse(element.getElement("time_bank_balance_vacations")?.innerText ?? "")
    );
    sick = TimeBankElement(
        TimeBankBalanceType.sick,
        int.tryParse(element.getElement("time_bank_balance_sick")?.innerText ?? "")
    );
  }
}

class TimeBankElement {
  final TimeBankBalanceType type;
  int? value;
  String get timeLeft => "${((value ?? 0) / 60).floor()}:${NumberFormat("00").format((value ?? 0) % 60)}";

  TimeBankElement(this.type, this.value);
}

enum TimeBankBalanceType {
  accumulated,
  vacations,
  sick,
}