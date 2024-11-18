import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view/patient_menu_screens/patients_info.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientScreen extends StatefulWidget {
  final int id;
  const PatientScreen({super.key, required this.id});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int topIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        leading: IconButton(
            icon: const Icon(
              FluentIcons.back,
              size: 35,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  FluentPageRoute(builder: (context) => MainScreen()));
            }),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: topIndex,
        onChanged: (int i) => setState(() => topIndex = i),
        items: [
          PaneItem(
            icon: const SizedBox.shrink(),
            title: Text(AppLocalizations.of(context)!.info),
            body: PatientsInfo(patientId: widget.id),
          ),
          PaneItem(
            icon: const SizedBox.shrink(),
            title: Text(AppLocalizations.of(context)!.treatments),
            body: NavigationView(
              content: Center(),
            ),
          ),
          PaneItem(
            icon: const SizedBox.shrink(),
            title: Text(AppLocalizations.of(context)!.implants),
            body: NavigationView(
              content: Center(),
            ),
          ),
          PaneItem(
            icon: const SizedBox.shrink(),
            title: Text(AppLocalizations.of(context)!.payments),
            body: NavigationView(
              content: Center(),
            ),
          ),
          PaneItem(
            icon: const SizedBox.shrink(),
            title: Text(AppLocalizations.of(context)!.reminders),
            body: NavigationView(
              content: Center(),
            ),
          ),
        ],
      ),
    );
  }
}
