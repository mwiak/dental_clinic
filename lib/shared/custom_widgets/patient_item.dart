import 'package:dental_clinic/view/patient_menu_screens/patient_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PatientItem extends StatefulWidget {
  final Map patientData;
  const PatientItem({super.key, required this.patientData});

  @override
  State<PatientItem> createState() => _PatientItemState();
}

class _PatientItemState extends State<PatientItem> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Button(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.isHovered) {
                return FluentTheme.of(context).selectionColor;
              }
              return FluentTheme.of(context).cardColor; // Default color
            }),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.patientData['firstname']),
              Text(widget.patientData['lastname']),
              Text(widget.patientData['age'])
            ],
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(FluentPageRoute(
                builder: (context) => PatientScreen(
                      id: widget.patientData['id'],
                    )));
          }),
    );
  }
}
