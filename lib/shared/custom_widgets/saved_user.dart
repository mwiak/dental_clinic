import 'package:fluent_ui/fluent_ui.dart';

class SavedUser extends StatefulWidget {
  final int id;
  final String name;
  final String device;
  final bool isConnected;
  final Function() onChangeName;
  final Function() onDelete;

  const SavedUser(
      {super.key,
      required this.id,
      required this.name,
      required this.device,
      required this.isConnected,
      required this.onChangeName,
      required this.onDelete});

  @override
  State<SavedUser> createState() => _SavedUserState();
}

class _SavedUserState extends State<SavedUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: 400,
        height: 70,
        child: Card(
          child: Row(
            children: [
              Expanded(child: Text(widget.name)),
              Expanded(child: Text(widget.device)),
              Expanded(
                  child: widget.isConnected
                      ? Text('متصل 🟢')
                      : Text('غير متصل 🔘')),
              DropDownButton(
                title: Text('الخيارات'),
                items: [
                  MenuFlyoutItem(
                    text: Text('تغيير الاسم'),
                    onPressed: () {
                      widget.onChangeName();
                    },
                  ),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                      text: Text('حذف'),
                      onPressed: () async {
                        widget.onDelete();
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
