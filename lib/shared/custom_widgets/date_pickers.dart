import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class DatePickerBasic extends StatefulWidget {
  final String label;
  final TextEditingController value;
  final String? requiredSymbol;
  const DatePickerBasic(
      {super.key,
      required this.label,
      required this.value,
      this.requiredSymbol});

  @override
  State<DatePickerBasic> createState() => _DatePickerBasicState();
}

class _DatePickerBasicState extends State<DatePickerBasic> {
  DateTime now = DateTime.now();

  String currentDateToString(DateTime dateInput) {
    String format = 'dd/MM/yyyy';
    DateFormat dateFormatter = DateFormat(format);
    String dateString = dateFormatter.format(dateInput);
    return dateString;
  }

  @override
  void initState() {
    super.initState();
    widget.value.text = currentDateToString(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label + (widget.requiredSymbol ?? ''),
      child: DatePicker(
        selected: now,
        onChanged: (value) {
          setState(() {
            now = value;
            widget.value.text = currentDateToString(value);
          });
        },
      ),
    );
  }
}

class DatePickerNullable extends StatefulWidget {
  final String label;
  final TextEditingController value;
  final String? date;
  final String? requiredSymbol;

  DatePickerNullable(
      {super.key,
      required this.label,
      required this.value,
      this.date,
      this.requiredSymbol});

  @override
  State<DatePickerNullable> createState() => _DatePickerNullableState();
}

class _DatePickerNullableState extends State<DatePickerNullable> {
  DateTime? now;

  String currentDateToString(DateTime dateInput) {
    String format = 'dd/MM/yyyy';
    DateFormat dateFormatter = DateFormat(format);
    String dateString = dateFormatter.format(dateInput);
    return dateString;
  }

  DateTime? stringToDate(String dateString) {
    if (dateString.isNotEmpty) {
      String format = 'dd/MM/yyyy';
      DateFormat dateFormatter = DateFormat(format);
      DateTime date = dateFormatter.parse(dateString);
      return date;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    now = stringToDate(widget.date ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label + (widget.requiredSymbol ?? ''),
      child: SizedBox(
        width: 400,
        child: Row(
          children: [
            DatePicker(
              selected: now,
              onChanged: (value) {
                setState(() {
                  now = value;
                  widget.value.text = currentDateToString(value);
                });
              },
            ),
            IconButton(
                icon: Icon(FluentIcons.delete),
                onPressed: () {
                  setState(() {
                    now = null;
                    widget.value.text = '';
                  });
                })
          ],
        ),
      ),
    );
  }
}

class BirthDatePicker extends StatefulWidget {
  final String label;
  final TextEditingController value;
  final String? requiredSymbol;
  const BirthDatePicker(
      {super.key,
      required this.label,
      required this.value,
      this.requiredSymbol});

  @override
  State<BirthDatePicker> createState() => _BirthDatePickerState();
}

class _BirthDatePickerState extends State<BirthDatePicker> {
  DateTime selectedDate = DateTime(2000, 1, 1);

  @override
  void initState() {
    super.initState();
    widget.value.text = dateToString(
      DateTime(2000, 1, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label + (widget.requiredSymbol ?? ''),
      child: DatePicker(
        selected: selectedDate,
        onChanged: (value) {
          setState(() {
            selectedDate = value;
            widget.value.text = dateToString(value);
          });
        },
      ),
    );
  }
}
