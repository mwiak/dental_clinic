import 'package:fluent_ui/fluent_ui.dart';

import '../modified_widgets/auto_suggest_box.dart' as m;

class AutoSuggestBoxesForPregnancyComplete extends StatefulWidget {
  final List choices;
  final TextEditingController valueC;
  const AutoSuggestBoxesForPregnancyComplete(
      {super.key, required this.choices, required this.valueC});

  @override
  State<AutoSuggestBoxesForPregnancyComplete> createState() =>
      _AutoSuggestBoxesForPregnancyCompleteState();
}

class _AutoSuggestBoxesForPregnancyCompleteState
    extends State<AutoSuggestBoxesForPregnancyComplete> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return m.AutoSuggestBoxCustom<String>(
      controller: widget.valueC,
      placeholder: 'اختر حالة نهاية الحمل',
      items: widget.choices.map((choice) {
        return m.AutoSuggestBoxItem<String>(
            value: choice,
            label: choice,
            onFocusChange: (focused) {
              if (focused) {
                debugPrint('Focused $choice');
              }
            });
      }).toList(),
      onSelected: (item) {
        setState(() => selected = item.value);
      },
    );
  }
}
