import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/entities/reminder_entity.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_screen.dart';
import 'package:dental_clinic/view_model/reminders_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ReminderEntry extends StatefulWidget {
  final Map data;
  const ReminderEntry({super.key, required this.data});

  @override
  State<ReminderEntry> createState() => _ReminderEntryState();
}

class _ReminderEntryState extends State<ReminderEntry> {
  int hours = 0;
  String value = '';
  String status = '';
  bool isDue = false;
  SqlDb dataHelper = SqlDb();

  void setUp() {
    DateTime endDate = stringToDateN(widget.data['end_date']);
    DateTime now = DateTime.now();
    int remainingDays = endDate.difference(now).inHours;
    Duration difference = endDate.difference(now);
    hours = remainingDays;
    status = widget.data['status'];
    if (status == 'ongoing') {
      if (difference.isNegative || hours == 0) {
        isDue = true;
        modifyReminderStatus('due');
      }
    } else if (status == 'due') {
      isDue = true;
    } else if (status == 'checked') {}

    setState(() {});
  }

  String parseStatus(String status, BuildContext context) {
    switch (status) {
      case 'ongoing':
        return AppLocalizations.of(context)!.ongoing;

      case 'due':
        return AppLocalizations.of(context)!.passed;
      case 'checked':
        return AppLocalizations.of(context)!.read;
      default:
        return AppLocalizations.of(context)!.no_data;
    }
  }

  String generateLeftDays() {
    int days = (hours / 24).round();
    if (AppLocalizations.of(context)!.localeName == 'ar') {
      if (hours == 0) {
        return '0';
      } else if (hours < 0) {
        return 'متأخر' + ' ' + '${days.abs()} ' + 'يوم';
      } else if (hours > 0 && hours < 24) {
        return 'باقي يوم واحد';
      } else {
        return 'باقي' + ' ' + '${days.abs()} ' + 'يوم';
      }
    } else {
      if (hours == 0) {
        return '0';
      } else if (hours < 0) {
        return '${days.abs()} ' + ' ' + 'passed';
      } else if (hours > 0 && hours < 24) {
        return 'one day left';
      } else {
        return '${days.abs()} ' + ' ' + 'to go';
      }
    }
  }

  Future<void> modifyReminderStatus(String newStatus) async {
    int respnose = await dataHelper.updateData(
        ''' UPDATE notifications set status = '$newStatus' WHERE id = ${widget.data['id']}''');
    if (respnose > 0) {
      status = newStatus;
      setState(() {});
    }
  }

  Future<void> deleteReminder() async {
    int respnose = await dataHelper.deleteData(
        ''' DELETE FROM notifications WHERE id = ${widget.data['id']}''');
    if (respnose > 0) {
      setState(() {
        //notifyListenrs
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: SizedBox(
        width: 500,
        child: Row(
          children: [
            Expanded(child: Text(widget.data['title'])),
            Expanded(child: Text(widget.data['end_date'])),
            Expanded(child: Text(generateLeftDays())),
            Expanded(
                child: DropDownButton(
              title: Text(parseStatus(status, context)),
              items: [
                MenuFlyoutItem(
                    text: Tooltip(
                      message:
                          AppLocalizations.of(context)!.status_hover_message,
                      displayHorizontally: true,
                      useMousePosition: false,
                      style: TooltipThemeData(preferBelow: true),
                      child: Text(AppLocalizations.of(context)!.mark_as_read),
                    ),
                    onPressed: !isDue
                        ? null
                        : status == 'checked'
                            ? null
                            : () {
                                modifyReminderStatus('checked');
                              }),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                    text: Text(AppLocalizations.of(context)!.generic_delete),
                    onPressed: () async {
                      await deleteReminder();
                      Provider.of<RemindersProvider>(context, listen: false)
                          .notify();
                    }),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class GeneralReminderEntry extends StatefulWidget {
  final ReminderEntity data;

  const GeneralReminderEntry({super.key, required this.data});

  @override
  State<GeneralReminderEntry> createState() => _GeneralReminderEntryState();
}

class _GeneralReminderEntryState extends State<GeneralReminderEntry> {
  int hours = 0;
  String value = '';
  String status = '';
  bool isDue = false;
  SqlDb dataHelper = SqlDb();

  void setUp() {
    DateTime endDate = widget.data.date;
    DateTime now = DateTime.now();
    hours = endDate.difference(now).inHours;
    Duration difference = endDate.difference(now);

    status = widget.data.status;
    if (status == 'ongoing') {
      if (difference.isNegative || hours == 0) {
        isDue = true;
        modifyReminderStatus('due');
      }
    } else if (status == 'due') {
      isDue = true;
    } else if (status == 'checked') {}

    setState(() {});
  }

  String parseStatus(String status, BuildContext context) {
    switch (status) {
      case 'ongoing':
        return AppLocalizations.of(context)!.ongoing;

      case 'due':
        return AppLocalizations.of(context)!.passed;
      case 'checked':
        return AppLocalizations.of(context)!.read;
      default:
        return AppLocalizations.of(context)!.no_data;
    }
  }

  String generateLeftDays() {
    int days = (hours / 24).round();
    if (AppLocalizations.of(context)!.localeName == 'ar') {
      if (hours == 0) {
        return '0';
      } else if (hours < 0) {
        return 'متأخر' + ' ' + '$days' + 'يوم';
      } else if (hours > 0 && hours < 24) {
        return 'باقي يوم واحد';
      } else {
        return 'باقي' + ' ' + '$days' + 'يوم';
      }
    } else {
      if (hours == 0) {
        return '0';
      } else if (hours < 0) {
        return '$days' + ' ' + 'passed';
      } else if (hours > 0 && hours < 24) {
        return 'one day left';
      } else {
        return '$days' + ' ' + 'to go';
      }
    }
  }

  Future<void> modifyReminderStatus(String newStatus) async {
    int respnose = await dataHelper.updateData(
        ''' UPDATE notifications set status = '$newStatus' WHERE id = ${widget.data.id}''');
    if (respnose > 0) {
      status = newStatus;
      setState(() {});
    }
  }

  Future<void> deleteReminder() async {
    int respnose = await dataHelper.deleteData(
        ''' DELETE FROM notifications WHERE id = ${widget.data.id}''');
    if (respnose > 0) {
      setState(() {
        //notifyListenrs
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: SizedBox(
        width: 500,
        child: Row(
          children: [
            Expanded(child: Text(widget.data.patientName)),
            Expanded(child: Text(widget.data.title)),
            Expanded(child: Text(dateToString(widget.data.date))),
            Expanded(child: Text(generateLeftDays())),
            Expanded(
                child: DropDownButton(
              title: Text(parseStatus(status, context)),
              items: [
                MenuFlyoutItem(
                    text: Tooltip(
                      message:
                          AppLocalizations.of(context)!.status_hover_message,
                      displayHorizontally: true,
                      useMousePosition: false,
                      style: TooltipThemeData(preferBelow: true),
                      child: Text(AppLocalizations.of(context)!.mark_as_read),
                    ),
                    onPressed: !isDue
                        ? null
                        : status == 'checked'
                            ? null
                            : () async {
                                await modifyReminderStatus('checked');
                                Provider.of<RemindersProvider>(context,
                                        listen: false)
                                    .notify();
                              }),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                    text:
                        Text(AppLocalizations.of(context)!.go_to_patient_page),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(FluentPageRoute(
                          builder: (context) => PatientScreen(
                              id: widget.data.patientId,
                              patientName: widget.data.patientName)));
                    }),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                    text: Text(AppLocalizations.of(context)!.generic_delete),
                    onPressed: () async {
                      await deleteReminder();
                      Provider.of<RemindersProvider>(context, listen: false)
                          .notify();
                    }),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
