import 'package:fluent_ui/fluent_ui.dart';

class ToothMultiple extends StatefulWidget {
  final int code;
  final Function(int code, bool flag) onPressed;

  const ToothMultiple({super.key, required this.code, required this.onPressed});

  @override
  State<ToothMultiple> createState() => _ToothMultipleState();
}

class _ToothMultipleState extends State<ToothMultiple> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
            width: 40, height: 50, 'assets/teeth_images/${widget.code}.png'),
        Text('${widget.code}'),
        Checkbox(
            checked: isActive,
            onChanged: (value) {
              setState(() {
                isActive = value!;
              });
              if (isActive) {
                widget.onPressed(widget.code, true);
              } else {
                widget.onPressed(widget.code, false);
              }
            })
      ],
    );
  }
}

class ToothMultipleDisplay extends StatefulWidget {
  final int code;

  final bool isActive;

  const ToothMultipleDisplay(
      {super.key, required this.code, required this.isActive});

  @override
  State<ToothMultipleDisplay> createState() => _ToothMultipleDisplayState();
}

class _ToothMultipleDisplayState extends State<ToothMultipleDisplay> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
            width: 50, height: 50, 'assets/teeth_images/${widget.code}.png'),
        Text('${widget.code}'),
        Checkbox(checked: widget.isActive, onChanged: null)
      ],
    );
  }
}
