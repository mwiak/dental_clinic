import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/custom_widgets/patient_inpayment_entry.dart';

class IncompletedPayments extends StatefulWidget {
  const IncompletedPayments({super.key});

  @override
  State<IncompletedPayments> createState() => _IncompletedPaymentsState();
}

class _IncompletedPaymentsState extends State<IncompletedPayments> {
  SqlDb dataHelper = SqlDb();

  Future<List<Map<String, dynamic>>> getRemainingPatientsBalance() async {
    List<Map<String, dynamic>> response = [];

    //fetch all data
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

    //convert the fetched data to maps with patient id as a key and sum as a value
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

    // checks if the patient has unpaid invoices and add the patient with the remaining to the response
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
        SizedBox(
          width: 500,
          child: Text(AppLocalizations.of(context)!.incomplete_message),
        ),
        const Divider(),
        SizedBox(
          width: 500,
          child: RemindersHeader(
            title1: AppLocalizations.of(context)!.patient_name,
            title2: AppLocalizations.of(context)!.total_invoices,
            title3: AppLocalizations.of(context)!.total_incoming_payments,
            title4: AppLocalizations.of(context)!.remaining,
          ),
        ),
        const Divider(),
        FutureBuilder(
            future: getRemainingPatientsBalance(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ProgressRing());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)!
                        .incomplete_payments_nodata));
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
