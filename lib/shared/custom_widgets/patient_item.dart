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
                      patientName: widget.patientData['firstname'] +
                          ' ' +
                          widget.patientData['lastname'],
                    )));
          }),
    );
  }
}

class PatientDetailedItem extends StatefulWidget {
  final Map patientData;
  const PatientDetailedItem({super.key, required this.patientData});

  @override
  State<PatientDetailedItem> createState() => _PatientDetailedItemState();
}

class _PatientDetailedItemState extends State<PatientDetailedItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 1, 8, 12),
      child: MouseRegion(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text(widget.patientData['firstname'])),
                Expanded(child: Text(widget.patientData['lastname'])),
                Expanded(child: Text(widget.patientData['age'])),
                Expanded(child: Text(widget.patientData['phone_number'])),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(FluentPageRoute(
                  builder: (context) => PatientScreen(
                        id: widget.patientData['id'],
                        patientName: widget.patientData['firstname'] +
                            ' ' +
                            widget.patientData['lastname'],
                      )));
            }),
      ),
    );
  }
}
