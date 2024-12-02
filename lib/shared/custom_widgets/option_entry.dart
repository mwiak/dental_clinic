import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionEntry extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  const OptionEntry(
      {super.key, required this.controller, required this.onDelete});

  @override
  State<OptionEntry> createState() => _OptionEntryState();
}

class _OptionEntryState extends State<OptionEntry> {
  bool enabled = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        child: Row(
          children: [
            Flexible(
              child: InfoLabel(
                label: AppLocalizations.of(context)!.option,
                child: TextBox(
                  enabled: enabled,
                  controller: widget.controller,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
                icon: Icon(FluentIcons.delete),
                onPressed: () {
                  widget.onDelete();
                })
          ],
        ),
      ),
    );
  }
}
