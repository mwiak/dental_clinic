import 'package:fluent_ui/fluent_ui.dart';

void goTo(BuildContext context, Widget route) {
  Navigator.of(context)
      .pushReplacement(FluentPageRoute(builder: (context) => route));
}
