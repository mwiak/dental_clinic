import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class CostBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? requiredSign;
  const CostBox(
      {super.key,
      required this.label,
      required this.controller,
      this.requiredSign});

  @override
  State<CostBox> createState() => _CostBoxState();
}

class _CostBoxState extends State<CostBox> {
  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: widget.label + '*',
      child: SizedBox(
        width: 200,
        child: Row(
          children: [
            Expanded(
              child: TextBox(
                controller: widget.controller,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).cardColor,
                  border: Border.all(
                    color: FluentTheme.of(context)
                        .inactiveColor, // Unfocused border color
                    width: 1.0, // Set border width for unfocused state
                  ),
                  borderRadius: BorderRadius.circular(
                      4.0), // Optional: Customize corner radius
                ),
              ),
            ),
            Text('  \$')
          ],
        ),
      ),
    );
  }
}
