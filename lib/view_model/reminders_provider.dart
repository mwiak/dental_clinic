import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/sqflite.dart';
import '../model/reminder_entity.dart';
import '../shared/public_methods/datetime_methods.dart';

class RemindersProvider extends ChangeNotifier {
  SqlDb dataHelper = SqlDb();

  Future<List> getAllReminders() async {
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

    return data;
  }

  Future<List> getAllRemindersFromIsolate() async {
    return await Isolate.run(getAllReminders);
  }

  Future<List> getPatientReminders(int patientId) async {
    List data = await dataHelper.readData(
        '''SELECT * FROM notifications WHERE patient_id = $patientId ''');
    return data;
  }

  void notify() {
    notifyListeners();
  }
}
