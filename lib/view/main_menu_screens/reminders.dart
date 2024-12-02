import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/reminder_entity.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:dental_clinic/view_model/reminders_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../shared/custom_widgets/headers.dart';
import '../../shared/custom_widgets/reminder_entry.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  SqlDb dataHelper = SqlDb();

  Future<List> getAllreminders() async {
    List ongoingData = await dataHelper
        .readData('''SELECT * FROM notifications WHERE status = 'ongoing' ''');
    List dueData = await dataHelper
        .readData('''SELECT * FROM notifications WHERE status =  'due' ''');
    List ongoing = [];
    ongoing = ongoingData.map((reminder) {
      return ReminderEntity(
          id: reminder['id'],
          patientId: reminder['patient_id'],
          patientName: reminder['name'],
          title: reminder['title'] ?? '',
          date: stringToDateN(reminder['end_date']),
          status: reminder['status']);
    }).toList();
    List due = [];
    due = dueData.map((reminder) {
      return ReminderEntity(
          id: reminder['id'],
          patientId: reminder['patient_id'],
          patientName: reminder['name'],
          title: reminder['title'] ?? '',
          date: stringToDateN(reminder['end_date']),
          status: reminder['status']);
    }).toList();

    List filteredOngoing = ongoing
        .where((element) => element.date.difference(DateTime.now()).inHours < 0)
        .toList();
    for (ReminderEntity reminder in filteredOngoing) {
      int response = await dataHelper.updateData(
          ''' UPDATE notifications set status = 'due' WHERE id = ${reminder.id}''');
    }

    List data = filteredOngoing + due;
    print(data);
    List empty = [];
    return data;
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
            GeneralRemindersHeader(
              title2: AppLocalizations.of(context)!.reminder_cause,
              title3: AppLocalizations.of(context)!.reminder_date,
              title4: AppLocalizations.of(context)!.remaining_days,
              title5: AppLocalizations.of(context)!.status,
              title1: AppLocalizations.of(context)!.patient_name,
            ),
          ],
        ),
        Divider(),
        SizedBox(
          height: 20,
        ),
        FutureBuilder(
            future: Provider.of<RemindersProvider>(context).getAllReminders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(AppLocalizations.of(context)!.no_data);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                return SizedBox(
                  width: 500,
                  height: 500,
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        return GeneralReminderEntry(data: snapshot.data![i]);
                      }),
                );
              }
            })
      ],
    );
  }
}
