import 'package:fluent_ui/fluent_ui.dart';

void goTo(BuildContext context, Widget route) {
  Navigator.of(context)
      .pushReplacement(FluentPageRoute(builder: (context) => route));
}

void goToPushOnly(BuildContext context, Widget route) {
  Navigator.of(context).push(FluentPageRoute(builder: (context) => route));
}

void safePop(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}
