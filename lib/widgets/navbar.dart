import 'package:billmind/models/client.dart';
import 'package:billmind/pages/principal/balance_page.dart';
import 'package:billmind/pages/principal/calendar_alert_page.dart';
import 'package:billmind/pages/principal/debts_page.dart';
import 'package:billmind/pages/principal/profile_page.dart';
import 'package:billmind/services/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  final Client client;

  const Navbar({super.key, required this.client});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientId = Provider.of<ClientProvider>(context).clientId;

    return Scaffold(
        appBar: AppBar(
          title: const Text('BillMind'),
        ),
        body: TabBarView(
          controller: _tabController,
          children:[
            DebtsPage(clientId: clientId ?? 0),
            CalendarAlertPage(clientId: clientId ?? 0),
            BalancePage(clientId: clientId ?? 0),
            ProfilePage(clientId: clientId ?? 0),
          ],
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor:
                Colors.green,
            unselectedLabelColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.all(5.0),
            tabs: const [
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Cuentas'),
              Tab(icon: Icon(Icons.notifications_active), text: 'Alertas'),
              Tab(icon: Icon(Icons.account_balance), text: 'Balance'),
              Tab(icon: Icon(Icons.person_outline), text: 'Perfil'),
            ],
          ),
        )
    );
  }
}