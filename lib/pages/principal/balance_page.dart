import 'package:flutter/material.dart';

class BalancePage extends StatefulWidget {
  final int clientId;
  const BalancePage({super.key, required this.clientId});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Alerts Page'),
    );
  }
}