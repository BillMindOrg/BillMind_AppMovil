import 'package:billmind/database/balance_data.dart';
import 'package:billmind/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:billmind/models/debts.dart';
import 'package:billmind/services/client_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalancePage extends StatefulWidget {
  final int clientId;
  const BalancePage({super.key, required this.clientId});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final TextEditingController _capitalController = TextEditingController();
  double _capital = 0.0;
  late Future<List<Debts>> _debts;
  final ClientService cService = ClientService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCapital();
    _debts = fetchDebts();
  }

  Future<void> _loadCapital() async {
    double capital = await dbHelper.getCapital();
    setState(() {
      _capital = capital;
      _capitalController.text = _capital.toString();
    });
  }

  Future<void> _saveCapital() async {
    double capital = double.tryParse(_capitalController.text) ?? 0.0;
    await dbHelper.insertCapital(capital);
    setState(() {
      _capital = capital;
    });
  }

  Future<List<Debts>> fetchDebts() async {
    try {
      return await cService.getClientDebts(widget.clientId);
    } catch (e) {
      print('Error fetching debts: $e');
      throw Exception('Error fetching debts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _capitalController,
              decoration: const InputDecoration(
                labelText: 'Ingrese su capital',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _saveCapital,
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Debts>>(
              future: _debts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final debts = snapshot.data!;
                  double totalDebts = debts.fold(
                      0, (sum, debt) => sum + double.tryParse(debt.amount)!);
                  double balance = _capital - totalDebts;

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance del mes: S/. $balance'),
                        const SizedBox(height: 20),
                        _buildChart(debts, totalDebts, balance),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('No se encontraron deudas.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Debts> debts, double totalDebts, double balance) {
    List<BalanceData> chartData = [
      BalanceData('Deudas', totalDebts),
      BalanceData('Balance', balance),
    ];

    return Expanded(
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
          ColumnSeries<BalanceData, String>(
            dataSource: chartData,
            xValueMapper: (BalanceData data, _) => data.category,
            yValueMapper: (BalanceData data, _) => data.amount,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }
}
