import 'package:fluent_ui/fluent_ui.dart';

class SmallTextBox extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  const SmallTextBox(
      {super.key,
      required this.controller,
      required this.label,
      required this.readOnly});

  @override
  State<SmallTextBox> createState() => _SmallTextBoxState();
}

class _SmallTextBoxState extends State<SmallTextBox> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        SizedBox(
          height: 10,
        ),
        IgnorePointer(
          ignoring: !widget.readOnly,
          child: NumberBox(
            enableInteractiveSelection: widget.readOnly,
            min: 0,
            max: 50,
            value: count,
            onChanged: (value) {
              widget.controller.text = value.toString();
            },
            mode: SpinButtonPlacementMode.inline,
          ),
        ),
      ],
    );
  }
}
