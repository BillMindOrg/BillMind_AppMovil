import 'package:billmind/models/client.dart';
import 'package:billmind/models/debts.dart';
import 'package:billmind/services/client_service.dart';
import 'package:billmind/services/debts_service.dart';
import 'package:flutter/material.dart';

class DebtsPage extends StatefulWidget {
  final int clientId;
  const DebtsPage({super.key, required this.clientId});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  late Future<List<Debts>> _debts;
  final DebtsService dService = DebtsService();
  final ClientService cService = ClientService();

  @override
  void initState() {
    super.initState();
    _debts = fetchDebts();
  }

  Future<List<Debts>> fetchDebts() async {
    try {
      final debts = await cService.getClientDebts(widget.clientId);
      return debts;
    } catch (e) {
      print('Error fetching debts: $e');
      throw Exception('Error fetching debts: $e');
    }
  }

  Future<void> addDebt(Debts debt) async {
    try {
      await dService.addDebt(widget.clientId, debt);
      setState(() {
        _debts = fetchDebts();
      });
    } catch (e) {
      print('Error adding debt: $e');
    }
  }

  Future<void> deleteDebt(int debtId) async {
    try {
      await dService.deleteDebt(debtId);
      setState(() {
        _debts = fetchDebts();
      });
    } catch (e) {
      print('Error deleting debt: $e');
    }
  }

  Future<void> showAddDebtDialog() async {
    TextEditingController expirationController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedRelevance;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva deuda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Monto a pagar'),
                ),
                TextField(
                  controller: expirationController,
                  decoration:
                      const InputDecoration(labelText: 'Fecha de vencimiento'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedRelevance,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRelevance = newValue;
                    });
                  },
                  items: <String>['Baja', 'Media', 'Alta']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Relevancia'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Debts newDebt = Debts(
                  id: 0,
                  expiration: expirationController.text,
                  amount: amountController.text,
                  description: descriptionController.text,
                  relevance: selectedRelevance ?? '',
                  client: Client(
                    id: widget.clientId,
                    name: '', // Aquí deberías obtener estos valores de algún lugar o dejarlos vacíos según tu lógica
                    lastName: '',
                    mail: '',
                    phone: '',
                    password: '',
                  ),
                );

                try {
                  await dService.addDebt(widget.clientId, newDebt);
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding debt: $e');
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Icon getRelevanceIcon(String relevance) {
    switch (relevance) {
      case 'Alta':
        return const Icon(Icons.warning, color: Colors.red);
      case 'Media':
        return const Icon(Icons.emergency, color: Colors.amber);
      case 'Baja':
        return const Icon(Icons.low_priority, color: Colors.green);
      default:
        return const Icon(
            Icons.error); // En caso de que no se reconozca la relevancia
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
      ),
      body: FutureBuilder<List<Debts>>(
        future: _debts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final debt = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: getRelevanceIcon(debt.relevance),
                    title: Text(debt.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Monto: S/. ${debt.amount.toString()}'),
                        Text('Vencimiento: ${debt.expiration}'),
                        Text('Relevancia: ${debt.relevance}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteDebt(debt.id),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No debts found.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDebtDialog,
        tooltip: 'Add Debt',
        child: const Icon(Icons.add),
      ),
    );
  }
}