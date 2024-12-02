import 'package:fluent_ui/fluent_ui.dart';

import '../../database/sqflite.dart';

class ToothTreatments extends StatefulWidget {
  final int code;
  final int patientId;
  final Function(int) onTap;
  const ToothTreatments(
      {super.key,
      required this.code,
      required this.onTap,
      required this.patientId});

  @override
  State<ToothTreatments> createState() => _ToothTreatmentsState();
}

class _ToothTreatmentsState extends State<ToothTreatments> {
  SqlDb dataHelper = SqlDb();
  Color toothColor = Colors.white;
  Color standardColor = Colors.white;

  Future<void> checkForPreviousEntries() async {
    List data = await dataHelper.readData(
        '''SELECT * FROM treatments WHERE patient_id = ${widget.patientId} AND tooth_code = ${widget.code}   ''');

    if (data.isEmpty) {
      standardColor = Colors.white;
      toothColor = standardColor;
    } else {
      standardColor = Colors.blue.withOpacity(0.5);
      toothColor = standardColor;
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ToothTreatments oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    checkForPreviousEntries();
  }

  @override
  void initState() {
    checkForPreviousEntries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.6),
      child: MouseRegion(
        onExit: (event) {
          setState(() {
            toothColor = standardColor;
          });
        },
        onHover: (event) {
          setState(() {
            toothColor = FluentTheme.of(context).activeColor.withOpacity(0.5);
          });
        },
        cursor: SystemMouseCursors.click,
        child: HoverButton(
          onPressed: () {
            widget.onTap(widget.code);
          },
          builder: (context, states) {
            return Column(
              children: [
                ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      toothColor, // Adjust opacity for desired effect
                      BlendMode.modulate, // Blend mode to apply color filtering
                    ),
                    child:
                        Image.asset('assets/teeth_images/${widget.code}.png')),
                Text('${widget.code}')
              ],
            );
          },
        ),
      ),
    );
  }
}
