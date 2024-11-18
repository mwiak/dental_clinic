import 'package:fluent_ui/fluent_ui.dart';

import 'main_screen.dart';

class Second extends StatefulWidget {
  const Second({
    super.key,
  });

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: Column(
          children: [
            Text('second'),
            Button(
                child: Text('to1'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    FluentPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
