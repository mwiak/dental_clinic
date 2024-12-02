import 'package:fluent_ui/fluent_ui.dart';

class FieldForText extends StatefulWidget {
  final TextEditingController controller;
  final String fieldName;
  const FieldForText(
      {super.key, required this.controller, required this.fieldName});

  @override
  State<FieldForText> createState() => _FieldForTextState();
}

class _FieldForTextState extends State<FieldForText> {
  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.fieldName,
      child: TextBox(
        controller: widget.controller,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
        ),
      ),
    );
  }
}
