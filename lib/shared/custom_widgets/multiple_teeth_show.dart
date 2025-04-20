import 'package:dental_clinic/shared/custom_widgets/tooth_multiple.dart';
import 'package:fluent_ui/fluent_ui.dart';

class MultipleTeethShow extends StatefulWidget {
  final List codes;
  const MultipleTeethShow({super.key, required this.codes});

  @override
  State<MultipleTeethShow> createState() => _MultipleTeethShowState();
}

class _MultipleTeethShowState extends State<MultipleTeethShow> {
  bool checkSelected(int code) {
    return widget.codes.contains(code);
  }

  List<Widget> upperTeethBuild() {
    List<Widget> teethLeft = [];
    for (int x = 11; x <= 18; x++) {
      teethLeft.add(ToothMultipleDisplay(
        code: x,
        isActive: checkSelected(x),
      ));
    }
    List<Widget> teethRight = [];
    for (int x = 21; x <= 28; x++) {
      teethRight.add(ToothMultipleDisplay(
        code: x,
        isActive: checkSelected(x),
      ));
    }
    teethRight = teethRight.reversed.toList();

    List<Widget> teeth = teethRight + teethLeft;
    return teeth;
  }

  List<Widget> downTeethBuild() {
    List<Widget> teethLeft = [];
    for (int x = 41; x <= 48; x++) {
      teethLeft.add(ToothMultipleDisplay(
        code: x,
        isActive: checkSelected(x),
      ));
    }
    List<Widget> teethRight = [];
    for (int x = 31; x <= 38; x++) {
      teethRight.add(ToothMultipleDisplay(
        code: x,
        isActive: checkSelected(x),
      ));
    }
    teethRight = teethRight.reversed.toList();

    List<Widget> teeth = teethRight + teethLeft;
    return teeth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: upperTeethBuild(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: downTeethBuild(),
            ),
          ],
        ))
      ],
    );
  }
}
