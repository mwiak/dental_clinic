import 'package:dental_clinic/view/patient_menu_screens/patient_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PatientEntryForPayments extends StatefulWidget {
  final int patientId;
  final String name;
  final num cost;
  final num paid;
  final num remaining;
  const PatientEntryForPayments(
      {super.key,
      required this.name,
      required this.cost,
      required this.paid,
      required this.remaining,
      required this.patientId});

  @override
  State<PatientEntryForPayments> createState() =>
      _PatientEntryForPaymentsState();
}

class _PatientEntryForPaymentsState extends State<PatientEntryForPayments> {
  Color? entryColor;

  void goToPatientPage() {
    Navigator.of(context).pushReplacement(
      FluentPageRoute(
          builder: (context) => PatientScreen(
                id: widget.patientId,
                patientName: widget.name,
              )),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: entryColor,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              entryColor = FluentTheme.of(context).cardColor;
            });
          },
          onExit: (event) {
            setState(() {
              entryColor = null;
            });
          },
          child: Center(
            child: GestureDetector(
              onTap: () {
                goToPatientPage();
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(widget.name),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('\$ ${widget.cost.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('\$ ${widget.paid.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('\$ ${widget.remaining.toStringAsFixed(2)}'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
