import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:apnql_timesheet/model/command/main.dart';

class Oro {

  String uri = "https://app.orotimesheet.com/api.php";
  String apiPW = "14109-4d53db74-6c16-4b4b-a4de-0188216a7aaf";
  Encoding? encoding = Encoding.getByName("UTF-8");

  Future<http.Response> send(OroCommand command) {
    String request =
        "<request app=\"orotimesheet\" version=\"8\" password=\"$apiPW\">"
          "$command"
        "</request>";

    Future<http.Response> response = http.post(
        Uri.parse(uri),
        encoding: encoding,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,PUT,PATCH,POST,DELETE",
          "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
          "Content-Type": "application/x-www-form-urlencoded",
          //"xml_request": document
        },
        body: "xml_request=$request"
    );
    return response;
  }

}