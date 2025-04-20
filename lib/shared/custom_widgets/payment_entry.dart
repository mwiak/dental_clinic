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

class PaymentSEntry extends StatelessWidget {
  final int id;
  final String title;
  final num amount;
  final String date;
  final String notes;
  final VoidCallback onTap;
  const PaymentSEntry(
      {super.key,
      required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.notes,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Button(
        onPressed: onTap,
        child: SizedBox(
          width: 450,
          child: Row(
            children: [
              Expanded(child: Text(title)),
              Expanded(child: Text(amount.toString())),
              SizedBox(
                width: 50,
              ),
              Expanded(child: Text(date)),
              SizedBox(
                width: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
