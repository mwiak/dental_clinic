import 'package:fluent_ui/fluent_ui.dart';

class BasicHeader extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  const BasicHeader(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 100, child: Text(title1)),
            SizedBox(width: 80, child: Text(title2)),
            SizedBox(width: 80, child: Text(title3)),
            SizedBox(width: 80),
          ],
        ),
      ),
    );
  }
}

class RemindersHeader extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final String title4;
  const RemindersHeader(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3,
      required this.title4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Row(
        children: [
          Expanded(child: Text(title1)),
          Expanded(child: Text(title2)),
          Expanded(child: Text(title3)),
          Expanded(child: Text(title4)),
        ],
      ),
    );
  }
}

class GeneralRemindersHeader extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final String title4;
  final String title5;
  const GeneralRemindersHeader(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3,
      required this.title4,
      required this.title5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Row(
        children: [
          Expanded(child: Text(title1)),
          Expanded(child: Text(title2)),
          Expanded(child: Text(title3)),
          Expanded(child: Text(title4)),
          Expanded(child: Text(title5)),
        ],
      ),
    );
  }
}

class HeaderWithButton extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final Function onPressed;
  final IconData iconValue;
  const HeaderWithButton(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3,
      required this.onPressed,
      required this.iconValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 100, child: Text(title1)),
            SizedBox(width: 80, child: Text(title2)),
            SizedBox(width: 80, child: Text(title3)),
            SizedBox(
              width: 80,
              child: IconButton(
                icon: Icon(iconValue),
                onPressed: () {
                  onPressed.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
