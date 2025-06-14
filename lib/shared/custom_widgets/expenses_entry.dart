import 'package:fluent_ui/fluent_ui.dart';

class ExpensesEntry extends StatefulWidget {
  final String title;
  final num cost;
  final String? date;
  final Function onPressed;
  const ExpensesEntry(
      {super.key,
      required this.title,
      required this.cost,
      this.date,
      required this.onPressed});

  @override
  State<ExpensesEntry> createState() => _ExpensesEntryState();
}

class _ExpensesEntryState extends State<ExpensesEntry> {
  String getDate() {
    if (widget.date == '' || widget.date == null) {
      return 'لايوجد تاريخ';
    } else {
      return widget.date!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 100,
            child: Text(widget.title),
          ),
          SizedBox(
            width: 80,
            child: Text('\$ ${widget.cost.toString()}'),
          ),
          SizedBox(
            width: 80,
            child: Text(getDate()),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              icon: Icon(FluentIcons.edit),
              onPressed: () {
                widget.onPressed.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}
