import 'dart:async';
import 'dart:convert';

import 'package:billmind/models/debts.dart';
import 'package:http/http.dart' as http;

class DebtsService {
  static const String clientUrl =
      'https://billmindbackend-production-f0cc.up.railway.app/api/v1/clients';
  static const String debtUrl =
      'https://billmindbackend-production-f0cc.up.railway.app/api/v1/debts';
  //static const String baseUrl = 'http://192.168.1.11:8080/api/v1/debts';

  Future<void> addDebt(int clientId, Debts debt) async {
    final String url = '$clientUrl/$clientId/debts';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(debt.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add debt: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (_) {
      throw Exception('Request to $url timed out');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> deleteDebt(int debtId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$debtUrl/$debtId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete debt: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (_) {
      throw Exception('Request to $debtUrl timed out');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
