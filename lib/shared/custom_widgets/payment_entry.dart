import 'package:fluent_ui/fluent_ui.dart';

class PaymentEntry extends StatelessWidget {
  final String title;
  final num amount;
  final String date;
  final String notes;
  const PaymentEntry(
      {super.key,
      required this.title,
      required this.amount,
      required this.date,
      required this.notes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Expanded(child: Text(amount.toString())),
          Expanded(child: Text(date)),
        ],
      ),
    );
  }
}
