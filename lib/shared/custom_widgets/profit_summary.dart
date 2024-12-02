import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfitSummary extends StatefulWidget {
  final num totalExpenses;
  final num totalPaid;
  final num profit;
  const ProfitSummary(
      {super.key,
      required this.totalExpenses,
      required this.totalPaid,
      required this.profit});

  @override
  State<ProfitSummary> createState() => _ProfitSummaryState();
}

class _ProfitSummaryState extends State<ProfitSummary> {
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
            height: 50,
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.total_expenses,
                    children: [
                      TextSpan(text: ' : '),
                      TextSpan(text: widget.totalExpenses.toStringAsFixed(2)),
                      TextSpan(text: ' '),
                      TextSpan(text: '\$')
                    ])),
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.total_incoming_payments,
                    children: [
                      TextSpan(text: ' : '),
                      TextSpan(text: widget.totalPaid.toStringAsFixed(2)),
                      TextSpan(text: ' '),
                      TextSpan(text: '\$')
                    ])),
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.profit,
                    children: [
                      TextSpan(text: ' : '),
                      TextSpan(text: widget.profit.toStringAsFixed(2)),
                      TextSpan(text: ' '),
                      TextSpan(text: '\$')
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
