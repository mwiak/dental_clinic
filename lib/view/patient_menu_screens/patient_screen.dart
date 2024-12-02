import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view/patient_menu_screens/implants.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_payments.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_reminders.dart';
import 'package:dental_clinic/view/patient_menu_screens/patients_info.dart';
import 'package:dental_clinic/view/patient_menu_screens/treatments.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientScreen extends StatefulWidget {
  final int id;
  final String patientName;
  const PatientScreen({super.key, required this.id, required this.patientName});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int topIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: bucket,
      child: NavigationView(
        appBar: NavigationAppBar(
            leading: IconButton(
                icon: const Icon(
                  FluentIcons.arrow_down_right8,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      FluentPageRoute(builder: (context) => MainScreen()));
                }),
            title: Text.rich(TextSpan(
                text: AppLocalizations.of(context)!.patient_data,
                children: [
                  TextSpan(text: '  '),
                  TextSpan(text: widget.patientName)
                ]))),
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
              body: Treatments(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.implants),
              body: Implants(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.payments),
              body: PatientPayments(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.reminders),
              body: PatientReminders(
                patientId: widget.id,
                patientName: 'sadsadasd',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
