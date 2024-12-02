import 'package:fluent_ui/fluent_ui.dart';

class TreatmentsField extends StatefulWidget {
  final String label;

  const TreatmentsField({super.key, required this.label});

  @override
  State<TreatmentsField> createState() => _TreatmentsFieldState();
}

class _TreatmentsFieldState extends State<TreatmentsField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.label;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(FluentIcons.text_field),
        SizedBox(
          width: 5,
        ),
        Text('حقل كتابة'),
        SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 200,
          child: TextBox(
            controller: controller,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        IconButton(icon: Icon(FluentIcons.delete), onPressed: () {})
      ],
    );
  }
}
