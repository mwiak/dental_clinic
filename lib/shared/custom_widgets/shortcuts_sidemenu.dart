import 'package:dental_clinic/shared/public_methods/navigation.dart';
import 'package:dental_clinic/view_model/shortcuts_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class ShortcutsSidemenu extends StatefulWidget {
  final Function onClose;
  final TextEditingController controller;

  const ShortcutsSidemenu(
      {super.key, required this.onClose, required this.controller});

  @override
  State<ShortcutsSidemenu> createState() => _ShortcutsSidemenuState();
}

class _ShortcutsSidemenuState extends State<ShortcutsSidemenu> {
  @override
  Widget build(BuildContext context) {
    Provider.of<ShortcutsProvider>(context, listen: false).getALlShortcuts();
    return Container(
      width: 300,
      height: 300,
      child: Column(
        children: [
          TextBox(),
          Consumer<ShortcutsProvider>(builder: (context, value, child) {
            return Expanded(
                child: ListView.builder(
                    itemCount: value.shortcuts.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                          onTap: () {
                            widget.controller.text = widget.controller.text +
                                ' ' +
                                value.shortcuts[i]['value'];
                          },
                          child: Text(value.shortcuts[i]['value']));
                    }));
          }),
          IconButton(
              icon: Icon(FluentIcons.cancel),
              onPressed: () {
                widget.onClose.call();
              })
        ],
      ),
    );
  }
}
