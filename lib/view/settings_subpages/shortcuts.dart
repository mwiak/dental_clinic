import 'package:dental_clinic/view_model/shortcuts_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../shared/custom_widgets/editor_text_box.dart';

class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({super.key});

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage> {
  void showAddShortcutDialog(BuildContext context) async {
    TextEditingController valueC = TextEditingController();
    TextEditingController categoryC = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 500),
        title: Text('إضافة اختصار جديد'),
        content: Column(
          children: [
            EditorTextBox(
              controller: valueC,
              label: 'الاختصار',
              isEditing: true,
            ),
          ],
        ),
        actions: [
          Button(
            child: Text('إغلاق'),
            onPressed: () {
              Navigator.pop(context);
              // Delete file here
            },
          ),
          FilledButton(
            child: Text('إضافة'),
            onPressed: () async {
              if (valueC.text.isNotEmpty) {
                await Provider.of<ShortcutsProvider>(context, listen: false)
                    .addShortcut(valueC.text.trim(), categoryC.text.trim());
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CommandBar(primaryItems: [
            CommandBarButton(
                onPressed: () {
                  showAddShortcutDialog(context);
                },
                label: Text('إضافة اختصار جديد'))
          ]),
          Consumer<ShortcutsProvider>(builder: (context, value, child) {
            return Expanded(
                child: ListView.builder(
                    itemCount: value.shortcuts.length,
                    itemBuilder: (context, i) {
                      return Text(value.shortcuts[i]['value']);
                    }));
          })
        ],
      ),
    );
  }
}
