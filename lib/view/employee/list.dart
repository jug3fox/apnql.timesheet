import 'package:flutter/material.dart';
import 'package:apnql_timesheet/main.dart';
import 'package:apnql_timesheet/model/employee/main.dart';

import 'main.dart';

class EmployeesWidget extends StatefulWidget {
  const EmployeesWidget({Key? key}) : super(key: key);
 
  @override
  State<EmployeesWidget> createState() => _EmployeesWidgetState();
}

class _EmployeesWidgetState extends State<EmployeesWidget> {
  //OroListEmployees employees = OroListEmployees();
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Connexion"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: TextFormField(
          autofocus: true,
          focusNode: focusNode,
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
              labelText: "Entrer votre courriel",
              floatingLabelAlignment: FloatingLabelAlignment.center,
              alignLabelWithHint: true
          ),
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (emailAddress) {

            EmployeeInfo.fromEmail(emailAddress).then((info) {
              if (info == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  elevation: 5,
                  content: Text("Erreur",
                    style: Theme.of(context).textTheme.titleLarge?.apply(
                        fontWeightDelta: 3,
                        color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(30),

                  backgroundColor: Colors.red,
                ));
                controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);
                focusNode.requestFocus();
              } else {
                info.stream.listen((event) async {
                  /*
                  final Email email = Email(
                    body: 'Il y a eu une tentative de connexion sur votre compte OroTimesheet.\n'
                        'Si vous ne vous êtes pas connecté, veuillez communiquer avec votre superviseur.',
                    subject: 'Nouvelle connexion sur votre feuille de temps',
                    recipients: [emailAddress],
                    isHTML: false,
                  );

                  await FlutterEmailSender.send(email);
                  */
                  preferences.setInt("employee_id", event.id);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EmployeeInfoPage(event.id),)
                  );
                });
              }
            });
          },
        ),
      ),
    );
    /*return LoadingStreamWidget(
        list: employees,
        builder: (employee) => EmployeeWidget(employee)
    );
    return StreamBuilder(
      stream: employees.stream,
      builder: (context, snapshot) {
        if(employees.isEmpty) return Center(
          child: Text("Laoding"),
        );
        return ListView(
          children: employees.map((employee) => EmployeeWidget(employee)).toList(),
        );
      },
    );*/
  }
}
