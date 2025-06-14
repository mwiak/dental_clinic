import 'package:fluent_ui/fluent_ui.dart';

class PaymentEntry extends StatelessWidget {
  final String title;
  final num amount;
  final String date;
  final String notes;
  final Function onPay;
  const PaymentEntry(
      {super.key,
      required this.title,
      required this.amount,
      required this.date,
      required this.notes,
      required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 100, child: Text(title)),
            SizedBox(width: 80, child: Text(amount.toString())),
            SizedBox(width: 80, child: Text(date)),
            SizedBox(
              width: 80,
              child: Button(
                  child: Text('دفع'),
                  onPressed: () {
                    onPay.call();
                  }),
            )
          ],
        ),
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
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 100, child: Text(title)),
            SizedBox(width: 80, child: Text(amount.toString())),
            SizedBox(width: 80, child: Text(date)),
            SizedBox(
                width: 80,
                child: IconButton(
                    icon: Icon(FluentIcons.edit),
                    onPressed: () {
                      onTap.call();
                    })),
          ],
        ),
      ),
    );
  }
}
