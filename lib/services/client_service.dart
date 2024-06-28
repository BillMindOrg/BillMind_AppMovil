import 'dart:async';
import 'dart:convert';

import 'package:billmind/models/client.dart';
import 'package:billmind/models/debts.dart';
import 'package:http/http.dart' as http;

class ClientService {
  static const String baseUrl = 'https://billmindbackend-production-f0cc.up.railway.app/api/v1/clients';
  //static const String baseUrl = 'http://192.168.1.11:8080/api/v1/clients';

  // Método para iniciar sesión
  Future<Client?> login(String email, String password) async {
    const url = '$baseUrl/login';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Client.fromJson(data);
      } else if (response.statusCode == 401) {
        return null; // Credenciales incorrectas
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (_) {
      throw Exception('Request to $url timed out');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  //genera una funcion que trae un cliente por id
  Future<Client> getClientById(int id, {required int clientId}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load client: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (_) {
      throw Exception('Request to $baseUrl timed out');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  //obtener deudas de un cliente por id
  Future<List<Debts>> getClientDebts(int clientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$clientId/debts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(response.body);
      List<Debts> debts = jsonResponse.map((debt) => Debts.fromJson(debt)).toList();
      return debts;
    } else {
      throw Exception('Failed to load debts');
    }
  }

  //registrar un cliente
  Future<int> registerClient(Client client) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(client.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data[
            'id']; // Suponiendo que la respuesta contiene el ID del cliente
      } else {
        return -1;
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (_) {
      throw Exception('Request to $baseUrl timed out');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
