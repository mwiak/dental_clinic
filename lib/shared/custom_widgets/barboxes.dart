import 'package:fluent_ui/fluent_ui.dart';

void showBar(BuildContext context, String message, InfoBarSeverity type) async {
  await displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: const Text(''),
      content: Text(message),
      action: IconButton(
        icon: const Icon(FluentIcons.clear),
        onPressed: close,
      ),
      severity: type,
    );
  });
}
