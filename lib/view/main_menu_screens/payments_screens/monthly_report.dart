import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:dental_clinic/shared/custom_widgets/profit_summary.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../../database/sqflite.dart';
import '../../../model/monatery_entity.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  SqlDb dataHelper = SqlDb();
  int currentMonthNumber = DateTime.now().month;
  int currentYearNumber = DateTime.now().year;
  int previousMonthsCount = 12 - DateTime.now().month;
  Map<int, Map> datafinal = {};
  bool isLoading = true;
  List currentMonthData = [];

  late num currentMonthE;
  late num currentMonthP;
  late num currentMonthProfit;

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

  String parseCurrentMonth() {
    int monthNumber = DateTime.now().month;
    return monthsAr[monthNumber - 1] + '  ' + monthNumber.toString();
  }

  String parseGivenMonth(int input) {
    return monthsAr[input - 1] + '  ' + input.toString();
  }

  Future<List> getExpenses() async {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> data = await dataHelper.readData(
        ''' SELECT * from expenses WHERE substr(date, -4) = '${now.year}'  ''');
    List<MonetaryEntry> response = data.map((Map element) {
      DateTime date = stringToDateN(element['date']);
      return MonetaryEntry(
          name: element['description'], amount: element['amount'], date: date);
    }).toList();
    return response;
  }

  Future<List> getExpenses1() async {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> data = await dataHelper.readData(
        ''' SELECT * from expenses WHERE substr(date, -4) = '${now.year}' ''');
    List<MonetaryEntry> response = data.map((Map element) {
      DateTime date = stringToDateN(element['date']);
      return MonetaryEntry(
          name: element['description'], amount: element['amount'], date: date);
    }).toList();
    return response;
  }

  Future<List> getPayments() async {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> data = await dataHelper.readData(
        ''' SELECT * from payments  WHERE substr(date, -4) = '${now.year}'  ''');
    List<MonetaryEntry> response = data.map((Map element) {
      DateTime date = stringToDateN(element['date']);
      return MonetaryEntry(
          name: element['title'], amount: element['amount'], date: date);
    }).toList();

    return response;
  }

  Future<List> processReport() async {
    List payments = await getPayments();
    List expenses = await getExpenses();

    List yearFilteredPayments = payments
        .where((element) => element.date.month == currentMonthNumber)
        .toList();
    List yearFilteredExpenses = expenses
        .where((element) => element.date.month == currentMonthNumber)
        .toList();
    if (yearFilteredExpenses.isNotEmpty) {
      currentMonthE =
          yearFilteredExpenses.map((obj) => obj.amount).reduce((a, b) => a + b);
    } else {
      currentMonthE = 0;
    }
    if (yearFilteredPayments.isNotEmpty) {
      currentMonthP =
          yearFilteredPayments.map((obj) => obj.amount).reduce((a, b) => a + b);
    } else {
      currentMonthP = 0;
    }

    currentMonthProfit = currentMonthP - currentMonthE;

    List<num> response = [currentMonthP, currentMonthE, currentMonthProfit];
    currentMonthData = response;

    return response;
  }

  Future<void> processReport1() async {
    List payments = await getPayments();
    List expenses = await getExpenses();
    Map<int, Map> total = {};

    for (int x = 1; x < currentMonthNumber; x++) {
      Map<String, dynamic> y = {};

      // Filter payments and expenses by year and month
      List yearFilteredPayments =
          payments.where((element) => element.date.month == x).toList();
      List yearFilteredExpenses =
          expenses.where((element) => element.date.month == x).toList();

      // Handle empty lists by setting default value (0)
      currentMonthP = yearFilteredPayments.isNotEmpty
          ? yearFilteredPayments
              .map((obj) => obj.amount)
              .reduce((a, b) => a + b)
          : 0;
      currentMonthE = yearFilteredExpenses.isNotEmpty
          ? yearFilteredExpenses
              .map((obj) => obj.amount)
              .reduce((a, b) => a + b)
          : 0;

      // Calculate profit
      currentMonthProfit = currentMonthP - currentMonthE;

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

    datafinal = total;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> processAll() async {
    await processReport();
    await processReport1();
  }

  @override
  void initState() {
    processAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              Text.rich(TextSpan(
                  text: 'الشهر الحالي',
                  style: TextStyle(fontSize: 20),
                  children: [
                    TextSpan(text: ": "),
                    TextSpan(
                        text: parseCurrentMonth(),
                        style: TextStyle(fontSize: 20, color: Colors.blue))
                  ])),
              isLoading
                  ? const SizedBox()
                  : SizedBox(
                      child: ProfitSummary(
                          totalExpenses: currentMonthData[1],
                          totalPaid: currentMonthData[0],
                          profit: currentMonthData[2]),
                    ),
              const SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Button(
                      child: Text('تحديث الصفحة'),
                      onPressed: () {
                        processAll();
                      },
                    ),
                  ),
                ],
              ),
              const Text(
                'الأشهر الماضية',
                style: TextStyle(fontSize: 20),
              ),
              const Divider(),
              const SizedBox(
                width: 500,
                child: RemindersHeader(
                    title1: 'الشهر',
                    title2: 'مصاريف الشهر',
                    title3: 'دفعات الشهر',
                    title4: 'الربح'),
              ),
              const Divider(),
              isLoading
                  ? const ProgressRing()
                  : SizedBox(
                      height: 350,
                      width: 500,
                      child: ListView.builder(
                        itemCount:
                            currentMonthNumber, // Define how many items the ListView should display
                        itemBuilder: (context, i) {
                          // Safely check for null or empty data at index i
                          if (datafinal[i] != null &&
                              datafinal[i]!.isNotEmpty) {
                            String month = parseGivenMonth(i);
                            String monthP =
                                datafinal[i]!['Month_p'].toStringAsFixed(2);
                            String monthE =
                                datafinal[i]!['Month_e'].toStringAsFixed(2);
                            String monthProfit = datafinal[i]!['Month_profit']
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
    );
  }
}
