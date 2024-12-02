import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryCard extends StatefulWidget {
  final num totalCost;
  final num totalPaid;
  const SummaryCard(
      {super.key, required this.totalCost, required this.totalPaid});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  num remaining = 0;
  double percentage = 0;

  void setUp() {
    if (widget.totalPaid == 0 || widget.totalCost == 0) {
      percentage = 0; // Handle division by zero
    } else {
      percentage = (widget.totalPaid / widget.totalCost) * 100;
      remaining = widget.totalCost - widget.totalPaid;
    }
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Acrylic(
        elevation: 8,
        tintAlpha: 0.2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 500,
            height: 100,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                SizedBox(
                    width: 400,
                    child: percentage <= 100
                        ? ProgressBar(
                            value: percentage,
                            activeColor: Colors.green,
                          )
                        : Center(
                            child: Text(
                            AppLocalizations.of(context)!.exceeded_invoices,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                SizedBox(
                  height: 8,
                ),
                Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text.rich(TextSpan(
                        text: AppLocalizations.of(context)!.total_invoices,
                        children: [
                          TextSpan(text: ' : '),
                          TextSpan(text: widget.totalCost.toStringAsFixed(2)),
                          TextSpan(text: ' '),
                          TextSpan(text: '\$')
                        ])),
                    Text.rich(TextSpan(
                        text: AppLocalizations.of(context)!.total_paid,
                        children: [
                          TextSpan(text: ' : '),
                          TextSpan(text: widget.totalPaid.toStringAsFixed(2)),
                          TextSpan(text: ' '),
                          TextSpan(text: '\$')
                        ])),
                    Text.rich(TextSpan(
                        text: AppLocalizations.of(context)!.remaining,
                        children: [
                          TextSpan(text: ' : '),
                          TextSpan(text: remaining.toStringAsFixed(2)),
                          TextSpan(text: ' '),
                          TextSpan(text: '\$')
                        ]))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
