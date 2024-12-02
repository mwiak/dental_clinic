import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';

class DropDown extends StatefulWidget {
  final String label;
  final List options;
  final TextEditingController value;
  DropDown(
      {super.key,
      required this.label,
      required this.options,
      required this.value});

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  List<ComboBoxItem> options = [];
  String? value;

  void setOptions() {
    for (Map option in widget.options) {
      String text = option['option_value'];

      options.add(ComboBoxItem(
        child: Text(text),
        value: text,
      ));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setOptions();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label,
      child: ComboBox(
        value: value,
        onChanged: (val) {
          setState(() {
            widget.value.text = val;
            value = val;
          });
        },
        items: options,
      ),
    );
  }
}
