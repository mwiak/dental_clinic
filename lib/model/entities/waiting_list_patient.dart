class WaitingListPatient {
  late int id;
  late String firstname;
  late String lastname;
  late String age;
  late String phone;

  WaitingListPatient({
    required Map data,
  }) {
    id = data['id'];
    firstname = data['firstname'];
    lastname = data['lastname'];
    age = data['age'];
    phone = data['phone_number'];
  }
}
