import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../shared/custom_widgets/patient_inpayment_entry.dart';

class IncompletedPayments extends StatefulWidget {
  const IncompletedPayments({super.key});

  @override
  State<IncompletedPayments> createState() => _IncompletedPaymentsState();
}

class _IncompletedPaymentsState extends State<IncompletedPayments> {
  SqlDb dataHelper = SqlDb();

  Future<List> getRemainingPatientsBalance() async {
    List<Map> response = [];
    var data = await dataHelper.readData(''' SELECT * FROM patients''');

    List patientsIds = data.map((Map patientMap) {
      int patientId = patientMap['id'];
      String fullName = patientMap['firstname'] + ' ' + patientMap['lastname'];
      Map patientCompact = {'id': patientId, 'full_name': fullName};
      return patientCompact;
    }).toList();

    for (int x = 0; x < patientsIds.length; x++) {
      int id = patientsIds[x]['id'];
      String name = patientsIds[x]['full_name'];
      var data1 = await dataHelper.readData(
          '''SELECT SUM(cost) as total_treatments FROM treatments WHERE patient_id = $id ''');
      var data2 = await dataHelper.readData(
          '''SELECT SUM(cost) as total_gum_treatments FROM general_treatments WHERE patient_id = $id ''');
      var data3 = await dataHelper.readData(
          '''SELECT SUM(cost) as total_implants FROM implants WHERE patient_id = $id ''');

      var data4 = await dataHelper.readData(
          '''SELECT SUM(amount) as total_paid FROM payments WHERE patient_id = $id ''');

      num totalTreatment = data1[0]['total_treatments'] ?? 0;
      num totalGumTreatment = data2[0]['total_gum_treatments'] ?? 0;
      num totalImplants = data3[0]['total_implants'] ?? 0;
      num totalPaid = data4[0]['total_paid'] ?? 0;
      num totalCost = totalTreatment + totalGumTreatment + totalImplants;
      num remaining = totalCost - totalPaid;

      if (remaining > 0) {
        Map finalMap = {
          'id': id,
          'full_name': name,
          'total_cost': totalCost,
          'total_paid': totalPaid,
          'remaining': remaining
        };

        response.add(finalMap);
      }
    }

    return response;
  }

  Future<List<Map<String, dynamic>>> getRemainingPatientsBalanceFaster() async {
    List<Map<String, dynamic>> response = [];

    // Fetch all necessary data in fewer queries
    var patientsData = await dataHelper
        .readData('SELECT id, firstname, lastname FROM patients');
    var treatmentsData = await dataHelper.readData(
        'SELECT patient_id, SUM(cost) as total_treatments FROM treatments GROUP BY patient_id');
    var gumTreatmentsData = await dataHelper.readData(
        'SELECT patient_id, SUM(cost) as total_gum_treatments FROM general_treatments GROUP BY patient_id');
    var implantsData = await dataHelper.readData(
        'SELECT patient_id, SUM(cost) as total_implants FROM implants GROUP BY patient_id');
    var paymentsData = await dataHelper.readData(
        'SELECT patient_id, SUM(amount) as total_paid FROM payments GROUP BY patient_id');

    // Convert data to maps for easier access
    Map<int, num> treatmentsMap = {
      for (var row in treatmentsData)
        row['patient_id']: row['total_treatments'] ?? 0
    };
    Map<int, num> gumTreatmentsMap = {
      for (var row in gumTreatmentsData)
        row['patient_id']: row['total_gum_treatments'] ?? 0
    };
    Map<int, num> implantsMap = {
      for (var row in implantsData)
        row['patient_id']: row['total_implants'] ?? 0
    };
    Map<int, num> paymentsMap = {
      for (var row in paymentsData) row['patient_id']: row['total_paid'] ?? 0
    };

    // Process each patient
    for (var patient in patientsData) {
      int id = patient['id'];
      String name = '${patient['firstname']} ${patient['lastname']}';

      num totalTreatment = treatmentsMap[id] ?? 0;
      num totalGumTreatment = gumTreatmentsMap[id] ?? 0;
      num totalImplants = implantsMap[id] ?? 0;
      num totalPaid = paymentsMap[id] ?? 0;
      num totalCost = totalTreatment + totalGumTreatment + totalImplants;
      num remaining = totalCost - totalPaid;

      if (remaining > 0) {
        response.add({
          'id': id,
          'full_name': name,
          'total_cost': totalCost,
          'total_paid': totalPaid,
          'remaining': remaining,
        });
      }
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const SizedBox(
          width: 500,
          child: Text('ستظهر سجلات المرضى المتبقي عليهم دفعات'),
        ),
        const Divider(),
        const SizedBox(
          width: 500,
          child: RemindersHeader(
            title1: 'اسم المريض',
            title2: 'إجمالي الفواتير',
            title3: 'إجمالي الدفعات',
            title4: 'المبلغ المتبقي',
          ),
        ),
        const Divider(),
        FutureBuilder(
            future: getRemainingPatientsBalanceFaster(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ProgressRing());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('لا يوجد مرضى متبقي عليهم دفعات'));
              } else {
                return SizedBox(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        int id = snapshot.data![i]['id'];
                        String name = snapshot.data![i]['full_name'];
                        num cost = snapshot.data![i]['total_cost'];
                        num paid = snapshot.data![i]['total_paid'];
                        num remaining = snapshot.data![i]['remaining'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: PatientEntryForPayments(
                            name: name,
                            cost: cost,
                            paid: paid,
                            remaining: remaining,
                            patientId: id,
                          ),
                        );
                      }),
                );
              }
            }),
      ],
    ));
  }
}
