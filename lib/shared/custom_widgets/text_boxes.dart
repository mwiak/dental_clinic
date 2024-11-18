import 'package:fluent_ui/fluent_ui.dart';

import 'package:dental_clinic/shared/theme.dart';

class InputText extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  const InputText(
      {super.key,
      required this.controller,
      required this.label,
      this.placeholder});

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label + '*',
      child: TextBox(
        focusNode: FocusNode(),
        controller: widget.controller,
        placeholder: widget.placeholder,
        style: TextStyle(
          fontSize: fontSizeForTextBox, // Font size of the TextBox text
        ),
        expands: false,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
        ),
      ),
    );
  }
}

class InfoEntrySmall extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final bool readOnly;
  const InfoEntrySmall(
      {super.key,
      required this.controller,
      required this.label,
      this.placeholder,
      required this.readOnly});

  @override
  State<InfoEntrySmall> createState() => _InfoEntrySmallState();
}

class _InfoEntrySmallState extends State<InfoEntrySmall> {
  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label,
      child: TextBox(
        enabled: widget.readOnly,
        // readOnly: widget.readOnly,
        focusNode: FocusNode(),
        controller: widget.controller,
        placeholder: widget.placeholder,
        style: TextStyle(
          fontSize: fontSizeForTextBox, // Font size of the TextBox text
        ),
        expands: false,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
        ),
      ),
    );
  }
}

class InfoEntryLarge extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final bool readOnly;
  const InfoEntryLarge(
      {super.key,
      required this.controller,
      required this.label,
      this.placeholder,
      required this.readOnly});

  @override
  State<InfoEntryLarge> createState() => _InfoEntryLargeState();
}

class _InfoEntryLargeState extends State<InfoEntryLarge> {
  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label,
      child: TextBox(
        minLines: 7,
        maxLines: 10,
        enabled: widget.readOnly,
        // readOnly: widget.readOnly,
        focusNode: FocusNode(),
        controller: widget.controller,
        placeholder: widget.placeholder,
        style: TextStyle(
          fontSize: fontSizeForTextBox, // Font size of the TextBox text
        ),
        expands: false,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
        ),
      ),
    );
  }
}
