import 'package:dental_clinic/shared/custom_widgets/profit_summary.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../database/sqflite.dart';
import '../../../model/entities/monatery_entity.dart';
import '../../../shared/custom_widgets/headers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport({super.key});

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  SqlDb dataHelper = SqlDb();
  TextEditingController yearC = TextEditingController();
  Map dataFinal = {};
  bool isLoading = true;

  List<String> monthsAr = [
    'كانون الثاني',
    'شباط',
    'أذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'أب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  List<String> monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String parseGivenMonth(int input) {
    if (AppLocalizations.of(context)!.localeName == 'ar') {
      return monthsAr[input - 1] + '  ' + input.toString();
    } else {
      return monthsEn[input - 1] + '  ' + input.toString();
    }
  }

  DateTime stringToDate(String x) {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    DateTime dateTime = dateFormat.parse(x);
    return dateTime;
  }

  void parseYearInput() async {
    String input = yearC.text.trim();
    if (input != '') {
      int result = int.parse(input);
      showLoadingAlert(context);
      await processReport1(result);
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context).pop();
    } else {
      showErorrAlertDialog(context, '', 'أدخل السنة');
    }
  }

  //database
  Future<List> getExpenses() async {
    List<Map<String, dynamic>> data =
        await dataHelper.readData(''' SELECT * from expenses''');
    List<MonetaryEntry> response = data.map((Map element) {
      DateTime date = stringToDate(element['date']);
      return MonetaryEntry(
          name: element['description'], amount: element['amount'], date: date);
    }).toList();
    return response;
  }

  Future<List> getPayments() async {
    List<Map<String, dynamic>> data =
        await dataHelper.readData(''' SELECT * from payments''');
    List<MonetaryEntry> response = data.map((Map element) {
      DateTime date = stringToDate(element['date']);
      return MonetaryEntry(
          name: element['title'], amount: element['amount'], date: date);
    }).toList();
    return response;
  }

  Future<void> processReport1(int givenYear) async {
    List payments = await getPayments();
    List expenses = await getExpenses();
    Map<int, Map> total = {};
    num totalP = 0;
    num totalE = 0;
    num totalProfit = 0;

    for (int x = 1; x < 13; x++) {
      Map<String, dynamic> y = {};

      // Filter payments and expenses by year and month
      List yearFilteredPayments = payments
          .where((element) =>
              element.date.year == givenYear && element.date.month == x)
          .toList();
      List yearFilteredExpenses = expenses
          .where((element) =>
              element.date.year == givenYear && element.date.month == x)
          .toList();

      // Handle empty lists by setting default value (0)
      num currentMonthP = yearFilteredPayments.isNotEmpty
          ? yearFilteredPayments
              .map((obj) => obj.amount)
              .reduce((a, b) => a + b)
          : 0;
      num currentMonthE = yearFilteredExpenses.isNotEmpty
          ? yearFilteredExpenses
              .map((obj) => obj.amount)
              .reduce((a, b) => a + b)
          : 0;
      totalE = totalE + currentMonthE;
      totalP = totalP + currentMonthP;
      // Calculate profit
      num currentMonthProfit = currentMonthP - currentMonthE;

      // Only add data if payments or expenses exist
      if (currentMonthP != 0 || currentMonthE != 0) {
        y = {
          'Month_p': currentMonthP,
          'Month_e': currentMonthE,
          'Month_profit': currentMonthProfit,
        };

        total[x] = y;
      }
    }
    totalProfit = totalP - totalE;
    total[20] = {
      'yearP': totalP,
      'yearE': totalE,
      'yearProfit': totalProfit,
      'year': givenYear
    };
    dataFinal = total;

    setState(() {
      isLoading = false;
    });
  }

  showLoadingAlert(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ContentDialog(
            content: SizedBox(
              width: 250,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProgressRing(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(AppLocalizations.of(context)!.report_being_prepared)
                ],
              ),
            ),
          );
        });
  }

  void showErorrAlertDialog(
      BuildContext context, String title, String content) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ContentDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                Button(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.close))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          SizedBox(
              width: 300,
              child: TextBox(
                placeholder:
                    AppLocalizations.of(context)!.year_report_placeholder,
                controller: yearC,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              )),
          const SizedBox(
            height: 20,
          ),
          Button(
              onPressed: () {
                parseYearInput();
              },
              child: Text(AppLocalizations.of(context)!.start_report)),
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? SizedBox.shrink()
              : Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dataFinal[20]['year'].toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(' '),
                          Text(
                            AppLocalizations.of(context)!.financial_report,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProfitSummary(
                                totalExpenses: dataFinal[20]['yearE'],
                                totalPaid: dataFinal[20]['yearP'],
                                profit: dataFinal[20]['yearProfit'])
                          ],
                        ),
                      ),
                      RemindersHeader(
                          title1: AppLocalizations.of(context)!.month,
                          title2: AppLocalizations.of(context)!.total_expenses,
                          title3: AppLocalizations.of(context)!
                              .total_incoming_payments,
                          title4: AppLocalizations.of(context)!.profit),
                      SizedBox(
                        height: 300,
                        width: 500,
                        child: ListView.builder(
                          itemCount:
                              13, // Define how many items the ListView should display
                          itemBuilder: (context, i) {
                            // Safely check for null or empty data at index i
                            if (dataFinal[i] != null &&
                                dataFinal[i]!.isNotEmpty) {
                              String month = parseGivenMonth(i);
                              String monthP =
                                  dataFinal[i]!['Month_p'].toStringAsFixed(2);
                              String monthE =
                                  dataFinal[i]!['Month_e'].toStringAsFixed(2);
                              String monthProfit = dataFinal[i]!['Month_profit']
                                  .toStringAsFixed(2);

                              return SizedBox(
                                width: 500,
                                child: RemindersHeader(
                                    title1: month,
                                    title2: monthE,
                                    title3: monthP,
                                    title4: monthProfit),
                              );
                            } else {
                              // Return an empty widget or some placeholder when data is not valid
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
