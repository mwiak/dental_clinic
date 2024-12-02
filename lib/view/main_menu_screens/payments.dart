import 'package:dental_clinic/view/main_menu_screens/payments_screens/expenses.dart';
import 'package:dental_clinic/view/main_menu_screens/payments_screens/incompleted_payments.dart';
import 'package:dental_clinic/view/main_menu_screens/payments_screens/monthly_report.dart';
import 'package:dental_clinic/view/main_menu_screens/payments_screens/yearly_report.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  int topIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
          onChanged: (int i) => setState(() => topIndex = i),
          selected: topIndex,
          items: [
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.incomplete_payments),
              body: Center(
                child: IncompletedPayments(),
              ),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.expenses),
              body: Center(
                child: Expenses(),
              ),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.reports),
              body: Center(
                child: MonthlyReport(),
              ),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text(AppLocalizations.of(context)!.reports),
              body: Center(
                child: YearlyReport(),
              ),
            ),
          ],
          displayMode: PaneDisplayMode.top),
    );
  }
}
