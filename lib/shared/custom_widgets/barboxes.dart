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

void showCustomBar(
    BuildContext context, String message, InfoBarSeverity type) async {
  await displayInfoBar(context, builder: (context, close) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // semi-transparent white
        borderRadius: BorderRadius.circular(12), // rounded corners
      ),
      clipBehavior: Clip.antiAlias, // to apply rounded corners
      child: InfoBar(
        title: const Text(''),
        content: Text(message),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: type,
        style: InfoBarThemeData(
            // prevent override
            ),
      ),
    );
  });
}
