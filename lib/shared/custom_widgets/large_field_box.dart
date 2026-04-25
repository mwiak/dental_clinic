import 'package:fluent_ui/fluent_ui.dart';

class LargeFieldBox extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const LargeFieldBox(
      {super.key, required this.controller, required this.label});

  @override
  State<LargeFieldBox> createState() => _LargeFieldBoxState();
}

class _LargeFieldBoxState extends State<LargeFieldBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        SizedBox(
          height: 10,
        ),
        TextBox(
          controller: widget.controller,
          minLines: 7,
          maxLines: 10,
        )
      ],
    );
  }
}
