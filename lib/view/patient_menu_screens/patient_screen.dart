import 'package:dental_clinic/shared/strings/patient_screen.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view/patient_menu_screens/medical_record.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_reminders.dart';
import 'package:dental_clinic/view/patient_menu_screens/patients_info.dart';
import 'package:dental_clinic/view/patient_menu_screens/pregnancy.dart';
import 'package:dental_clinic/view/patient_menu_screens/sessions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientScreen extends StatefulWidget {
  final int id;
  final String patientName;
  int? prePageIndex = 0;
  int? index = 0;
  PatientScreen(
      {super.key,
      required this.id,
      required this.patientName,
      this.prePageIndex,
      this.index});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int topIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    topIndex = widget.index ?? 0;
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
                  Navigator.of(context).pushReplacement(FluentPageRoute(
                      builder: (context) => MainScreen(
                            selectedIndex: widget.prePageIndex == 0
                                ? 0
                                : widget.prePageIndex,
                          )));
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
              title: Text(LABELS['pregnancies']!),
              body: Pregnancy(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(LABELS['sessions']!),
              body: Sessions(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(LABELS['medical_record']!),
              body: MedicalRecord(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(LABELS['drugs']!),
              body: MedicalRecord(patientId: widget.id),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(LABELS['reminders']!),
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
