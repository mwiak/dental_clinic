import 'package:fluent_ui/fluent_ui.dart';

class ExpensesEntry extends StatefulWidget {
  final String title;
  final num cost;
  final String? date;
  const ExpensesEntry(
      {super.key, required this.title, required this.cost, this.date});

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
    return Center(
      child: Container(
        child: Center(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(widget.title),
              ),
              Expanded(
                flex: 1,
                child: Text('\$ ${widget.cost.toString()}'),
              ),
              Expanded(
                flex: 1,
                child: Text(getDate()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
