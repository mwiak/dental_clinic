class ReminderEntity {
  late int id;
  late int patientId;
  late String patientName;

  late String title;
  late DateTime date;
  late String status;

  ReminderEntity(
      {required this.id,
      required this.patientId,
      required this.patientName,
      required this.title,
      required this.date,
      required this.status});
}
