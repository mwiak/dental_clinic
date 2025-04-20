import 'package:dental_clinic/shared/custom_widgets/tooth_multiple.dart';
import 'package:fluent_ui/fluent_ui.dart';

class MultipleTeethTreatment extends StatefulWidget {
  final List selectedCodes;
  final bool isGeneral;
  final String description;
  final void Function(bool)? onIsGeneralChanged;

  const MultipleTeethTreatment({
    super.key,
    required this.selectedCodes,
    required this.isGeneral,
    this.onIsGeneralChanged,
    required this.description,
  });

  @override
  State<MultipleTeethTreatment> createState() => _MultipleTeethTreatmentState();
}

class _MultipleTeethTreatmentState extends State<MultipleTeethTreatment> {
  List selectedCodes = [];
  bool isActive = false;

  List getSelectedTeethCodes() {
    return [];
  }

  void onPressed(int value, bool flag) {
    if (flag) {
      widget.selectedCodes.add(value);
    } else {
      widget.selectedCodes.remove(value);
    }
  }

  List<Widget> upperTeethBuild() {
    List<Widget> teethLeft = [];
    for (int x = 11; x <= 18; x++) {
      teethLeft.add(ToothMultiple(
        code: x,
        onPressed: onPressed,
      ));
    }
    List<Widget> teethRight = [];
    for (int x = 21; x <= 28; x++) {
      teethRight.add(ToothMultiple(
        code: x,
        onPressed: onPressed,
      ));
    }
    teethRight = teethRight.reversed.toList();

    List<Widget> teeth = teethRight + teethLeft;
    return teeth;
  }

  List<Widget> downTeethBuild() {
    List<Widget> teethLeft = [];
    for (int x = 41; x <= 48; x++) {
      teethLeft.add(ToothMultiple(
        code: x,
        onPressed: onPressed,
      ));
    }
    List<Widget> teethRight = [];
    for (int x = 31; x <= 38; x++) {
      teethRight.add(ToothMultiple(
        code: x,
        onPressed: onPressed,
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
        Expanded(flex: 2, child: Text(widget.description)),
        Expanded(
            flex: 8,
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
