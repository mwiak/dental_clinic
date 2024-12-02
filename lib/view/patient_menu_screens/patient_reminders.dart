import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:dental_clinic/shared/custom_widgets/reminder_entry.dart';
import 'package:dental_clinic/view_model/reminders_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../shared/custom_widgets/cost_box.dart';
import '../../shared/custom_widgets/date_pickers.dart';
import '../../shared/custom_widgets/text_boxes.dart';

class PatientReminders extends StatefulWidget {
  final int patientId;
  final String patientName;
  const PatientReminders(
      {super.key, required this.patientId, required this.patientName});

  @override
  State<PatientReminders> createState() => _PatientRemindersState();
}

class _PatientRemindersState extends State<PatientReminders> {
  SqlDb dataHelper = SqlDb();

  TextEditingController reasonC = TextEditingController();
  TextEditingController dateC = TextEditingController();

  Future<List> getAllreminders() async {
    List data = await dataHelper.readData(
        '''SELECT * FROM notifications WHERE patient_id = ${widget.patientId} ''');
    return data;
  }

  Future<void> addReminder(String cause, String date) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO notifications (patient_id,name,title,end_date,status) VALUES (${widget.patientId},'${widget.patientName}','$cause','$date','ongoing')''');
    if (response > 0) {
      setState(() {});
    }
  }

  void validateAddReminder() async {
    if (reasonC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String date = dateC.text;
      String cause = reasonC.text.trim();
      addReminder(cause, date);
    } else {
      showBar(context, 'cant be empty', InfoBarSeverity.warning);
    }
  }

  void showAddReminderDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Text(AppLocalizations.of(context)!.add_reminder),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: reasonC,
                  label: AppLocalizations.of(context)!.reminder_cause,
                  readOnly: true,
                  requiredSymbol: '*',
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 5,
              ),
              DatePickerNullable(
                  label: AppLocalizations.of(context)!.reminder_date,
                  value: dateC),
              SizedBox(
                height: 5,
              ),
            ],
          ),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
                // Delete file here
              },
            ),
            FilledButton(
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () {
                validateAddReminder();
              },
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IconButton(
                  icon: Icon(FluentIcons.add),
                  onPressed: () {
                    showAddReminderDialog(context);
                  }),
            ),
            RemindersHeader(
                title1: AppLocalizations.of(context)!.reminder_cause,
                title2: AppLocalizations.of(context)!.reminder_date,
                title3: AppLocalizations.of(context)!.remaining_days,
                title4: AppLocalizations.of(context)!.status),
          ],
        ),
        Divider(),
        SizedBox(
          height: 20,
        ),
        FutureBuilder(
            future: Provider.of<RemindersProvider>(context)
                .getPatientReminders(widget.patientId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink();
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                return SizedBox(
                  width: 500,
                  height: 400,
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        return ReminderEntry(data: snapshot.data![i]);
                      }),
                );
              }
            })
      ],
    );
  }
}
