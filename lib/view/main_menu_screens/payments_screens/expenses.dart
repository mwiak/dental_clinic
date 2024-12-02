import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../database/sqflite.dart';
import '../../../shared/custom_widgets/cost_box.dart';
import '../../../shared/custom_widgets/date_pickers.dart';
import '../../../shared/custom_widgets/expenses_entry.dart';
import '../../../shared/custom_widgets/flyout.dart';
import '../../../shared/custom_widgets/text_boxes.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  SqlDb dataHelper = SqlDb();
  TextEditingController dateC = TextEditingController();
  TextEditingController causeC = TextEditingController();
  TextEditingController amountC = TextEditingController();

  Future<List> getAllPaymentsFromPatient() async {
    var data = await dataHelper.readData('''SELECT * FROM expenses  ''');

    return data;
  }

  Future<void> saveNewExpense(String cause, String date, num amount) async {
    int response = await dataHelper.insertData(
        ''' INSERT INTO expenses (description,date,amount) VALUES('$cause','$date', $amount ) ''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void validateAddExpense() {
    if (amountC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String cause = causeC.text.trim();
      String date = dateC.text;
      num amount = num.parse(amountC.text);
      saveNewExpense(cause, date, amount);
    }
  }

  Future<void> modifyImplant(
      int id, num amount, String date, String cause) async {
    int response = await dataHelper.updateData(
        ''' UPDATE expenses SET date = '$date',amount = $amount ,description = '$cause' WHERE id = $id''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void validateModifyExpense(int id) {
    if (amountC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String cause = causeC.text.trim();
      String date = dateC.text;
      num amount = num.parse(amountC.text);
      modifyImplant(id, amount, date, cause);
    }
  }

  Future<void> deleteExpense(int id) async {
    int response = await dataHelper
        .deleteData(''' DELETE FROM expenses WHERE id = $id ''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void showAddExpenseDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Text(AppLocalizations.of(context)!.add_payment),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: causeC,
                  label: AppLocalizations.of(context)!.payment_cause,
                  readOnly: true,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CostBox(
                  label: AppLocalizations.of(context)!.amount,
                  controller: amountC),
              SizedBox(
                height: 5,
              ),
              DatePickerBasic(
                  label: AppLocalizations.of(context)!.payment_date,
                  value: dateC),
              SizedBox(
                height: 5,
              ),
            ],
          ),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
                // Delete file here
              },
            ),
            FilledButton(
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () {
                validateAddExpense();
              },
            ),
          ],
        );
      }),
    );

    dateC.clear();
    causeC.clear();
    amountC.clear();
  }

  void showModifyExpenseDialog(BuildContext context, Map expenseData) async {
    int id = expenseData['id'];
    amountC.text = expenseData['amount'].toString();
    causeC.text = expenseData['description'] ?? '';
    dateC.text = expenseData['date'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.modify_implant),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () {
                    deleteExpense(expenseData['id']);
                  },
                  action:
                      AppLocalizations.of(context)!.generic_delete_confirmation,
                  buttonText: AppLocalizations.of(context)!.generic_delete)
            ],
          ),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: causeC,
                  label: AppLocalizations.of(context)!.payment_cause,
                  readOnly: true,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CostBox(
                  label: AppLocalizations.of(context)!.amount,
                  controller: amountC),
              SizedBox(
                height: 5,
              ),
              DatePickerNullable(
                label: AppLocalizations.of(context)!.payment_date,
                value: dateC,
                date: dateC.text,
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
                // Delete file here
              },
            ),
            FilledButton(
              child: Text(AppLocalizations.of(context)!.generic_modify),
              onPressed: () {
                validateModifyExpense(id);
              },
            ),
          ],
        );
      }),
    );

    dateC.clear();
    causeC.clear();
    amountC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                child: BasicHeader(
                    title1: 'المصروف', title2: 'المبلغ', title3: 'التاريخ'),
              ),
              IconButton(
                  onPressed: () {
                    showAddExpenseDialog(context);
                  },
                  icon: Icon(FluentIcons.add))
            ],
          ),
          Divider(),
          SizedBox(
            width: 500,
            height: 509,
            child: FutureBuilder(
                future: getAllPaymentsFromPatient(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: ProgressRing());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا يوجد دفعات'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        String title = snapshot.data![index]['description'];
                        num cost = snapshot.data![index]['amount'];
                        String date = snapshot.data![index]['date'] ??
                            'لا يوجد تاريخ محدد';
                        return GestureDetector(
                          onTap: () {
                            showModifyExpenseDialog(
                                context, snapshot.data![index]);
                          },
                          child: ExpensesEntry(
                            title: title,
                            cost: cost,
                            date: date,
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
