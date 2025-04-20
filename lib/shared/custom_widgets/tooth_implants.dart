import '../../database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ToothImplants extends StatefulWidget {
  final int code;
  final int patientId;
  final Function(int) onTap;
  const ToothImplants(
      {super.key,
      required this.code,
      required this.patientId,
      required this.onTap});

  @override
  State<ToothImplants> createState() => _ToothImplantsState();
}

class _ToothImplantsState extends State<ToothImplants> {
  SqlDb dataHelper = SqlDb();
  Color toothColor = Colors.white;
  Color standardColor = Colors.white;

  Future<void> checkForPreviousEntries() async {
    List data = await dataHelper.readData(
        '''SELECT * FROM implants WHERE patient_id = ${widget.patientId} AND EXISTS (
    SELECT 1
    FROM json_each(tooth_code)
    WHERE value = ${widget.code}
  )   ''');

    if (data.isEmpty) {
      standardColor = Colors.white;
      toothColor = standardColor;
    } else {
      standardColor = Colors.red.withOpacity(0.5);
      toothColor = standardColor;
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ToothImplants oldWidget) {
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
