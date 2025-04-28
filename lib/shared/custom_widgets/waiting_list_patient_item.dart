import 'package:dental_clinic/model/entities/waiting_list_patient.dart';
import 'package:fluent_ui/fluent_ui.dart';

class WaitingListPatientItem extends StatefulWidget {
  final WaitingListPatient data;
  final Function onRemove;
  final Function onOpen;


  const WaitingListPatientItem({super.key, required this.data, required this.onRemove, required this.onOpen});

  @override
  State<WaitingListPatientItem> createState() => _WaitingListPatientItemState();
}

class _WaitingListPatientItemState extends State<WaitingListPatientItem> {
  int id = 0;
  String firstname = '';
  String lastname = '';
  String age = '';

  @override
  void initState() {
    super.initState();
    id = widget.data.id;
    firstname = widget.data.firstname;
    lastname = widget.data.lastname;
    age = widget.data.age;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 60,
      child: Card(
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(child: Text(firstname)),
            Expanded(child: Text(lastname)),
            Expanded(child: Text(age)),
            Button(child: Text('open'), onPressed: () {
              widget.onOpen();
            }),
            SizedBox(
              width: 2,
            ),
            Button(child: Text('remove'), onPressed: () {
              widget.onRemove();
            }),
          ],
        ),
      ),
    );
  }
}
