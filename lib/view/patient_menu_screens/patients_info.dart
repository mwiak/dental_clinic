import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientsInfo extends StatefulWidget {
  final int patientId;
  const PatientsInfo({super.key, required this.patientId});

  @override
  State<PatientsInfo> createState() => _PatientsInfoState();
}

class _PatientsInfoState extends State<PatientsInfo> {
  bool enabled = true;
  TextEditingController firstnameC = TextEditingController();
  TextEditingController lastnameC = TextEditingController();
  TextEditingController ageC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController medicalC = TextEditingController();
  TextEditingController surgeryC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntrySmall(
                      controller: firstnameC,
                      label: AppLocalizations.of(context)!.first_name,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: lastnameC,
                      label: AppLocalizations.of(context)!.last_name,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: ageC,
                      label: AppLocalizations.of(context)!.age,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: phoneC,
                      label: AppLocalizations.of(context)!.phone,
                      readOnly: enabled,
                    ),
                    InfoLabel(
                      label: 'date of registration',
                      child: Row(
                        children: [
                          Text('20.20.2020'),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: FilledButton(
                                child: Text('edit'), onPressed: () {}))
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntryLarge(
                      controller: medicalC,
                      label: AppLocalizations.of(context)!.medical_history,
                      readOnly: enabled,
                    ),
                    InfoEntryLarge(
                      controller: surgeryC,
                      label: AppLocalizations.of(context)!.surgery_history,
                      readOnly: enabled,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntryLarge(
                      controller: notesC,
                      label: AppLocalizations.of(context)!.notes,
                      readOnly: enabled,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
