import 'package:billmind/models/client.dart';

class Debts {
  final int id;
  final String expiration;
  final String amount;
  final String description;
  final String relevance;
  final Client client;
  
  Debts({
    required this.id,
    required this.expiration,
    required this.amount,
    required this.description,
    required this.relevance,
    required this.client,
  });

  factory Debts.fromJson(Map<String, dynamic> json) {
    return Debts(
      id: json['id'],
      expiration: json['expiration'],
      amount: json['amount'],
      description: json['description'],
      relevance: json['relevance'],
      client: Client.fromJson(json['clientId']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expiration': expiration,
    'amount': amount,
    'description': description,
    'relevance': relevance,
    'clientId': client.toJson(), // Aquí se convierte el objeto Client a JSON
  };
}